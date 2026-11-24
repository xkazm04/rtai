class_name PlayerMotion
extends RefCounted
## Held sprint clears the 7.5 m/s tackle line and turns more slowly toward travel. A roll press
## eases out with i-frames and recovery, or vaults a low obstacle. Station cover owns the snap,
## slide and corner peek. A dash press commits to a burst along the ground direction.

enum Phase { FREE, ROLL, RECOVER, VAULT, DASH }

const TABLE: String = "res://data/tables/rivet_motion.json"
const SCHEMA: String = "gtai.rivet-motion/1"

var mover: TopDownMover = TopDownMover.new()
var vault: PlayerVault = PlayerVault.new()
var cover: PlayerCover = PlayerCover.new()
var phase: Phase = Phase.FREE
var sprinting: bool = false
var dash: PlayerMotionDash = PlayerMotionDash.new()
var dashes: int = 0
var rolls: int = 0
var roll_dir: Vector2 = Vector2.ZERO
var sprint_mps: float = 9.3
var sprint_accel_mps2: float = 24.0
var sprint_turn_dps: float = 320.0
var min_forward_dot: float = 0.4
var roll_m: float = 3.2
var roll_ticks: int = 22
var iframe_from: int = 2
var iframe_to: int = 14
var recovery_ticks: int = 10
var recovery_move_scale: float = 0.35
var cooldown_ticks: int = 8
var exit_speed_k: float = 0.5
## n11 (the owner's "direction of player should follow cursor"; rivet_motion.json face_aim): the
## look is the aim wherever a device aims, a sprint included; false = the turned, walking facing.
var face_aim: bool = true
var errors: Array[String] = []
var _phase_tick: int = 0
var _cooldown: int = 0
## The roll tick executed by the last step (-1 outside a roll): the i-frame window reads it.
var _roll_tick: int = -1


static func shipped() -> PlayerMotion:
	var m: PlayerMotion = from_table(DataTable.open(TABLE, SCHEMA))
	m.vault.apply_flags()
	m.cover.apply_flags()
	return m


static func from_table(t: DataTable) -> PlayerMotion:
	return PlayerMotionTable.read(t)


func drive(stage: CollectCallStage, pilot: StagePilot, c: PlayerCommand, walk: float) -> void:
	if (
		stage.vehicles != null
		and (stage.vehicles.driving != null or stage.vehicles.doors.car != null)
	):
		stop()
		stage.intent.move_by = Vector2.ZERO
		return
	if not cover.drive(stage, pilot, c, walk):
		vault.drive(stage, pilot, c, walk)
		if dash.frame >= 0:
			stage.intent.move_by = dash.clip_move(stage, self, stage.intent.move_by)
	elif cover.spot != null:  # A roll exit released its spot and already called step().
		@warning_ignore("return_value_discarded")
		dash.rest_tick()


## The displacement for one tick. `aim` Vector2.ZERO faces the walk direction.
func step(c: PlayerCommand, walk_mps: float, actions: PlayerActions) -> Vector2:
	_cooldown = maxi(_cooldown - 1, 0)
	_roll_tick = -1
	var dash_ready: bool = dash.rest_tick()
	vault.reset_tick()
	if c.was_pressed(actions, &"roll") and can_roll() and not vault.intercept(self, c.move):
		_start_roll(c.move)
	if phase == Phase.VAULT:
		_phase_tick = vault.advance(_phase_tick)
		if _phase_tick == 0:
			phase = Phase.RECOVER
	if vault.owns_move:
		return Vector2.ZERO
	match phase:
		Phase.ROLL:
			return _roll_step(walk_mps)
		Phase.RECOVER:
			return _recover_step(c, walk_mps, actions)
	if dash_ready and phase == Phase.FREE and c.was_pressed(actions, &"dash"):
		dash.start(self, c)
	if phase == Phase.DASH:
		return dash.advance(self, walk_mps)
	return _free_step(c, walk_mps, actions)


