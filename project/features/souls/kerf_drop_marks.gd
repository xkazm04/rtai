class_name KerfDropMarks
extends RefCounted
## n31 ghost 22: the ground a landed Kerf drop cut leaves, in ink, soot, charcoal and tan with a
## flat amber heat thread (never teal, red or vermilion). C = the cut tick. Laid only by a cut
## that hit (a whiff leaves nothing); the record outlives the ghost, as Ohm's scorch does:
## - the cut scorch: a 2.6 m x 0.8 m char seam along the cut line (KerfView.CUT_DEG across his
##   facing), centred on the target's position at C, whole from C, held 2 s and faded 1 s;
## - the spatter: molten drops 1.8 m across thrown along the cut line, C..C+11 only;
## - the rear scorch: a 1.4 m scorched star where he landed behind the target, held with the seam.

const SCORCH: Texture2D = preload("res://features/souls/art/kerf_cut_scorch.png")
const SPATTER: Texture2D = preload("res://features/souls/art/kerf_cut_spatter.png")
const REAR: Texture2D = preload("res://features/souls/art/kerf_rear_scorch.png")
const SCORCH_LONG_M: float = 2.6
const SCORCH_WIDE_M: float = 0.8
## The seam's band in its 1024x320 strip (the char seam rows 130-189 and its thrown specks):
## this band spans SCORCH_WIDE_M across the line, so the seam reads at play zoom.
const SCORCH_BAND: Vector2 = Vector2(100.0, 220.0)
const SPATTER_M: float = 1.8
const REAR_M: float = 1.4
const SPATTER_TICKS: int = 12
const HOLD_TICKS: int = 120
const FADE_TICKS: int = 60

## The target's position at C, the cut line's unit direction and the rear spot, in metres.
var at: Vector2
var dir: Vector2
var rear: Vector2
var cut_tick: int


func _init(target: Vector2, line: Vector2, behind: Vector2, cut: int) -> void:
	at = target
	dir = line.normalized() if line != Vector2.ZERO else Vector2.RIGHT
	rear = behind
	cut_tick = cut


func live(tick: int) -> bool:
	return tick < cut_tick + HOLD_TICKS + FADE_TICKS


## The scorches' opacity: whole from C until C + HOLD_TICKS, gone over FADE_TICKS.
func ground_alpha(tick: int) -> float:
	var age: int = tick - cut_tick
	if age < 0:
		return 0.0
	return 1.0 - clampf(float(age - HOLD_TICKS) / FADE_TICKS, 0.0, 1.0)


## The spatter's opacity: thrown on C, gone at C + SPATTER_TICKS (eases out).
func spatter_alpha(tick: int) -> float:
	var age: int = tick - cut_tick
	if age < 0 or age >= SPATTER_TICKS:
		return 0.0
	var u: float = float(age) / SPATTER_TICKS
	return 1.0 - u * u


func draw(ci: CanvasItem, tick: int, ppm: float) -> void:
	var ground: float = ground_alpha(tick)
	if ground > 0.0:
		var heel: Transform2D = Transform2D(dir.angle(), rear * ppm)
		_decal(ci, REAR, heel, REAR_M * ppm, ground)
		var seam: Transform2D = Transform2D(dir.angle(), at * ppm)
		ci.draw_set_transform_matrix(seam)
		var sy: float = SCORCH_WIDE_M * ppm / (SCORCH_BAND.y - SCORCH_BAND.x)
		var long_px: float = SCORCH_LONG_M * ppm
		var top: float = -SCORCH_WIDE_M * ppm * 0.5 - SCORCH_BAND.x * sy
		var rect: Rect2 = Rect2(-long_px * 0.5, top, long_px, SCORCH.get_height() * sy)
		ci.draw_texture_rect(SCORCH, rect, false, Color(1, 1, 1, ground))
	var spat: float = spatter_alpha(tick)
	if spat > 0.0:
		var grow: float = 0.85 + 0.15 * float(tick - cut_tick) / SPATTER_TICKS
		var thrown: Transform2D = Transform2D(dir.angle(), at * ppm)
		_decal(ci, SPATTER, thrown, SPATTER_M * ppm * grow, spat)
	ci.draw_set_transform(Vector2.ZERO)


## A square decal `long_px` across, centred on `place`'s origin, along its x axis.
func _decal(
	ci: CanvasItem, tex: Texture2D, place: Transform2D, long_px: float, alpha: float
) -> void:
	ci.draw_set_transform_matrix(place)
	var half: float = long_px * 0.5
	ci.draw_texture_rect(tex, Rect2(-half, -half, long_px, long_px), false, Color(1, 1, 1, alpha))
