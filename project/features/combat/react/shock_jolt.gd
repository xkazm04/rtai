class_name ShockJolt
extends RefCounted
## The electro convulsion (owner note 2026-11-04: "improve character reaction on electro gun"),
## render only. The old one was smooth sines, a shiver that read as a daze at 32 px/m. This one
## holds a pose for a few frames and then jumps: each channel (body, torso, each arm's envelope,
## head, hat) on its own step rate, so the limbs jolt off each other's rhythm. Hash noise of the
## actor's phase and the family's clock: no RNG, a replay draws the same jolts.

## Steps per second of each channel (body x, body y, torso, hands up, reach, head, head x,
## head y, hat). Primes apart so they never line up.
const RATES: PackedFloat32Array = [17.0, 13.0, 11.0, 9.0, 7.0, 15.0, 19.0, 23.0, 21.0]
## The body jolt as a multiple of the family's travel_m, the torso twist and head turn (rad),
## the head's throw (part px) and the hat's pop (head scale).
const BODY_K: float = 2.2
const TWIST_RAD: float = 0.6
const HEAD_RAD: float = 0.8
const HEAD_PX: float = 45.0
const HAT_POP: float = 0.25
## The crawling arcs: how many, how far from the body centre they start (m), how long (m), their
## kinks and how far a kink jumps off the line (m).
const ARCS: int = 3
const BODY_M: float = 0.2
const ARC_M: float = 0.26
const KINKS: int = 4
const WOBBLE_M: float = 0.07
## The spits: short arcs from the body's edge outward past its silhouette, so a 20 px body at
## 32 px/m reads as live (the crawling arcs alone stayed inside it). Count, start and end (m).
const SPITS: int = 3
const SPIT_IN_M: float = 0.16
const SPIT_OUT_M: float = 0.5

## False (`--soft-shock`): the old smooth shiver and no crawling arcs (the A/B's before).
static var hard: bool = not OS.get_cmdline_user_args().has("--soft-shock")


## Channel `ch` at time `t` (s) for phase `phase`: a value in [-1, 1] held for 1/RATES[ch] s.
static func step(t: float, phase: float, ch: int) -> float:
	var n: float = floorf(t * RATES[ch])
	return (
		fposmod(sin(n * 12.9898 + phase * 78.233 + float(ch) * 37.719) * 43758.5453, 1.0) * 2.0
		- 1.0
	)


## The hard convulsion on `r` / `rig`, `env` its strength (0 = none).
static func pose(r: HumanReact, rig: CutRig, env: float) -> void:
	var t: float = r.t
	var p: float = r.phase
	r.off = Vector2(step(t, p, 0), step(t, p, 1)) * r.travel * BODY_K * env
	rig.twist = step(t, p, 2) * TWIST_RAD * env
	rig.c_hands_up = maxf(rig.c_hands_up, (0.55 + 0.45 * step(t, p, 3)) * env)
	rig.c_reach = maxf(rig.c_reach, (0.5 + 0.5 * step(t, p, 4)) * env)
	r.head_rot = step(t, p, 5) * HEAD_RAD * env
	r.head_off = Vector2(step(t, p, 6), step(t, p, 7)) * HEAD_PX * env
	r.head_s = 1.0 + HAT_POP * maxf(0.0, step(t, p, 8)) * env
	rig.gun_out = false


## Arcs crawling over a stunned body centred at `at` (px, `ppm` px per metre): ARCS short cream
## sparks in an ink rim between hashed points on the body, re-picked every other tick so they
## crawl. ShockArcsView draws them over the rigs. View only.
static func arcs(ci: CanvasItem, at: Vector2, ppm: float, tick: int) -> void:
	if not hard:
		return
	var n: int = tick / 2
	for i: int in ARCS:
		var a: Vector2 = Vector2(_u(n, i * 4), _u(n, i * 4 + 1)) * BODY_M
		var d: Vector2 = Vector2.from_angle(PI * _u(n, i * 4 + 2))
		var nrm: Vector2 = d.orthogonal()
		var pts: PackedVector2Array = PackedVector2Array()
		for k: int in KINKS + 1:
			var edge: bool = k == 0 or k == KINKS
			var w: float = 0.0 if edge else _u(n + k, i * 9 + k) * WOBBLE_M
			@warning_ignore("return_value_discarded")
			pts.append(at + (a + d * ARC_M * float(k) / float(KINKS) + nrm * w) * ppm)
		_spark(ci, pts)
	for j: int in SPITS:
		_spark(ci, spit(at, ppm, n, j))


## Spit `j` of arc frame `n`: a kinked line from SPIT_IN_M to SPIT_OUT_M off the body centre,
## its direction re-picked with the frame (px).
static func spit(at: Vector2, ppm: float, n: int, j: int) -> PackedVector2Array:
	var d: Vector2 = Vector2.from_angle(PI * _u(n, 60 + j * 3))
	var pts: PackedVector2Array = PackedVector2Array()
	for k: int in KINKS + 1:
		var r: float = lerpf(SPIT_IN_M, SPIT_OUT_M, float(k) / float(KINKS))
		var w: float = 0.0 if k == 0 else _u(n + k, 61 + j * 3) * WOBBLE_M
		@warning_ignore("return_value_discarded")
		pts.append(at + (d * r + d.orthogonal() * w) * ppm)
	return pts


static func _spark(ci: CanvasItem, pts: PackedVector2Array) -> void:
	ci.draw_polyline(pts, Ink.INK, 6.0, true)
	ci.draw_polyline(pts, Ink.CREAM, 2.5, true)


static func _u(a: int, b: int) -> float:
	return fposmod(sin(float(a) * 12.9898 + float(b) * 78.233) * 43758.5453, 1.0) * 2.0 - 1.0
