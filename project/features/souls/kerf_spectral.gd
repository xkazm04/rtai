class_name KerfSpectral
extends Node2D
## The flight mount carries the body. Sighting, recoil and the blink overshoot are visual offsets.

const LUNGE_TICKS: int = 8
const TUCK_TICKS: int = 4
const TURN_HOLD_TICKS: int = 5
const AIM_LIMIT: float = deg_to_rad(25.0)
const AIM_TICKS: int = 4

var reduced_motion: bool = LaunchArgs.has("--reduced-motion")
var current: KerfRoninDrawn.Pose = KerfRoninDrawn.Pose.HOVER
var _top: KerfRoninTop = KerfRoninTop.new()
var _last_tick: int = -1
var _turn_tick: int = -TURN_HOLD_TICKS
var _turn_rate: float = 0.0
var _tilted: KerfRoninDrawn = KerfRoninDrawn.new()
var _echoes: KerfEcho
var _yaw: float = 0.0
var _yaw_start: float = 0.0
var _yaw_goal: float = 0.0
var _aim_tick: int = 0
var _sight_enabled: bool = HitFeel.feel_flag() != "off"
var _hit: KerfHit = KerfHit.new()


static func blink_pose(age: int, sliced: bool) -> KerfRoninDrawn.Pose:
	if age >= 0 and age < LUNGE_TICKS:
		return KerfRoninDrawn.Pose.CUT if sliced else KerfRoninDrawn.Pose.BLINK
	if sliced and age >= LUNGE_TICKS and age < 2 * LUNGE_TICKS:
		return KerfRoninDrawn.Pose.RECOVER
	return KerfRoninDrawn.Pose.HOVER


func _ready() -> void:
	add_child(_top)
	add_child(_tilted)


func live(stage: CollectCallStage, rig: KerfRig) -> void:
	var k: KerfStage = stage.pilot.kerf
	var since: int = -1 if k.trail_tick.is_empty() else stage.tick - k.trail_tick[-1]
	var sliced: bool = since >= 0 and k.trail_cut[-1] != Vector2.INF
	var facing: float = rig.global_rotation
	var target: Fighter
	if _sight_enabled and k.on() and k.charges > 0 and k.num(&"sight_k") > 0.0:
		if stage.pilot.ghosts.settled_in(KerfStage.GHOST):
			target = k.pick(stage, k.sight_aim)
	var bearing: float = facing
	if target != null:
		bearing = stage.arena.rivet.pos.angle_to_point(target.pos)
	_aim(clampf(angle_difference(facing, bearing), -AIM_LIMIT, AIM_LIMIT), stage.tick)
	transform = Transform2D.IDENTITY
	if since >= 0 and since < KerfSlot.RETURN_TICKS + TUCK_TICKS:
		var shift: Vector2 = (KerfSlot.end_m(k, -1, since) - k.trail_to[-1]) * SimConst.PX_PER_M
		if rig.drawn.flight != null:
			var back: float = smoothstep(
				KerfSlot.RETURN_TICKS, KerfSlot.RETURN_TICKS + TUCK_TICKS, since
			)
			shift -= rig.drawn.flight.hover.lag_px * (1.0 - back)
		global_position += shift
	_hit.read(stage.arena, facing)
	pose(rig, blink_pose(since, sliced), target != null, bearing, stage.tick)
	_hit.apply(self)
	_step_echoes(stage)


func pose(
	rig: KerfRig, blink: KerfRoninDrawn.Pose, locked: bool, bearing: float, tick: int
) -> void:
	var flight: GhostFlight = rig.drawn.flight
	var speed: float = flight.hover.speed_mps if flight != null else rig.speed_mps
	var yaw: float = _turn(flight.hover.yaw_rate_dps if flight != null else 0.0, tick)
	current = KerfRoninDrawn.pose(speed, yaw, blink, locked, _hit.hurt)
	_tilted.visible = ViewMode.shared().art in ["p55", "p70"]
	_top.visible = not _tilted.visible
	if flight != null:
		# A billboard ribbon hangs down the screen. Only the overhead tip follows a ground anchor.
		flight.tail.visible = _top.visible
	var steps: int = maxi(0, tick - _last_tick)
	_last_tick = tick
	_top.pose(current, speed, yaw, steps)
	if _tilted.visible:
		var oct: int = rig.drawn.octant(rig.global_rotation)
		if current == KerfRoninDrawn.Pose.COCK:
			oct = posmod(roundi(bearing / (TAU / 8.0)), 8)
		var lean: float = flight.hover.lean * cos(rig.rotation) if flight != null else 0.0
		_tilted.show_pose(oct, current, yaw, lean - rig.rotation, _hit.flinch)
	else:
		_top.rotation = _yaw


## A snapped aim octant can turn 45 degrees in one tick. Hold its signed cell long enough to read.
func _turn(rate: float, tick: int) -> float:
	if absf(rate) > KerfRoninDrawn.TURN_DPS:
		_turn_tick = tick
		_turn_rate = rate
	var age: int = tick - _turn_tick
	return _turn_rate if age >= 0 and age < TURN_HOLD_TICKS else rate


func _step_echoes(stage: CollectCallStage) -> void:
	if not reduced_motion:
		if _echoes == null:
			_echoes = KerfEcho.new()
			add_child(_echoes)
			_echoes.bind(_top, _tilted)
		_echoes.step(stage)
	elif _echoes != null:
		_echoes.queue_free()
		_echoes = null


func _aim(goal: float, tick: int) -> void:
	if not is_equal_approx(goal, _yaw_goal):
		_yaw_start = _yaw
		_yaw_goal = goal
		_aim_tick = tick - 1
	_yaw = lerpf(_yaw_start, _yaw_goal, smoothstep(0, AIM_TICKS, tick - _aim_tick))
