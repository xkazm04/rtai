class_name GibSim
extends RefCounted
## The flying parts of signature kills (lane brutality) as data: a fixed pool of pieces in metres,
## stepped on the 60 Hz tick (SimClock.TICK_DT) with dice from the caller's RNG stream, so the
## same seed throws the same gibs (SIM-02/05). Each piece flies with a height (z, metres) under
## comic gravity, bounces off the street, then slides to rest while its spin dies. The pool is a
## ring: a new kill reuses the oldest slots, which is the leftover budget. No nodes (SIM-03).

const CAPACITY: int = 72
const GRAVITY: float = 24.0
const LAND_VZ: float = 1.2
const AIR_SPIN_KEEP: float = 0.6
## Piece mass feel: the torso flies lower and slower than a limb or the head.
## The whole body (blowback) flies as one; its cap pops higher and spins hardest.
## The two halves of a split body slide apart heavily.
const HEAVY: PackedFloat32Array = [0.9, 0.55, 1.0, 1.0, 0.85, 0.85, 1.0, 1.15, 1.0, 1.0]
## Spin per piece: a blown-back body turns slowly, everything else at the row's spin.
const SPIN_K: PackedFloat32Array = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.12, 1.4, 1.0, 1.0]
## A split half leaves along its own side of the cut, carried this much along the blade (the
## default of SignatureKill.split_follow).
const SPLIT_FOLLOW: float = 0.25

var pos: PackedVector2Array = PackedVector2Array()
var vel: PackedVector2Array = PackedVector2Array()
var z: PackedFloat32Array = PackedFloat32Array()
var vz: PackedFloat32Array = PackedFloat32Array()
var ang: PackedFloat32Array = PackedFloat32Array()
var spin: PackedFloat32Array = PackedFloat32Array()
## SignatureKill.PIECE_IDS index of each slot, and the kill serial that threw it (-1 = free).
var piece: PackedInt32Array = PackedInt32Array()
var kill_of: PackedInt32Array = PackedInt32Array()
var bounce: PackedFloat32Array = PackedFloat32Array()
var drag: PackedFloat32Array = PackedFloat32Array()
## Ticks a slot still waits before it flies (the chainsaw's grind holds the halves together).
var wait: PackedInt32Array = PackedInt32Array()
var kills: int = 0
var _next: int = 0


func _init() -> void:
	z = _floats()
	vz = _floats()
	ang = _floats()
	spin = _floats()
	bounce = _floats()
	drag = _floats()
	@warning_ignore("return_value_discarded")
	pos.resize(CAPACITY)
	@warning_ignore("return_value_discarded")
	vel.resize(CAPACITY)
	@warning_ignore("return_value_discarded")
	piece.resize(CAPACITY)
	@warning_ignore("return_value_discarded")
	kill_of.resize(CAPACITY)
	@warning_ignore("return_value_discarded")
	wait.resize(CAPACITY)
	kill_of.fill(-1)


## Throws `row`'s pieces from `at` along `dir` (unit); `offsets` (metres, by piece id) start each
## piece where it sat on the body. Returns the kill serial (the view's key for its visuals).
func throw(
	row: SignatureKill,
	at: Vector2,
	dir: Vector2,
	offsets: PackedVector2Array,
	rng: RandomNumberGenerator
) -> int:
	var serial: int = kills
	kills += 1
	var half: float = deg_to_rad(row.cone_deg) * 0.5
	for p: int in row.pieces:
		var i: int = _next
		_next = (_next + 1) % CAPACITY
		var heavy: float = HEAVY[p]
		var base: Vector2 = dir
		if p >= SignatureKill.HALF_A and p < offsets.size():  # off its side of the cut
			base = offsets[p].normalized() + dir * row.split_follow
		var a: float = base.angle() + rng.randf_range(-half, half)
		var speed: float = rng.randf_range(row.launch_mps.x, row.launch_mps.y) * heavy
		pos[i] = at + (offsets[p] if p < offsets.size() else Vector2.ZERO)
		vel[i] = Vector2.from_angle(a) * speed
		if p == SignatureKill.HAT and row.hat_kick_mps > 0.0:  # off to one side (alternating)
			var side: Vector2 = dir.orthogonal() * (1.0 if serial % 2 == 0 else -1.0)
			vel[i] += (side + dir * 0.5).normalized() * row.hat_kick_mps
		z[i] = 0.6
		vz[i] = rng.randf_range(row.up_mps.x, row.up_mps.y) * heavy
		ang[i] = rng.randf_range(-PI, PI)
		spin[i] = (
			deg_to_rad(rng.randf_range(row.spin_dps.x, row.spin_dps.y)) * _sign(rng) * SPIN_K[p]
		)
		piece[i] = p
		kill_of[i] = serial
		bounce[i] = row.bounce
		drag[i] = row.ground_drag
		wait[i] = row.grind_ticks
	return serial


## One 60 Hz tick for every live piece.
func step() -> void:
	var dt: float = SimClock.TICK_DT
	for i: int in CAPACITY:
		if kill_of[i] < 0:
			continue
		if wait[i] > 0:
			wait[i] -= 1
			continue
		if z[i] > 0.0 or vz[i] > 0.0:
			_fly(i, dt)
		else:
			_slide(i, dt)
		ang[i] += spin[i] * dt


func live(i: int) -> bool:
	return kill_of[i] >= 0


func at_rest(i: int) -> bool:
	return z[i] <= 0.0 and vz[i] == 0.0 and vel[i] == Vector2.ZERO


## The pool's state for the replay hash (positions, heights, angles of live slots).
func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(kills)
	for i: int in CAPACITY:
		if kill_of[i] < 0:
			continue
		out.put_32(kill_of[i])
		out.put_double(pos[i].x)
		out.put_double(pos[i].y)
		out.put_double(z[i])
		out.put_double(ang[i])


func _fly(i: int, dt: float) -> void:
	vz[i] -= GRAVITY * dt
	z[i] += vz[i] * dt
	pos[i] += vel[i] * dt
	if z[i] > 0.0:
		return
	z[i] = 0.0
	if -vz[i] > LAND_VZ:
		vz[i] = -vz[i] * bounce[i]
		vel[i] *= 0.75
		spin[i] *= AIR_SPIN_KEEP
	else:
		vz[i] = 0.0


func _slide(i: int, dt: float) -> void:
	var v: Vector2 = vel[i]
	var sp: float = v.length()
	var after: float = maxf(0.0, sp - drag[i] * dt)
	vel[i] = v * (after / sp) if sp > 0.0 and after > 0.0 else Vector2.ZERO
	pos[i] += vel[i] * dt
	spin[i] = move_toward(spin[i], 0.0, absf(spin[i]) * 4.0 * dt + 0.2 * dt)


static func _floats() -> PackedFloat32Array:
	var a: PackedFloat32Array = PackedFloat32Array()
	@warning_ignore("return_value_discarded")
	a.resize(CAPACITY)
	return a


static func _sign(rng: RandomNumberGenerator) -> float:
	return 1.0 if rng.randf() < 0.5 else -1.0
