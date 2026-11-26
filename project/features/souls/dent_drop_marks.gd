class_name DentDropMarks
extends RefCounted
## n31 ghost 18b: the ground under Dent's drop deploy, in tan dust, soot and ink only (never teal,
## red or vermilion). The record outlives the ghost so the scuffed lane can stay.
## P = press tick, R = the ram tick (P + the row's charge ticks); the lane runs origin -> spot:
## - arrival P..P+3: a small launch puff at the origin, billowing backward;
## - wind-up P+4..R-1: the skid (art/dent_lane_skid.png) revealed origin -> spot, ease-out, whole
##   by R-6 (the dive's start), its two scrape lines on the lane's edges (2 x ram_half_m apart), and
##   the cap's arcs converging on the spot: the telegraph (foes can step out);
## - dive R-6..R+1: the dust wake from the launch point to the diving body (DentDropBeats.dive,
##   at the spot on R), a bigger launch puff at the origin from R-6;
## - stop R..: the stop scuff's heel under the spot, its gouges trailing back to the origin;
## - aftermath R..: the scuffed lane replaces the skid, holds 2 s and fades 1 s.

const SKID: Texture2D = preload("res://features/souls/art/dent_lane_skid.png")
const SCUFF: Texture2D = preload("res://features/souls/art/dent_lane_scuff.png")
const WAKE: Texture2D = preload("res://features/souls/art/dent_wake.png")
const CAP: Texture2D = preload("res://features/souls/art/dent_lane_cap.png")
const STOP: Texture2D = preload("res://features/souls/art/dent_stop_scuff.png")
const PUFF: Texture2D = preload("res://features/souls/art/dent_launch_puff.png")
## Art bands (x from, y from, width, height in px) drawn across the lane's 2 x ram_half_m: the
## skid's two scrape lines (y 117 and 206), the scuff's and the wake's opaque extents.
const SKID_BAND: Rect2 = Rect2(0.0, 117.0, 1024.0, 89.0)
const SCUFF_BAND: Rect2 = Rect2(0.0, 47.0, 1024.0, 225.0)
const WAKE_BAND: Rect2 = Rect2(134.0, 0.0, 755.0, 320.0)
## The cap's arc tips and the stop scuff's heel in their 512 px art: both pinned on the spot.
const CAP_TIP: Vector2 = Vector2(512.0, 294.0)
const STOP_HEEL: Vector2 = Vector2(472.0, 262.0)
## The launch puff's back edge of its small cloud, pinned on the origin (the big cloud behind).
const PUFF_PIN: Vector2 = Vector2(400.0, 256.0)
const CAP_M: float = 2.0
const STOP_M: float = 2.2
const PUFF_M: float = 1.0
const RAM_PUFF_M: float = 1.4
const WAKE_WIDTH: float = 0.8
const ARRIVE_TICKS: int = 4
const SKID_LEAD_TICKS: int = DentDropBeats.DIVE_TICKS
## The wake and the launch puff: the dive plus two ticks of settling dust (R-6..R+1).
const WAKE_TICKS: int = DentDropBeats.DIVE_TICKS + 2
const CAP_IN_TICKS: int = 4
const STOP_IN_TICKS: int = 3
const HOLD_TICKS: int = 120
const FADE_TICKS: int = 60

var origin: Vector2
var spot: Vector2
var press_tick: int
var ram_tick: int
var half_m: float
var _frame: Transform2D


## `from` and `to` in metres: the lane's origin (Rivet's side) and the spot.
func _init(from: Vector2, to: Vector2, press: int, ram: int, half: float) -> void:
	origin = from
	spot = to
	press_tick = press
	ram_tick = ram
	half_m = half


func length_m() -> float:
	return origin.distance_to(spot)


func live(tick: int) -> bool:
	return tick < ram_tick + HOLD_TICKS + FADE_TICKS


## The skid's front (metres from the origin): 0 before P+4, ease-out to the spot by R-6.
func skid_m(tick: int) -> float:
	var start: int = press_tick + ARRIVE_TICKS
	var span: int = ram_tick - SKID_LEAD_TICKS - start + 1
	if tick < start:
		return 0.0
	var t: float = clampf(float(tick - start + 1) / maxi(span, 1), 0.0, 1.0)
	return length_m() * (1.0 - (1.0 - t) * (1.0 - t))


## The scuffed lane's opacity: whole from R until R + HOLD_TICKS, gone over FADE_TICKS.
func ground_alpha(tick: int) -> float:
	var age: int = tick - ram_tick
	if age < 0:
		return 0.0
	return 1.0 - clampf(float(age - HOLD_TICKS) / FADE_TICKS, 0.0, 1.0)