func blocks_fire() -> bool:
	return cover.blocks_fire() or phase == Phase.ROLL or (vault.frame >= 0 and vault.no_fire)


func can_roll() -> bool:
	return phase == Phase.FREE and _cooldown == 0


## True on the roll's invulnerable ticks (iframe_from..iframe_to, inclusive).
func invulnerable() -> bool:
	return vault.invulnerable() or (_roll_tick >= iframe_from and _roll_tick <= iframe_to)


## 0..1 through the roll (for the rig's tuck), 0 outside it.
func roll_progress() -> float:
	return float(_roll_tick + 1) / float(roll_ticks) if _roll_tick >= 0 else 0.0


func facing() -> Vector2:
	return mover.facing


## The look: the aim while a device aims (not during a roll, which faces its roll), else the turned
## facing. Turning and the sprint's own heading stay in the mover (speed, strafe).
func heading(aim: Vector2) -> Vector2:
	if face_aim and aim != Vector2.ZERO and phase != Phase.ROLL and vault.frame < 0:
		return aim.normalized()
	return mover.facing


func velocity() -> Vector2:
	return mover.velocity


func stop() -> void:
	if phase == Phase.DASH:
		dash.finish(self)
	dash.frame = -1
	cover.interrupt()
	vault.interrupt()
	if phase == Phase.VAULT:
		phase = Phase.RECOVER
		_phase_tick = 0
	mover.stop()
	sprinting = false


func write_state(out: StreamPeerBuffer) -> void:
	mover.write_state(out)
	out.put_32(phase)
	out.put_32(_phase_tick)
	out.put_32(_cooldown)
	out.put_float(roll_dir.x)
	out.put_float(roll_dir.y)
	vault.write_state(out, phase)
	cover.write_state(out)
	if dashes > 0:
		dash.write_state(out, dashes)


func _free_step(c: PlayerCommand, walk_mps: float, actions: PlayerActions) -> Vector2:
	var push: Vector2 = c.move.limit_length(1.0)
	var held: bool = c.is_held(actions, &"sprint") or dash.sprint_held(c, actions)
	sprinting = held and push.length() > 0.5
	if not sprinting:
		return mover.step(c.move, c.aim, walk_mps, actions)
	var aligned: bool = push.normalized().dot(mover.facing) >= min_forward_dot
	var top: float = sprint_mps if aligned else walk_mps
	return mover.sprint(c.move, top, actions, sprint_accel_mps2, sprint_turn_dps)


func _start_roll(stick: Vector2) -> void:
	var push: Vector2 = stick.limit_length(1.0)
	roll_dir = push.normalized() if push.length() > 0.2 else mover.facing
	mover.facing = roll_dir
	phase = Phase.ROLL
	_phase_tick = 0
	sprinting = false
	rolls += 1


## Ease-out: f(u) = 1 - (1 - u)^2, so the covered distance is exactly roll_m.
func _roll_step(walk_mps: float) -> Vector2:
	var k: int = _phase_tick
	var u0: float = float(k) / float(roll_ticks)
	var u1: float = float(k + 1) / float(roll_ticks)
	var ds: float = roll_m * ((1.0 - u0) * (1.0 - u0) - (1.0 - u1) * (1.0 - u1))
	_roll_tick = k
	_phase_tick += 1
	mover.velocity = roll_dir * ds / SimClock.TICK_DT
	if _phase_tick >= roll_ticks:
		phase = Phase.RECOVER
		_phase_tick = 0
		mover.velocity = roll_dir * walk_mps * exit_speed_k
	return roll_dir * ds


func _recover_step(c: PlayerCommand, walk_mps: float, actions: PlayerActions) -> Vector2:
	_phase_tick += 1
	if _phase_tick >= recovery_ticks:
		phase = Phase.FREE
		_phase_tick = 0
		_cooldown = cooldown_ticks
	return mover.step(c.move * recovery_move_scale, c.aim, walk_mps, actions)
