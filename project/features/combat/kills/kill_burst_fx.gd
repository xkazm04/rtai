class_name KillBurstFx
extends Node2D
## The homing shard kill (lane brutality, signature style `burst`), render only: while the body
## stands frozen on the hold (row hitstop + grind ticks), cream shards in an ink rim stick out of
## its far side (driven through, clear of Rivet's claws) and tremble harder toward the pop; at
## the pop a red mist puff swells and thins over the parts flying off. Ticks against the sim
## tick, shapes from a hash of the serial, no dice, so a replay shows the same frames.

const SHARD: Color = Color("#F4E3B5")
const MIST: Color = Color(0.72, 0.06, 0.08, 0.55)
const SHARDS: int = 5
## The butts of the shards on the near side (the entry: short cream stubs back toward the shooter).
const BUTTS: int = 3
const MIST_TICKS: int = 26


class Burst:
	extends RefCounted
	var serial: int = 0
	var at: Vector2 = Vector2.ZERO
	var dir: Vector2 = Vector2.RIGHT
	var born: int = 0
	var hold: int = 0


var kills: SignatureKills = null
var ppm: float = 32.0
var reduced_motion: bool = false
var _bursts: Array[Burst] = []


func bind(p_kills: SignatureKills, p_ppm: float, p_reduced_motion: bool) -> void:
	kills = p_kills
	ppm = p_ppm
	reduced_motion = p_reduced_motion
	@warning_ignore("return_value_discarded")
	kills.killed.connect(_on_killed)


func _on_killed(_victim: int, serial: int, row: SignatureKill, at: Vector2, dir: Vector2) -> void:
	if row.style != &"burst":
		return
	var b: Burst = Burst.new()
	b.serial = serial
	b.at = at
	b.dir = dir.normalized() if dir != Vector2.ZERO else Vector2.RIGHT
	b.born = kills.tick
	b.hold = row.hitstop_ticks + row.grind_ticks
	@warning_ignore("return_value_discarded")
	_bursts.append(b)


func _process(_delta: float) -> void:
	if kills == null or _bursts.is_empty():
		return
	_bursts = _bursts.filter(
		func(b: Burst) -> bool: return kills.tick - b.born <= b.hold + MIST_TICKS
	)
	queue_redraw()


func _draw() -> void:
	for b: Burst in _bursts:
		var age: int = kills.tick - b.born
		if age < b.hold:
			_shards(b, age)
		else:
			_mist(b, float(age - b.hold) / MIST_TICKS)


## Shards driven through the body, fanned out of its far side along the shot, their butts
## standing out of the near side.
func _shards(b: Burst, age: int) -> void:
	var c: Vector2 = b.at * ppm
	var k: float = float(age) / maxf(1.0, float(b.hold))
	for n: int in SHARDS:
		var side: float = (float(n) + 0.3 * _h(b.serial, n)) / float(SHARDS) - 0.55  # spread, not bunched
		var depth: float = 0.12 + 0.1 * _h(b.serial, n + 20)
		var base: Vector2 = c + (b.dir.orthogonal() * side * 0.5 + b.dir * depth) * ppm
		var jit: float = 0.0 if reduced_motion else (_h(b.serial, n * 7 + age) - 0.5) * 0.06 * k
		var out: Vector2 = (
			b.dir.rotated(side * 2.2 + jit * 10.0) * (0.4 + 0.18 * _h(b.serial, n + 40))
		)
		_spike(base, out, 0.1)
	for n: int in BUTTS:  # the entry side: short butts standing out back along the shot
		var side: float = (float(n) + 0.5) / float(BUTTS) - 0.5
		var base: Vector2 = c + (b.dir.orthogonal() * side * 0.3 - b.dir * 0.16) * ppm
		var jit: float = 0.0 if reduced_motion else (_h(b.serial, n * 5 + age) - 0.5) * 0.4 * k
		_spike(base, -b.dir.rotated(side * 1.2 + jit) * (0.24 + 0.1 * _h(b.serial, n + 120)), 0.08)


## One shard: a cream spike in an ink rim from `base` out along `out` (metres), `half_w` m wide.
func _spike(base: Vector2, out: Vector2, half_w: float) -> void:
	var tip: Vector2 = base + out * ppm
	var w: Vector2 = out.orthogonal().normalized() * half_w * ppm
	var tri: PackedVector2Array = [base + w, tip, base - w]
	KillPoly.fill(self, tri, SHARD)
	@warning_ignore("return_value_discarded")
	tri.append(tri[0])
	draw_polyline(tri, Ink.INK, 1.2, true)


## The red mist at the pop: a soft blot that swells and thins.
func _mist(b: Burst, t: float) -> void:
	var c: Vector2 = b.at * ppm
	var r: float = (0.35 + 0.9 * t) * ppm
	var a: float = MIST.a * (1.0 - t)
	for n: int in 6:
		var o: Vector2 = Vector2.from_angle(TAU * _h(b.serial, n + 60)) * r * 0.4
		draw_circle(c + o, r * (0.55 + 0.3 * _h(b.serial, n + 80)), Color(MIST, a * 0.5))
	draw_circle(c, r * 0.7, Color(MIST, a))


static func _h(a: int, b: int) -> float:
	return fposmod(sin(float(a) * 12.9898 + float(b) * 78.233) * 43758.5453, 1.0)
