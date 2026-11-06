class_name VehicleCards
extends Node2D
## n8 vehicles: every car under a tilted view as a ROTATION SET from art (render only). The atlas
## (tools/art/vehicle_cards.py, art/<view art key>/traffic_cards.png) holds, per sim car art id, the
## library turntable's five rotations for that pitch (nose to the camera, three-quarter toward,
## side, three-quarter away, tail), the car's ground centre at each cell's centre; the three other
## eighths are those mirrored. A car draws the view nearest its heading, turned by the rest (at most
## VIEW_DEG / 2), as an upright card stretched back by 1 / ground_k (the art's own proportions).
## Within `blend_deg` of a view boundary the neighbours cross-fade (0 = a hard swap). Keyed by
## ViewMode.art (p70 / p55): a combined view swaps sets with its pitch; no atlas (and `top`) = none.

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
const WEAR_SEEDS: int = 64  # distinct dent patterns (the wear's seed range)
## Added to a wear(): the car's light bar flashes (the shader's siren_bit; police on duty).
const SIREN: int = 4 * WEAR_SEEDS
## The police cruiser's art row, and the speed (m/s) over which its light bar flashes.
const POLICE_ART: int = 8
const DUTY_SPEED: float = 1.0

static var _tex: Dictionary[String, Texture2D] = {}
## The live cross-fade window (dev scenes try others; the game keeps BLEND_DEG).
static var blend_deg: float = BLEND_DEG
## How upright the card's vertical stays as it turns by the rest: 0 = the card rotates rigidly,
## 1 = only its long axis turns and its verticals stay screen-vertical (a yaw shear, no roll).
static var upright_k: float = 0.0

## Who stands in front of a card this frame (empty: every card in the vehicles band).
var front: VehicleFront = VehicleFront.new()
## The cards with someone in front, drawn just under the actors (VehicleView parents it there).
var under: MultiMeshInstance2D = null
## Skip cars whose ground point is off screen by more than a cell (VehicleView sets it).
var cull: bool = false
var _mm: MultiMesh = null
var _mm_under: MultiMesh = null
var _node: MultiMeshInstance2D = null
var _n: int = 0
var _n_under: int = 0
## This frame's cards before the depth sort: ground y (m), transform, colour, custom data.
var _ys: PackedFloat32Array = PackedFloat32Array()
var _xfs: Array[Transform2D] = []
var _cs: PackedColorArray = PackedColorArray()
var _cds: PackedColorArray = PackedColorArray()
var _below: PackedByteArray = PackedByteArray()
var _seen: Rect2 = Rect2()


func _init() -> void:
	var shader: Shader = load(SHADER) as Shader
	_node = VehicleCardMesh.make(CAP, shader, COLS, ROWS)
	_mm = _node.multimesh
	add_child(_node)
	under = VehicleCardMesh.make(CAP, shader, COLS, ROWS)
	_mm_under = under.multimesh


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
	under.texture = tex
	if under.get_parent() == null:
		add_child(under)
	_n = 0
	_ys.clear()
	_xfs.clear()
	_cs.clear()
	_cds.clear()
	_below.clear()
	_seen = VehicleCull.screen_m(self, CELL_M) if cull else Rect2()


## The shader's wear for VehicleBody.State `state`: 0 intact (and hijacked), 1 dented (D1), 2
## smashed (D2), 3 burnt wreck, plus 4 x a seed from `id` (two wrecks wear different dents).
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


## SIREN for a police card moving faster than DUTY_SPEED (a kerb-parked one stays dark), else 0.
static func duty(art: int, speed: float) -> int:
	return SIREN if art == POLICE_ART and speed > DUTY_SPEED else 0


## A car of art id `art` at `pos` (m) facing `head` (ground unit), tinted `tint`, worn `worn`.
func put(art: int, pos: Vector2, head: Vector2, tint: Color, worn: int = 0) -> void:
	if _seen.has_area() and not _seen.has_point(pos):
		return
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


## Writes the cards back to front (north to south: a nearer car covers the one behind it, in any
## put order); a card with someone in front goes to the under layer.
func finish() -> void:
	var order: Array[int] = back_to_front(_ys)
	var n: Vector2i = Vector2i.ZERO
	for k: int in order:
		var mm: MultiMesh = _mm_under if _below[k] == 1 else _mm
		var i: int = n.y if _below[k] == 1 else n.x
		mm.set_instance_transform_2d(i, _xfs[k])
		mm.set_instance_color(i, _cs[k])
		mm.set_instance_custom_data(i, _cds[k])
		n += Vector2i(0, 1) if _below[k] == 1 else Vector2i(1, 0)
	_mm.visible_instance_count = n.x
	_mm_under.visible_instance_count = n.y
	_n_under = n.y


## The draw order for cards at ground y `ys`: north first, ties in put order.
static func back_to_front(ys: PackedFloat32Array) -> Array[int]:
	var order: Array[int] = []
	order.assign(range(ys.size()))
	order.sort_custom(
		func(a: int, b: int) -> bool: return ys[a] < ys[b] or (ys[a] == ys[b] and a < b)
	)
	return order


## The cards drawn this frame (all), and those drawn under the actors (someone in front).
func count() -> int:
	return _n


func count_under() -> int:
	return _n_under


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
	@warning_ignore("return_value_discarded")
	_below.append(1 if front.blocks(pos) else 0)
	_n += 1
