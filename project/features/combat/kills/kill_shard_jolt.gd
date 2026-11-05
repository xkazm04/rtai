class_name KillShardJolt
extends RefCounted
## The homing shard kill's flinch (owner note 2026-11-04, reel chapter 14: "reacts with delay"),
## render only. The burst row holds the cut body for hitstop + grind ticks (0.65 s) before the
## pop; held frozen, the victim read as reacting late. Now each drawn shard lands on its own tick
## (the first, the killing one, on the kill tick itself) and snaps the body back along the shot:
## the head and the arms thrown hardest and off the beat, the feet planted, each snap leaning the
## other way, then a tremble rising to the pop. A pure function of the age: no RNG, no sim state.

## The ticks after the kill tick the drawn shards land on (shard 0 kills; the gun's 8 Hz is 7.5
## ticks). One entry [0] is a single flinch; SNAP_M 0 is the old frozen hold.
const HITS: PackedInt32Array = [0, 7, 15, 22, 30]
## The first shard's snap back along the shot (metres), and each later shard's share of it.
const SNAP_M: float = 0.2
const LATER_K: float = 0.75
## Ticks to a snap's peak (the landing tick already shows a third of it), then the spring back:
## its decay (ticks) and its swing (radians per tick).
const RISE_TICKS: float = 2.0
const DECAY_TICKS: float = 5.0
const SPRING: float = 0.75
## Per rig part (head, torso, arm_l, arm_r, leg_l, leg_r): how far a snap throws it, and how many
## ticks it trails the torso (the arms flail off the beat; the feet stay planted).
const PART_K: PackedFloat32Array = [1.7, 1.0, 1.5, 1.5, 0.2, 0.2]
const PART_LAG: PackedInt32Array = [0, 0, 1, 2, 0, 0]
## The sideways share of a snap and the lean it adds (radians per part), alternating sides.
const SIDE_K: float = 0.35
const TILT_RAD: float = 0.28
## The tremble toward the pop: metres at the pop, from the last shard on.
const TREMBLE_M: float = 0.035


## Part `piece`'s flinch `age` ticks after the kill tick, in the shot's frame: Vector3(metres back
## along the shot, metres to its left, lean in radians). Zero before the kill tick.
static func at(age: int, piece: int, serial: int) -> Vector3:
	var out: Vector3 = Vector3.ZERO
	for n: int in HITS.size():
		out += hit(age, n, piece, serial)
	return out


## Shard `n`'s own share of part `piece`'s flinch at `age` (zero before it lands).
static func hit(age: int, n: int, piece: int, serial: int) -> Vector3:
	var lag: int = PART_LAG[piece] if piece < PART_LAG.size() else 0
	var a: int = age - HITS[n] - lag
	if a < 0:
		return Vector3.ZERO
	var k: float = PART_K[piece] if piece < PART_K.size() else 1.0
	var amp: float = SNAP_M * k * (1.0 if n == 0 else LATER_K)
	var side: float = 1.0 if (n + serial) % 2 == 0 else -1.0
	var s: float = snap(a)
	var lean: float = TILT_RAD * (1.0 if n == 0 else LATER_K) * side
	return Vector3(s * amp, s * amp * SIDE_K * side, s * lean)


## A snap's shape `a` ticks after it landed: a third on the landing tick, the peak at RISE_TICKS,
## then a damped spring back through rest.
static func snap(a: int) -> float:
	var t: float = float(a)
	if t < RISE_TICKS:
		return (t + 1.0) / (RISE_TICKS + 1.0)
	var d: float = t - RISE_TICKS
	return exp(-d / DECAY_TICKS) * cos(d * SPRING)


## The tremble (metres) of part `piece` at `age` of a `hold`-tick hold: none until the last shard
## landed, then growing to TREMBLE_M at the pop. Hash noise, no dice.
static func tremble(age: int, hold: int, piece: int, serial: int) -> Vector2:
	var last: int = HITS[HITS.size() - 1]
	if age <= last or hold <= last:
		return Vector2.ZERO
	var k: float = clampf(float(age - last) / float(hold - last), 0.0, 1.0) * TREMBLE_M
	var hx: float = _h(serial * 31 + piece, age) - 0.5
	var hy: float = _h(serial * 17 + piece, age + 400) - 0.5
	return Vector2(hx, hy) * 2.0 * k


## The first tick in [0, hold) on which `f` (Callable(age: int) -> Vector3) moves, or -1. The
## timing test reads every shard's own share through it.
static func first_motion(f: Callable, hold: int) -> int:
	for age: int in hold:
		var v: Vector3 = f.call(age)
		if v != Vector3.ZERO:
			return age
	return -1


static func _h(a: int, b: int) -> float:
	return fposmod(sin(float(a) * 12.9898 + float(b) * 78.233) * 43758.5453, 1.0)
