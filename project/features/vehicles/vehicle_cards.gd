class_name VehicleCards
extends Node2D
## n8 vehicles: every car under a tilted view as a ROTATION SET from art (render only). The atlas
## (tools/art/vehicle_cards.py, art/<view art key>/traffic_cards.png) holds, per sim car art id, the
## five rotations of the library's turntable sheet for that pitch (nose to the camera, three-quarter
## toward, side, three-quarter away, tail), the car's ground centre at each cell's centre; the three
## other eighths are those mirrored. A car draws the view nearest its heading, turned by the rest
## (at most VIEW_DEG / 2), as an upright card: the camera squashes the world canvas by ground_k, so
## the card is stretched back by 1 / ground_k and prints at the art's own proportions. Within
## `blend_deg` of a view boundary the two neighbouring views cross-fade (0 = a hard swap). The cards
## are keyed by ViewMode.art (p70 / p55), so a combined view swaps sets with its pitch; a pitch
## with no atlas (and `top`) draws nothing here and the flat crowd car layer stays on.

const DIR: String = "res://features/vehicles/art/%s/traffic_cards.png"
const SHADER: String = "res://features/vehicles/vehicle_cards.gdshader"
const COLS: int = 5
const ROWS: int = 9
## The atlas cell's side in metres (CELL_PX 448 at 64 px/m).
const CELL_M: float = 7.0
const VIEW_DEG: float = 45.0
## The cross-fade window around a view boundary (degrees of heading); 0 = hard swap.
const BLEND_DEG: float = 0.0
const CAP: int = 160

static var _tex: Dictionary[String, Texture2D] = {}
## The live cross-fade window (dev scenes try other values; the game keeps BLEND_DEG).
static var blend_deg: float = BLEND_DEG
## How upright the card's vertical stays as it turns by the rest: 0 = the card rotates rigidly,
## 1 = only its long axis turns and its verticals stay screen-vertical (a yaw shear, no roll).
static var upright_k: float = 0.0

var _mm: MultiMesh = null
var _node: MultiMeshInstance2D = null
var _n: int = 0


func _init() -> void:
	_mm = MultiMesh.new()
	_mm.transform_format = MultiMesh.TRANSFORM_2D
	_mm.use_colors = true
	_mm.use_custom_data = true
	_mm.mesh = _quad()
	_mm.instance_count = CAP
	_mm.visible_instance_count = 0
	_mm.custom_aabb = AABB(Vector3(-1e7, -1e7, -10), Vector3(2e7, 2e7, 20))
	_node = MultiMeshInstance2D.new()
	_node.multimesh = _mm
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = load(SHADER) as Shader
	mat.set_shader_parameter("cols", COLS)
	mat.set_shader_parameter("rows", ROWS)
	_node.material = mat
	add_child(_node)


## The card atlas for the shared view (null: flat, or no art for its pitch).
static func atlas() -> Texture2D:
	var view: ViewMode = ViewMode.shared()
	if view.is_flat() or view.art == "":
		return null
	var path: String = DIR % view.art
	if not _tex.has(path):
		_tex[path] = load(path) as Texture2D if ResourceLoader.exists(path) else null
	return _tex[path]


## Starts a frame with `tex`; then put() each car, then finish().
func begin(tex: Texture2D) -> void:
	_node.texture = tex
	_n = 0


## A car of art id `art` at `pos` (m) facing `head` (ground unit vector), tinted `tint`.
func put(art: int, pos: Vector2, head: Vector2, tint: Color) -> void:
	var a: float = rad_to_deg(atan2(head.y, head.x))
	var pick: Vector3 = view_of(a)
	var turn: float = wrapf(a - pick.z, -180.0, 180.0)
	var w: float = 1.0
	var edge: float = VIEW_DEG * 0.5 - absf(turn)
	if blend_deg > 0.0 and edge < blend_deg * 0.5:
		w = 0.5 + edge / blend_deg
		var nb: Vector3 = view_of(a + signf(turn) * VIEW_DEG)
		_one(art, pos, nb, wrapf(a - nb.z, -180.0, 180.0), Color(tint, tint.a * (1.0 - w)))
	_one(art, pos, pick, turn, Color(tint, tint.a * w))


func finish() -> void:
	_mm.visible_instance_count = _n


## The view for a nose angle `a_deg` (ground, y down: 90 = nose down the screen): x = the cell
## column 0-4, y = 1 when mirrored, z = the view's own nose angle (the card turns by the rest).
static func view_of(a_deg: float) -> Vector3:
	var a: float = wrapf(a_deg, -180.0, 180.0)
	var flip: bool = absf(a) > 90.0
	var s: float = 1.0 if a >= 0.0 else -1.0
	var a2: float = (s * 180.0 - a) if flip else a
	var i: int = clampi(roundi((90.0 - a2) / VIEW_DEG), 0, COLS - 1)
	var c: float = 90.0 - VIEW_DEG * i
	return Vector3(i, 1.0 if flip else 0.0, (s * 180.0 - c) if flip else c)


## The card's world transform: CELL_M square on screen, turned `turn_deg`, unsquashed by ground_k.
static func card_xf(pos: Vector2, turn_deg: float) -> Transform2D:
	var s: float = CELL_M * SimConst.PX_PER_M
	var gk: float = ViewMode.shared().ground_k()
	var r: Vector2 = Vector2.from_angle(deg_to_rad(turn_deg))
	var x: Vector2 = Vector2(r.x, r.y / gk) * s
	var y: Vector2 = Vector2(-r.y, r.x).lerp(Vector2(0.0, 1.0), upright_k)
	y = Vector2(y.x, y.y / gk) * s
	return Transform2D(x, y, pos * SimConst.PX_PER_M)


func _one(art: int, pos: Vector2, pick: Vector3, turn: float, c: Color) -> void:
	if _n >= CAP or c.a <= 0.0:
		return
	_mm.set_instance_transform_2d(_n, card_xf(pos, turn))
	_mm.set_instance_color(_n, c)
	var cell: float = float(clampi(art, 0, ROWS - 1) * COLS) + pick.x
	_mm.set_instance_custom_data(_n, Color(cell, pick.y, 0.0, 0.0))
	_n += 1


static func _quad() -> ArrayMesh:
	var arr: Array = []
	@warning_ignore("return_value_discarded")
	arr.resize(Mesh.ARRAY_MAX)
	var h: float = 0.5
	arr[Mesh.ARRAY_VERTEX] = PackedVector2Array(
		[Vector2(-h, -h), Vector2(h, -h), Vector2(h, h), Vector2(-h, h)]
	)
	arr[Mesh.ARRAY_TEX_UV] = PackedVector2Array(
		[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
	)
	arr[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 1, 2, 0, 2, 3])
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	return mesh
