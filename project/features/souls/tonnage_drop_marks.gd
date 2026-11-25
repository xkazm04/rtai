class_name TonnageDropMarks
extends RefCounted
## n31 ghost 03: the ground under Tonnage's drop deploy, in world colours only (ink, soot, tan,
## concrete; the teal stays on his body). The record outlives the ghost so the crater can stay.
## P = press tick, D = the dump tick (P + the row's charge ticks):
## - arrival P..P+5: an ink drop shadow grows under him; P+6.. a tan dust ring kicks outward;
## - charge P+6..D: the radial crack (art/tonnage_drop_crack.png) is revealed outward from his
##   feet, its front reaching radius_m exactly on D: the telegraph (foes can walk out);
## - dump D..D+24: an ink shock ring out to radius_m, a dust ring whose outer edge is radius_m,
##   SlamDebris chips; the crack stands whole at radius_m;
## - aftermath: the crater (art/tonnage_drop_crater.png) and the crack hold 2 s, then fade 1 s.

const CRACK: Texture2D = preload("res://features/souls/art/tonnage_drop_crack.png")
const CRATER: Texture2D = preload("res://features/souls/art/tonnage_drop_crater.png")
const DUST: Texture2D = preload("res://features/souls/art/tonnage_drop_dust.png")
## Radius of the crack tips' circle in the crack art (measured: alpha peak 460-470 px).
const CRACK_RIM_PX: float = 470.0
## Outer edge of the dust ring's puffs in the dust art (alpha 0.5 at 320-325 px).
const DUST_OUTER_PX: float = 325.0
const CRATER_M: float = 3.2
const INK: Color = Color(0.09, 0.08, 0.07)
const LAND_TICKS: int = 6
const ARRIVE_DUST_TICKS: int = 24
const SHOCK_REACH_TICKS: int = 8
const SHOCK_TICKS: int = 24
const DUMP_DUST_TICKS: int = 36
## Peak opacity of the dump dust ring (was 0.9, with a k^2 fade).
const DUMP_DUST_PEAK: float = 0.5
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
	var span: int = dump_tick - press_tick - LAND_TICKS
	if tick >= dump_tick or span <= 0:
		return radius_m if tick >= dump_tick else 0.0
	var t: float = clampf(float(tick - press_tick - LAND_TICKS) / span, 0.0, 1.0)
	return radius_m * (1.0 - (1.0 - t) * (1.0 - t))


## The ground's opacity: whole until D + HOLD_TICKS, then gone over FADE_TICKS.
func ground_alpha(tick: int) -> float:
	return 1.0 - clampf(float(tick - dump_tick - HOLD_TICKS) / FADE_TICKS, 0.0, 1.0)


func draw(ci: CanvasItem, tick: int, ppm: float) -> void:
	var fade: float = ground_alpha(tick)
	ci.draw_set_transform(spot)
	_shadow(ci, tick - press_tick, ppm)
	_dust(ci, tick, ppm)
	_crack(ci, reach_m(tick) * ppm, radius_m * ppm / CRACK_RIM_PX, fade)
	if tick >= dump_tick:
		_decal(ci, CRATER, CRATER_M * ppm / CRATER.get_width(), fade, 0.0)
	var age: int = tick - dump_tick
	if age >= 0 and age < SHOCK_TICKS:
		_shock(ci, age, ppm)
	ci.draw_set_transform(Vector2.ZERO)
	if age >= 0:
		SlamDebris.draw(ci, spot, age * SimClock.TICK_DT, ppm, dump_tick)


## The dust sits UNDER the crack (drawn first) and the dump's ring is light and fades fast, so the
## crack's rim reads all round from D+2 (n31 ghost 09: it was alpha 0.9 over the crack).
func _dust(ci: CanvasItem, tick: int, ppm: float) -> void:
	var arrive: int = tick - press_tick - LAND_TICKS
	if arrive >= 0 and arrive < ARRIVE_DUST_TICKS:
		var k: float = float(arrive) / ARRIVE_DUST_TICKS
		var outer: float = lerpf(1.2, 2.8, 1.0 - pow(1.0 - k, 2.0)) * ppm
		_decal(ci, DUST, outer / DUST_OUTER_PX, 0.85 * (1.0 - k), _turn)
	var age: int = tick - dump_tick
	if age >= 0 and age < DUMP_DUST_TICKS:
		var k2: float = float(age) / DUMP_DUST_TICKS
		var outer2: float = lerpf(0.8, 1.0, 1.0 - pow(1.0 - k2, 3.0)) * radius_m * ppm
		_decal(ci, DUST, outer2 / DUST_OUTER_PX, DUMP_DUST_PEAK * pow(1.0 - k2, 2.0), -_turn)


func _shadow(ci: CanvasItem, since: int, ppm: float) -> void:
	if since < 0 or since > LAND_TICKS:
		return
	var k: float = float(since) / LAND_TICKS
	ci.draw_circle(Vector2.ZERO, lerpf(0.4, 1.5, k * k) * ppm, Color(INK, lerpf(0.12, 0.42, k)))


## The crack art at its full size (tips on radius_m), shown only inside the front's circle.
func _crack(ci: CanvasItem, front_px: float, s: float, fade: float) -> void:
	if front_px <= 1.0 or fade <= 0.0:
		return
	var size: Vector2 = CRACK.get_size()
	var pts: PackedVector2Array = PackedVector2Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	for i: int in VERTS:
		var off: Vector2 = Vector2.from_angle(TAU * i / VERTS) * front_px
		@warning_ignore("return_value_discarded")
		pts.push_back(off)
		@warning_ignore("return_value_discarded")
		uvs.push_back(Vector2(0.5, 0.5) + off.rotated(-_turn) / s / size)
	ci.draw_colored_polygon(pts, Color(1.0, 1.0, 1.0, fade), uvs, CRACK)


func _decal(ci: CanvasItem, tex: Texture2D, s: float, alpha: float, turn: float) -> void:
	if alpha <= 0.0:
		return
	var size: Vector2 = tex.get_size() * s
	var rot: Transform2D = Transform2D(turn, Vector2.ZERO)
	ci.draw_set_transform_matrix(Transform2D(0.0, spot) * rot)
	ci.draw_texture_rect(tex, Rect2(-size * 0.5, size), false, Color(1.0, 1.0, 1.0, alpha))
	ci.draw_set_transform(spot)


## An ink ring out to radius_m over SHOCK_REACH_TICKS (cubic ease-out), held there fading.
func _shock(ci: CanvasItem, age: int, ppm: float) -> void:
	var k: float = clampf(float(age) / SHOCK_REACH_TICKS, 0.0, 1.0)
	var r: float = radius_m * ppm * (1.0 - pow(1.0 - k, 3.0))
	var fade: float = 1.0 - float(age) / SHOCK_TICKS
	var zoom: float = maxf(0.01, ci.get_canvas_transform().x.length())
	var width: float = lerpf(7.0, 2.5, float(age) / SHOCK_TICKS) / zoom
	var mid: float = maxf(1.0, r - width * 0.5)
	ci.draw_arc(Vector2.ZERO, mid, 0.0, TAU, 96, Color(INK, fade), width, true)