func draw(ci: CanvasItem, tick: int, ppm: float) -> void:
	var struck: int = tick - ram_tick
	var lane: float = length_m() * ppm
	var width: float = 2.0 * half_m * ppm
	_frame = Transform2D(origin.angle_to_point(spot), origin * ppm)
	ci.draw_set_transform_matrix(_frame)
	var scuff: float = ground_alpha(tick)
	_strip(ci, SCUFF, SCUFF_BAND, Rect2(0.0, -width * 0.5, lane, width), scuff)
	if struck >= 0:
		var rise: float = clampf(float(struck + 1) / STOP_IN_TICKS, 0, 1)
		_decal(ci, STOP, _pin(STOP_HEEL, lane, STOP_M * ppm), scuff * rise)
	if struck < 0:
		_telegraph(ci, tick, ppm)
	var dove: int = struck + DentDropBeats.DIVE_TICKS
	if dove >= 0 and dove < WAKE_TICKS:
		_wake(ci, struck, ppm, width)
	_puffs(ci, tick, ppm)
	ci.draw_set_transform(Vector2.ZERO)


## The skid revealed up to its front and the cap at the spot (the wind-up's telegraph).
func _telegraph(ci: CanvasItem, tick: int, ppm: float) -> void:
	var lane: float = length_m() * ppm
	var width: float = 2.0 * half_m * ppm
	var k: float = skid_m(tick) / maxf(length_m(), 0.001)
	if k <= 0.0:
		return
	var src: Rect2 = Rect2(SKID_BAND.position, Vector2(SKID_BAND.size.x * k, SKID_BAND.size.y))
	_strip(ci, SKID, src, Rect2(0.0, -width * 0.5, lane * k, width), 1.0)
	var cap: float = clampf(float(tick - press_tick - ARRIVE_TICKS + 1) / CAP_IN_TICKS, 0, 1)
	_decal(ci, CAP, _pin(CAP_TIP, lane, CAP_M * ppm), cap)


## The dust wake from the launch point to the diving body, thinning as he stops.
func _wake(ci: CanvasItem, struck: int, ppm: float, width: float) -> void:
	var head: Vector2 = DentDropBeats.dive(origin, spot, struck)
	var from: float = -DentDropBeats.RECOIL_M * ppm
	var to: float = origin.distance_to(head) * ppm
	if to - from <= 1.0:
		return
	var w: float = width * WAKE_WIDTH
	var fade: float = 1.0 - float(struck + DentDropBeats.DIVE_TICKS) / (WAKE_TICKS + 2)
	_strip(ci, WAKE, WAKE_BAND, Rect2(from, -w * 0.5, to - from, w), fade)


## The small puff on arrival (P..P+3) and the bigger one on the launch (R-6..R+1).
func _puffs(ci: CanvasItem, tick: int, ppm: float) -> void:
	var at: float = -DentDropBeats.RECOIL_M * ppm
	var since: int = tick - press_tick
	if since >= 0 and since < ARRIVE_TICKS:
		var k: float = float(since) / ARRIVE_TICKS
		_decal(ci, PUFF, _pin(PUFF_PIN, at, PUFF_M * ppm * (0.7 + 0.3 * k)), 1.0 - k * k)
	var dove: int = tick - ram_tick + DentDropBeats.DIVE_TICKS
	if dove >= 0 and dove < WAKE_TICKS:
		var u: float = float(dove) / WAKE_TICKS
		_decal(ci, PUFF, _pin(PUFF_PIN, at, RAM_PUFF_M * ppm * (0.8 + 0.4 * u)), 1.0 - u * u)


## A strip lying along +x: `src`'s y band spans `dst`'s y band, its x span `dst`'s x span.
func _strip(ci: CanvasItem, tex: Texture2D, src: Rect2, dst: Rect2, alpha: float) -> void:
	if alpha <= 0.0 or dst.size.x <= 0.0 or src.size.x <= 0.0:
		return
	var sy: float = dst.size.y / src.size.y
	var h: float = tex.get_height()
	var rect: Rect2 = Rect2(
		dst.position.x, dst.position.y - src.position.y * sy, dst.size.x, h * sy
	)
	var region: Rect2 = Rect2(src.position.x, 0.0, src.size.x, h)
	ci.draw_texture_rect_region(tex, rect, region, Color(1.0, 1.0, 1.0, alpha))


## Art px -> lane px: `pin` (art px) lands at `at_x` on the lane line, the art `long_px` wide.
func _pin(pin: Vector2, at_x: float, long_px: float) -> Transform2D:
	var s: float = long_px / 512.0
	return Transform2D(0.0, Vector2(s, s), 0.0, Vector2(at_x, 0.0) - pin * s)


func _decal(ci: CanvasItem, tex: Texture2D, place: Transform2D, alpha: float) -> void:
	if alpha <= 0.0:
		return
	ci.draw_set_transform_matrix(_frame * place)
	ci.draw_texture(tex, Vector2.ZERO, Color(1.0, 1.0, 1.0, alpha))
	ci.draw_set_transform_matrix(_frame)
