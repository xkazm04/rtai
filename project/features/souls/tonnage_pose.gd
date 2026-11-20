class_name TonnagePose
extends RefCounted
## Body-space metres. The flight mount supplies gross motion; the upper body leads the arms.

enum Pose { CARRY, CRUISE, ARMED, RECOIL }
enum Act { RAISE, POUND, LIFT }

## CRUISE / RECOIL opaque bounds (alpha >= 0.5), south to north, p70 then p55.
const RECOIL_FIT: Array[Vector2] = [
	Vector2(1.0419, 1.2229),
	Vector2(1.0236, 1.2151),
	Vector2(0.8873, 1.1742),
	Vector2(0.8905, 1.2473),
	Vector2(0.9682, 1.3275),
	Vector2(1.0046, 1.1345),
	Vector2(0.9727, 1.1397),
	Vector2(0.8694, 1.1576),
	Vector2(0.8727, 1.1958),
	Vector2(0.9004, 1.2816),
]
const CHEST_H: float = 1.55
const BACK_X: float = -0.55
const CARRY: Vector3 = Vector3(1.0, 0.8, 1.4)
const ARM_FROM_MPS: float = 2.4
const ARM_FULL_MPS: float = 3.0
const RETURN_TICKS: int = 20


class Sample:
	var velocity: Vector2
	var facing: float
	var windup: float
	var stomp_age: int = -1
	var hurt_age: int = -1
	var ram_hits: int
	var ramming: bool
	var bob_m: float


var torso: Vector3 = Vector3(BACK_X, 0.0, CHEST_H)
var pitch: float = 0.0
var left: Vector3 = Vector3(CARRY.x, -CARRY.y, CARRY.z)
var right: Vector3 = CARRY
var act: bool = false
var column: int = Pose.CARRY
var armed_k: float = 0.0
var lean_k: float = 1.0
var plant_k: float = 0.0
var fist_shadow_k: float = 0.0
var press_ahead_m: float
var _follow: Vector2
var _rate: Vector2
var _fist_follow: Vector3
var _cut_ticks: int
var _follow_ticks: int
var _hit_ticks: int
var _hits: int = 0
var _punch_age: int = 14


func _init(ahead_m: float, cut_ticks: int, follow_ticks: int, hit_ticks: int) -> void:
	_cut_ticks = cut_ticks
	_follow_ticks = follow_ticks
	_hit_ticks = hit_ticks
	press_ahead_m = ahead_m


## Ages identify events relative to the last tick in the batch. Zero steps hold the pose.
func step(sample: Sample, ticks: int) -> void:
	for i: int in ticks:
		var before: int = ticks - 1 - i
		var stomp: int = sample.stomp_age - before
		var hurt: int = sample.hurt_age - before
		_fly(sample)
		if sample.ram_hits > _hits:
			_punch_age = 0
		_hits = sample.ram_hits
		_punch_age = mini(_punch_age + 1, 14)
		_travel(sample, hurt)
		_slam(sample.windup, stomp)


static func recoil_fit(row: int, art: String) -> Vector2:
	return RECOIL_FIT[row + (GhostDrawn.ROWS if art == "p55" else 0)]


func landing(side: float) -> Vector3:
	return Vector3(press_ahead_m + 0.3, side * 0.7, 0.0)


func _fly(sample: Sample) -> void:
	var v: Vector2 = sample.velocity.rotated(-sample.facing)
	# Exact critically damped response with ten ticks' mean delay.
	var omega: float = 2.0 / (10.0 * SimClock.TICK_DT)
	var dt: float = SimClock.TICK_DT
	var target: Vector2 = v.limit_length(5.0) * 0.055
	var error: Vector2 = _follow - target
	var change: Vector2 = _rate + omega * error
	_follow = target + (error + change * dt) * exp(-omega * dt)
	_rate = (_rate - omega * change * dt) * exp(-omega * dt)
	torso = Vector3(BACK_X + _follow.x, _follow.y, CHEST_H + sample.bob_m)
	pitch = _follow.x * 0.55
	var trail: Vector3 = Vector3(-_follow.x * 1.6, -_follow.y, sample.bob_m)
	_fist_follow = _fist_follow.lerp(trail, 1.0 - exp(-1.0 / 6.0))


func _travel(sample: Sample, hurt: int) -> void:
	act = false
	plant_k = 0.0
	var speed: float = sample.velocity.length()
	armed_k = 1.0 if sample.ramming else smoothstep(ARM_FROM_MPS, ARM_FULL_MPS, speed)
	lean_k = 1.0 - armed_k
	column = Pose.CRUISE if speed > 1.5 else Pose.CARRY
	if armed_k > 0.5:
		column = Pose.ARMED
	elif hurt >= 0 and hurt < _hit_ticks:
		column = Pose.RECOIL
	left = Vector3(CARRY.x, -CARRY.y, CARRY.z) + _fist_follow
	right = CARRY + _fist_follow
	left = left.lerp(Vector3(-0.25, -1.05, 1.45), armed_k)
	right = right.lerp(Vector3(1.2, 0.25, 1.1), armed_k)
	var punch: float = minf(_punch_age / 4.0, (14 - _punch_age) / 10.0)
	right.x += 0.6 * punch


func _slam(windup: float, age: int) -> void:
	if windup > 0.0:
		fist_shadow_k = smoothstep(0.0, 0.25, windup)
		act = true
		column = Act.RAISE
		lean_k *= 1.0 - smoothstep(0.0, 0.5, windup)
		var k: float = smoothstep(0.0, 1.0, windup)
		left = left.lerp(Vector3(0.95, -1.5, 2.6), k)
		right = right.lerp(Vector3(0.95, 1.5, 2.6), k)
		return
	var lift_end: int = _cut_ticks + _follow_ticks
	fist_shadow_k = 1.0 - smoothstep(_cut_ticks, lift_end, age) if age >= 0 else 0.0
	if age < 0 or age >= lift_end + RETURN_TICKS:
		return
	act = age < lift_end
	var lift: float = 0.0
	plant_k = 1.0
	if age < _cut_ticks:
		column = Act.POUND
	elif act:
		column = Act.LIFT
		lift = lerpf(0.21, 0.8, smoothstep(0.0, _follow_ticks - 1, age - _cut_ticks))
	else:
		plant_k = 1.0 - smoothstep(0.0, RETURN_TICKS, age - lift_end)
		lift = 0.8
	lean_k *= 1.0 - plant_k
	var hunch: Vector3 = Vector3(BACK_X + press_ahead_m * 0.4, 0.0, CHEST_H - 0.28)
	torso = torso.lerp(hunch, plant_k * (1.0 - lift))
	pitch = lerpf(pitch, 0.24, plant_k * (1.0 - lift))
	left = left.lerp(landing(-1.0) + Vector3.BACK * lift, plant_k)
	right = right.lerp(landing(1.0) + Vector3.BACK * lift, plant_k)
