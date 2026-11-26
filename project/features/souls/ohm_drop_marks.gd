class_name OhmDropMarks
extends RefCounted
## n31 ghost 12: the ground under Ohm's drop deploy, in amber current, ink and soot only (the
## teal stays on his body and bolts). The record outlives the ghost so the scorch can stay.
## P = press tick, D = the discharge tick (P + the row's charge ticks):
## - arrival P..P+5: a small ink shadow under him;
## - charge P..D-1: the amber creep (art/ohm_drop_creep.png) is revealed outward from his feet,
##   its tips' circle reaching radius_m exactly on D: the telegraph (foes can walk out);
## - discharge D..D+12: the arc ring (art/ohm_drop_arc.png) runs out to radius_m and fades,
##   the creep flashes whole at radius_m and fades;
## - aftermath: the scorch ring (outer edge = radius_m) and the burn core hold 2 s, fade 1 s.

const CREEP: Texture2D = preload("res://features/souls/art/ohm_drop_creep.png")
const SCORCH: Texture2D = preload("res://features/souls/art/ohm_drop_scorch.png")
const ARC: Texture2D = preload("res://features/souls/art/ohm_drop_arc.png")
const CORE: Texture2D = preload("res://features/souls/art/ohm_drop_core.png")
## Radius of the creep's tips circle in its art (angular coverage peak at 456-464 px).
const CREEP_RIM_PX: float = 460.0
## Outer edge of the scorch annulus in its art (coverage 0.5 at 440 px; sparks beyond).
const SCORCH_OUTER_PX: float = 440.0
## Outer edge of the arc ring's bolts in its art (coverage 0.5 at 300 px).
const ARC_OUTER_PX: float = 300.0
const CORE_M: float = 3.0
const INK: Color = Color(0.09, 0.08, 0.07)
const LAND_TICKS: int = 6
const ARC_REACH_TICKS: int = 6
const ARC_TICKS: int = 12
const SCORCH_IN_TICKS: int = 4
const HOLD_TICKS: int = 120
const FADE_TICKS: int = 60
const VERTS: int = 64

var spot: Vector2
var press_tick: int
var dump_tick: int
var radius_m: float
var _turn: float


func _init(at_px: Vector2, press: int, dump: int, radius: float) -> void:
	spot = at_px
	press_tick = press
	dump_tick = dump
	radius_m = radius
	_turn = TAU * fposmod(dump * 0.618, 1.0)


func live(tick: int) -> bool:
	return tick < dump_tick + HOLD_TICKS + FADE_TICKS


## The telegraph's front (metres from the spot): eases out from his feet to radius_m on D.
func reach_m(tick: int) -> float:
	var span: int = dump_tick - press_tick
	if tick >= dump_tick or span <= 0:
		return radius_m if tick >= dump_tick else 0.0
	var t: float = clampf(float(tick - press_tick) / span, 0.0, 1.0)
	return radius_m * (1.0 - (1.0 - t) * (1.0 - t))


## The arc ring's outer edge (metres) after the discharge: cubic ease-out to radius_m.
func arc_m(tick: int) -> float:
	var k: float = clampf(float(tick - dump_tick + 1) / ARC_REACH_TICKS, 0.0, 1.0)
	return radius_m * (1.0 - pow(1.0 - k, 3.0))


## The scorch's opacity: in over SCORCH_IN_TICKS, whole until D + HOLD_TICKS, gone over FADE_TICKS.
func ground_alpha(tick: int) -> float:
	var age: int = tick - dump_tick
	if age < 0:
		return 0.0
	var rise: float = clampf(float(age + 1) / SCORCH_IN_TICKS, 0.0, 1.0)
	return rise * (1.0 - clampf(float(age - HOLD_TICKS) / FADE_TICKS, 0.0, 1.0))


func draw(ci: CanvasItem, tick: int, ppm: float) -> void:
	var age: int = tick - dump_tick
	ci.draw_set_transform(spot)
	_shadow(ci, tick - press_tick, ppm)
	var scorch: float = ground_alpha(tick)
	_decal(ci, SCORCH, radius_m * ppm / SCORCH_OUTER_PX, scorch, _turn)
	_decal(ci, CORE, CORE_M * ppm / CORE.get_width(), scorch, 0.0)
	var creep: float = 1.0 if age < 0 else 1.0 - float(age) / ARC_TICKS
	_reveal(ci, reach_m(tick) * ppm, radius_m * ppm / CREEP_RIM_PX, creep)
	if age >= 0 and age < ARC_TICKS:
		var fade: float = 1.0 - float(age) / ARC_TICKS
		_decal(ci, ARC, arc_m(tick) * ppm / ARC_OUTER_PX, fade, -_turn)
	ci.draw_set_transform(Vector2.ZERO)


func _shadow(ci: CanvasItem, since: int, ppm: float) -> void:
	if since < 0 or since >= LAND_TICKS:
		return
	var k: float = float(since + 1) / LAND_TICKS
	ci.draw_circle(Vector2.ZERO, lerpf(0.2, 0.6, k) * ppm, Color(INK, lerpf(0.1, 0.35, k)))


## The creep art at its full size (tips on radius_m), shown only inside the front's circle.
func _reveal(ci: CanvasItem, front_px: float, s: float, alpha: float) -> void:
	if front_px <= 1.0 or alpha <= 0.0:
		return
	var size: Vector2 = CREEP.get_size()
	var pts: PackedVector2Array = PackedVector2Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	for i: int in VERTS:
		var off: Vector2 = Vector2.from_angle(TAU * i / VERTS) * front_px
		@warning_ignore("return_value_discarded")
		pts.push_back(off)
		@warning_ignore("return_value_discarded")
		uvs.push_back(Vector2(0.5, 0.5) + off.rotated(-_turn) / s / size)
	ci.draw_colored_polygon(pts, Color(1.0, 1.0, 1.0, alpha), uvs, CREEP)


func _decal(ci: CanvasItem, tex: Texture2D, s: float, alpha: float, turn: float) -> void:
	if alpha <= 0.0:
		return
	var size: Vector2 = tex.get_size() * s
	ci.draw_set_transform_matrix(Transform2D(0.0, spot) * Transform2D(turn, Vector2.ZERO))
	ci.draw_texture_rect(tex, Rect2(-size * 0.5, size), false, Color(1.0, 1.0, 1.0, alpha))
	ci.draw_set_transform(spot)
