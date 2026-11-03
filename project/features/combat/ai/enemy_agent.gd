class_name EnemyAgent
extends RefCounted
## One enemy as data: archetype, body state, the brain's state and timers. Views read pose();
## nothing here is a node (SIM-03). Positions in metres, timers in ticks.

enum State {PATROL, ALERT, ENGAGE, WINDUP, FIRE, RECOVER, COVER, FLANK, PANIC, DOWN, DEAD, STAGGER}

const HURT_TICKS: int = 12

var id: int = 0
var arch: EnemyRoster.Archetype = null
var pos: Vector2 = Vector2.ZERO
var vel: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.RIGHT
## The locked or tracking aim direction while winding up.
var aim: Vector2 = Vector2.RIGHT
var hp: float = 1.0
var state: State = State.PATROL
var timer: int = 0
var state_ticks: int = 0
var cooldown: int = 0
var burst_left: int = 0
var burst_gap: int = 0
var token: bool = false
var token_ticks: int = 0
var waited: int = 0
var goal: Vector2 = Vector2.ZERO
var strafe_sign: float = 1.0
var last_seen: Vector2 = Vector2.ZERO
var sees: bool = false
var broke: bool = false
var hurt_tick: int = -1000
## The direction the last blow travelled (the rig's HIT clip shoves along it).
var hurt_dir: Vector2 = Vector2.RIGHT
## The tick of the last shot or swing (the rig's SHOOT recoil or swing clip).
var shot_tick: int = -1000
var died_tick: int = -1
## The pit's cover boxes (shared, read-only here): the motor paths round them.
var cover_ref: Array[Rect2] = []
## The group this enemy fights with (a pit wave): morale counts only its own fallen.
var squad: int = 0


static func make(p_id: int, p_arch: EnemyRoster.Archetype, at: Vector2) -> EnemyAgent:
	var e: EnemyAgent = EnemyAgent.new()
	e.id = p_id
	e.arch = p_arch
	e.pos = at
	e.goal = at
	e.hp = p_arch.hp
	e.strafe_sign = 1.0 if p_id % 2 == 0 else -1.0
	return e


func alive() -> bool:
	return state != State.DEAD


func melee() -> bool:
	return arch.weapon.melee


func radius() -> float:
	return 0.5 if arch.body == &"robot" else 0.35


func enter(next: State, ticks: int = 0) -> void:
	state = next
	timer = ticks
	state_ticks = 0


func engaged() -> bool:
	return state >= State.ENGAGE and state <= State.FLANK


## The aim is locked (the last aim_lock ticks of the windup: a player who moves now dodges).
func aim_locked(lock_ticks: int) -> bool:
	return state == State.WINDUP and timer <= lock_ticks


## The rig pose this tick (the cutout rig maps these to clips; readable at 32 px/m).
func pose(now: int) -> StringName:
	var p: StringName = &"run" if vel.length() > 0.4 else &"idle"
	match state:
		State.DEAD:
			p = &"die"
		State.DOWN:
			p = &"down" if timer > 20 else &"getup"
		State.WINDUP:
			p = &"windup" if melee() else &"aim"
		State.FIRE, State.RECOVER:
			p = &"swing" if melee() else &"shoot"
		State.PANIC:
			p = &"flee"
		State.STAGGER:
			p = &"stagger"
	var hurt: bool = now - hurt_tick < HURT_TICKS and state != State.DEAD
	return &"hit" if hurt and state != State.DOWN and state != State.STAGGER else p


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(id)
	out.put_32(state)
	out.put_float(pos.x)
	out.put_float(pos.y)
	out.put_float(hp)
	out.put_32(timer)
