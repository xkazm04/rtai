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
const CAP: int = 256
## Distinct dent patterns (the wear's seed range).
const WEAR_SEEDS: int = 64

static var _tex: Dictionary[String, Texture2D] = {}
## The live cross-fade window (dev scenes try other values; the game keeps BLEND_DEG).
static var blend_deg: float = BLEND_DEG
## How upright the card's vertical stays as it turns by the rest: 0 = the card rotates rigidly,
## 1 = only its long axis turns and its verticals stay screen-vertical (a yaw shear, no roll).
static var upright_k: float = 0.0

var _mm: MultiMesh = null
var _node: MultiMeshInstance2D = null
var _n: int = 0
## This frame's cards before the depth sort: ground y (m), transform, colour, custom data.
var _ys: PackedFloat32Array = PackedFloat32Array()
var _xfs: Array[Transform2D] = []
var _cs: PackedColorArray = PackedColorArray()
var _cds: PackedColorArray = PackedColorArray()


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
	_ys.clear()
	_xfs.clear()
	_cs.clear()
	_cds.clear()


## The shader's wear for a car in damage state `state` (VehicleBody.State): level 0 intact (and
## hijacked), 1 dented (D1), 2 smashed (D2), 3 burnt wreck, plus 4 x a seed from the car's `id`
## so two damaged cars do not wear the same dents.
static func wear(state: int, id: int) -> int:
	var level: int = 0
	match state:
		VehicleBody.State.D1:
			level = 1
		VehicleBody.State.D2:
			level = 2
		VehicleBody.State.WRECK:
			level = 3
	return level + 4 * (absi(id) % WEAR_SEEDS)


## A car of art id `art` at `pos` (m) facing `head` (ground unit vector), tinted `tint`, worn
## `worn` (wear(); 0 = intact).
func put(art: int, pos: Vector2, head: Vector2, tint: Color, worn: int = 0) -> void:
	var a: float = rad_to_deg(atan2(head.y, head.x))
	var pick: Vector3 = view_of(a)
	var turn: float = wrapf(a - pick.z, -180.0, 180.0)
	var w: float = 1.0
	var edge: float = VIEW_DEG * 0.5 - absf(turn)
	if blend_deg > 0.0 and edge < blend_deg * 0.5:
		w = 0.5 + edge / blend_deg
		var nb: Vector3 = view_of(a + signf(turn) * VIEW_DEG)
		var c: Color = Color(tint, tint.a * (1.0 - w))
		_one(Vector2i(art, worn), pos, nb, wrapf(a - nb.z, -180.0, 180.0), c)
	_one(Vector2i(art, worn), pos, pick, turn, Color(tint, tint.a * w))


## Writes the cards back to front (north to south on the ground: a car nearer the camera covers
## the one behind it, whatever order they were put in).
func finish() -> void:
	var order: Array[int] = back_to_front(_ys)
	for i: int in _n:
		var k: int = order[i]
		_mm.set_instance_transform_2d(i, _xfs[k])
		_mm.set_instance_color(i, _cs[k])
		_mm.set_instance_custom_data(i, _cds[k])
	_mm.visible_instance_count = _n


## The draw order for cards at ground y `ys`: north first, ties in put order.
static func back_to_front(ys: PackedFloat32Array) -> Array[int]:
	var order: Array[int] = []
	order.assign(range(ys.size()))
	order.sort_custom(
		func(a: int, b: int) -> bool: return ys[a] < ys[b] or (ys[a] == ys[b] and a < b)
	)
	return order


## The cards drawn this frame.
func count() -> int:
	return _n


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


## `aw`: the art id and the wear.
func _one(aw: Vector2i, pos: Vector2, pick: Vector3, turn: float, c: Color) -> void:
	if _n >= CAP or c.a <= 0.0:
		return
	var cell: float = float(clampi(aw.x, 0, ROWS - 1) * COLS) + pick.x
	@warning_ignore("return_value_discarded")
	_ys.append(pos.y)
	_xfs.append(card_xf(pos, turn))
	@warning_ignore("return_value_discarded")
	_cs.append(c)
	@warning_ignore("return_value_discarded")
	_cds.append(Color(cell, pick.y, float(aw.y), 0.0))
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
