class_name VehicleCards
extends Node2D
## n8 vehicles: every car under a tilted view as a ROTATION SET from art (render only). The atlas
## (tools/art/vehicle_cards.py, art/<view art key>/traffic_cards.png) holds, per sim car art id, the
## library turntable's five rotations for that pitch (nose to camera, three-quarter toward, side,
## three-quarter away, tail; ground centre at the cell's centre), the other eighths mirrored. A car
## draws the view nearest its heading, turned by the rest (<= VIEW_DEG / 2), as an upright card
## stretched back by 1 / ground_k; within `blend_deg` of a view boundary the neighbours cross-fade.
## Keyed by view art (p70 / p55; `top` none); a FINE row adds four 22.5-deg in-betweens.

const DIR: String = "res://features/vehicles/art/%s/traffic_cards.png"
const SHADER: String = "res://features/vehicles/vehicle_cards.gdshader"
const ROWS: int = 9  # the sim's car art ids 0-8; row 9 the sim bike (BIKE_ART), read from the sheet
const CELL_M: float = 7.0  # the atlas cell's side (m): CELL_PX 448 at 64 px/m
const BLEND_DEG: float = 0.0  # the cross-fade round a view boundary (deg of heading); 0 = hard swap
const CAP: int = 256
const WEAR_SEEDS: int = 64  # distinct dent patterns (the wear's seed range)
## Added to a wear(): SIREN flashes the light bar (police on duty, duty()); SOUL paints the soul's
## teal (a soul-hijacked car: the flat print's teal plate). The shader's siren_bit and soul_bit.
const SIREN: int = 4 * WEAR_SEEDS
const SOUL: int = 2 * SIREN
const POLICE_ART: int = 8  # the police cruiser's art row
const DUTY_SPEED: float = 1.0  # m/s: over it the cruiser's light bar flashes

static var _tex: Dictionary[String, Texture2D] = {}
static var blend_deg: float = BLEND_DEG  # live (dev scenes try others; the game: BLEND_DEG)
## How upright the card's vertical stays as it turns by the rest: 0 = the card rotates rigidly,
## 1 = only its long axis turns and its verticals stay screen-vertical (a yaw shear, no roll).
static var upright_k: float = 0.0

## Who stands in front of a card this frame (empty: every card in the vehicles band).
var front: VehicleFront = VehicleFront.new()
## The cards with someone in front, drawn just under the actors (VehicleView parents it there).
var under: MultiMeshInstance2D = null
## Skip cars whose ground point is off screen by more than a cell (VehicleView sets it); `seen`
## is this frame's cull rect (m; begin() sets it), empty without cull.
var cull: bool = false
var seen: Rect2 = Rect2()
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
var _grid: Vector2i = Vector2i(VehicleViews.COLS, ROWS)
var _fine: PackedInt32Array = PackedInt32Array()


func _init() -> void:
	var shader: Shader = load(SHADER) as Shader
	_node = VehicleCardMesh.make(CAP, shader, VehicleViews.COLS, ROWS)
	_mm = _node.multimesh
	add_child(_node)
	under = VehicleCardMesh.make(CAP, shader, VehicleViews.COLS, ROWS)
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
	if tex != _node.texture:  # a new atlas: its grid (columns, rows, FINE rows) into both layers
		_grid = VehicleViews.grid_of(tex, ROWS)
		_fine = VehicleViews.fine_rows(_grid.x, ViewMode.shared().art)
		for node: MultiMeshInstance2D in [_node, under]:
			VehicleCardMesh.set_grid(node, _grid)
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
	seen = VehicleCull.screen_m(self, CELL_M) if cull else Rect2()


## The shader's wear for VehicleBody.State `state`: 0 intact, 1 dented (D1), 2 smashed (D2), 3 burnt
## wreck, + 4 x a seed from `id` (two wrecks wear different dents); soul-hijacked: SOUL, no dents.
static func wear(state: int, id: int) -> int:
	var level: int = 0
	match state:
		VehicleBody.State.HIJACKED:
			level = SOUL
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
	if seen.has_area() and not seen.has_point(pos):
		return
	var a: float = rad_to_deg(atan2(head.y, head.x))
	var fine: bool = _fine.has(art)
	var step: float = VehicleViews.FINE_DEG if fine else VehicleViews.VIEW_DEG
	var pick: Vector3 = VehicleViews.view_of(a, fine)
	var turn: float = wrapf(a - pick.z, -180.0, 180.0)
	var w: float = 1.0
	var edge: float = step * 0.5 - absf(turn)
	if blend_deg > 0.0 and edge < blend_deg * 0.5:
		w = 0.5 + edge / blend_deg
		var nb: Vector3 = VehicleViews.view_of(a + signf(turn) * step, fine)
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


## The cards drawn this frame (all; count_under(): those under the actors, someone in front).
func count() -> int:
	return _n


func count_under() -> int:
	return _n_under


## The columns of the atlas begun last (a combined view's pitch swap changes it).
func cols() -> int:
	return _grid.x


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
	var cell: float = float(clampi(aw.x, 0, _grid.y - 1) * _grid.x) + pick.x
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
