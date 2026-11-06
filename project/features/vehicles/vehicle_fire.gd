class_name VehicleFire
extends Node2D
## A wreck burns (render only, VehicleView's child): for BURN_S seconds after a car becomes a
## wreck, the top-down fire loop (features/fx/art/fx_fire.png, 4 x 2 cells of 2.5 m: row 0 a
## 4-frame flame loop, row 1 two ember cells) sits on its engine bay, NOSE_M ahead of the centre,
## shrinking over the last FADE_S. A held `fire` light (lights.json) burns with it when a
## LightLayer is handed in, off the day grade only (like the headlights: in daylight its halo
## washed the wreck smoke pink). Frames and flicker are functions of the wreck's own sim clock
## (VehicleBody.wreck_t), so the same tick draws the same fire; nothing goes back to the sim.

const SHEET: String = "res://features/fx/art/fx_fire.png"
const CELL_PX: float = 256.0
const CELL_M: float = 2.5
const BURN_S: float = VehicleContacts.BURN_S
const FADE_S: float = 6.0
const NOSE_M: float = VehicleContacts.NOSE_M
const FLAME_SCALE: float = 1.0
const EMBER_SCALE: float = 1.3
## Flame loop frames per second.
const FPS: float = 10.0
const LIGHT_KIND: StringName = &"fire"
const DAY: StringName = &"day"
## n8: the bonnet's height (m): the fire sits on it when the car draws as a card (VehicleCards).
const HOOD_H_M: float = 1.0
## n8: on a card the top-down burst stands up as a flame: narrower and taller, its foot on the
## bonnet (x, y of the cell's size; ONE on the ground).
const STAND: Vector2 = Vector2(0.7, 1.4)

var service: VehicleService = null
## The page's lights (optional): one held `fire` light per burning wreck.
var lights: LightLayer = null
var _tex: Texture2D = null
## Car id -> light handle while it burns.
var _lit: Dictionary[int, int] = {}


## The flame size factor of a wreck `t` seconds old: 0 before it wrecked and after BURN_S,
## 1 while it burns, easing down over the last FADE_S.
static func flame(t: float) -> float:
	if t < 0.0 or t >= BURN_S:
		return 0.0
	return clampf((BURN_S - t) / FADE_S, 0.0, 1.0)


## The burning wrecks' ids this frame (evidence and tests).
func burning() -> PackedInt32Array:
	var out: PackedInt32Array = PackedInt32Array()
	if service == null:
		return out
	for b: VehicleBody in service.cars:
		if b.state == VehicleBody.State.WRECK and flame(b.wreck_t) > 0.0:
			@warning_ignore("return_value_discarded")
			out.append(b.id)
	return out


func _process(_delta: float) -> void:
	if service == null:
		return
	_light(burning())
	queue_redraw()


func _draw() -> void:
	if service == null:
		return
	if _tex == null:
		_tex = load(SHEET) as Texture2D
	for b: VehicleBody in service.cars:
		if b.state != VehicleBody.State.WRECK:
			continue
		var f: float = flame(b.wreck_t)
		if f <= 0.0:
			continue
		var lift: Vector2 = hood_lift()
		var at: Vector2 = (b.pos + b.head * NOSE_M) * SimConst.PX_PER_M + lift
		var frame: int = int(b.wreck_t * FPS) % 4
		var stand: Vector2 = Vector2.ONE if lift == Vector2.ZERO else STAND
		_cell(Vector2i((frame + b.id) % 2, 1), at - b.head * 16.0, EMBER_SCALE * f * Vector2.ONE)
		_cell(Vector2i(frame, 0), at, FLAME_SCALE * (0.75 + 0.25 * f) * stand)


## The fire's lift onto the bonnet: only when the cars draw as cards (else ZERO: flat bodies).
static func hood_lift() -> Vector2:
	if VehicleCards.atlas() == null:
		return Vector2.ZERO
	return ViewMode.shared().lift_px(HOOD_H_M)


## One 2.5 m cell of the sheet at `at` (world px), `scale` x its size (per axis). A cell taller
## than wide stands on `at` (its lower quarter below, the rest rising); else it is centred.
func _cell(cell: Vector2i, at: Vector2, scale: Vector2) -> void:
	var size: Vector2 = scale * CELL_M * SimConst.PX_PER_M
	var src: Rect2 = Rect2(Vector2(cell) * CELL_PX, Vector2(CELL_PX, CELL_PX))
	var foot: float = 0.75 if scale.y > scale.x else 0.5
	var top_left: Vector2 = at - Vector2(size.x * 0.5, size.y * foot)
	draw_texture_rect_region(_tex, Rect2(top_left, size), src)


## Keeps one held light per burning wreck; frees the lights of the ones that went out.
func _light(ids: PackedInt32Array) -> void:
	if lights == null:
		return
	var on: bool = lights.grade != DAY
	for id: int in _lit.keys():
		if not on or not ids.has(id):
			lights.remove(_lit[id])
			@warning_ignore("return_value_discarded")
			_lit.erase(id)
	for b: VehicleBody in service.cars:
		if not on or not ids.has(b.id):
			continue
		var at: Vector2 = (b.pos + b.head * NOSE_M) * SimConst.PX_PER_M
		if _lit.has(b.id):
			lights.move(_lit[b.id], at, 0.0)
			continue
		var h: int = lights.add(LIGHT_KIND, at, 0.0, int(b.wreck_t * SimClock.TICK_RATE))
		if h >= 0:
			_lit[b.id] = h
