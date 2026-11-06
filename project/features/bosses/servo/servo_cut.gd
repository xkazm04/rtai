class_name ServoCut
extends RefCounted
## A drone cut by Kerf (the kill weapon kerf_slice: the blink's target or BossKerfLine's cuts):
## the drone in two halves along the blink, each with Kerf's cauterised soul edge (a teal bloom
## round a white-hot band, KillCutEdge's look), drifting apart as they drop to the yard, then
## lying dark and fading. Every other kill keeps the drone's own fall. Render only (SIM-03): the
## cuts come from CombatArena.kill_landed and are never written to the state.

const WEAPON: StringName = &"kerf_slice"
## Frames from the cut: the halves part and fall (FALL), lie on the yard, then fade by GONE.
const FALL: int = 30
const GONE: int = 90
## How far each half drifts off the line (metres) and how much it turns (radians) as it falls.
const PART_M: float = 0.6
const TURN: float = 0.35
## The cut flash across the whole line (frames, and its length over the drone's width).
const FLASH: int = 8
const FLASH_K: float = 2.4
const BAND: Color = Color(0.9, 1.0, 0.97)

var px: float = 32.0
var cuts: Array[Cut] = []
var _tex: Texture2D = null
var _k: float = 1.0


class Cut:
	var at: Vector2
	var dir: Vector2
	var frame: int


## kill_landed: a drone body (a machine of the swarm, `owns`) killed by Kerf's slice.
func take(at: Vector2, dir: Vector2, frame: int) -> void:
	var x: Cut = Cut.new()
	x.at = at
	x.dir = dir.normalized() if dir.length() > 0.01 else Vector2.RIGHT
	x.frame = frame
	cuts.append(x)


## The cut halves at `frame`: the drone texture `tex` drawn `k` x its art size (as the swarm's).
func draw(c: CanvasItem, tex: Texture2D, k: float, frame: int) -> void:
	_tex = tex
	_k = k
	cuts = cuts.filter(func(x: Cut) -> bool: return frame - x.frame < GONE)
	if _tex == null:
		return
	for x: Cut in cuts:
		var dt: int = frame - x.frame
		var u: float = minf(float(dt) / FALL, 1.0)
		var fade: float = 1.0 - clampf(float(dt - FALL) / (GONE - FALL), 0.0, 1.0)
		for side: float in [-1.0, 1.0]:
			_half(c, x, side, u, fade)
		if dt < FLASH:
			_flash(c, x, 1.0 - float(dt) / FLASH)


## One half: the texture's half on `side` of the cut line (local y), pushed off the line and
## turned as it falls (u 0..1), then fading (fade 1..0).
func _half(c: CanvasItem, x: Cut, side: float, u: float, fade: float) -> void:
	var ease_u: float = 1.0 - (1.0 - u) * (1.0 - u)
	var off: Vector2 = Vector2(0.0, side).rotated(x.dir.angle()) * PART_M * ease_u
	var s: float = _k * px / ServoRig.ART_PPM * (1.0 - 0.18 * ease_u)  # the drop: smaller
	var size: Vector2 = _tex.get_size()
	var half: Rect2 = Rect2(
		-size.x * 0.5, 0.0 if side > 0.0 else -size.y * 0.5, size.x, size.y * 0.5
	)
	var dark: Color = Color.WHITE.lerp(Color(0.25, 0.24, 0.22), u)
	c.draw_set_transform((x.at + off) * px, x.dir.angle() + side * TURN * ease_u, Vector2.ONE * s)
	var src: Rect2 = Rect2(half.position + size * 0.5, half.size)
	c.draw_texture_rect_region(_tex, half, src, Color(dark, fade))
	var hot: float = (1.0 - u) * fade  # the cauterised edge cools as the half lands
	if hot > 0.0:
		var w: float = size.y * 0.1
		var lip: float = side * w * 0.5
		var a: Vector2 = Vector2(-size.x * 0.45, lip)
		var b: Vector2 = Vector2(size.x * 0.45, lip)
		c.draw_line(a, b, Color(HaulerLook.TEAL, 0.5 * hot), w * 2.6)
		c.draw_line(a * 0.93, b * 0.93, Color(BAND, hot), w)
	c.draw_set_transform(Vector2.ZERO)


## The slice itself for FLASH frames: a white-hot line in a teal bloom across the drone and past it.
func _flash(c: CanvasItem, x: Cut, a: float) -> void:
	var half_l: float = _tex.get_size().x * _k / ServoRig.ART_PPM * FLASH_K * 0.5 * px
	var p: Vector2 = x.at * px
	var d: Vector2 = x.dir * half_l
	c.draw_line(p - d, p + d, Color(HaulerLook.TEAL, 0.55 * a), 0.22 * px)
	c.draw_line(p - d, p + d, Color(BAND, a), 0.07 * px)
