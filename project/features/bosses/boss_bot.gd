class_name BossBot
extends InputSource
## `--bot=boss --boss=<id>`: a scripted player for boss clips and numbers (deterministic: it reads
## only the sim). It holds a band of HOLD_M from the boss and fires at it once the boss is in
## FIRE_M. The dodging bot reads the tell like a player: REACT_TICKS after a windup begins it
## checks whether it stands in the attack's zone (BossZone, the same numbers that land the hit)
## and, if so, rolls / sprints out sideways of the aim until the attack is over. `--bot-stand`
## is the standing bot: it never moves (the other end of each attack's hit rate).

const HOLD_M: float = 8.0
const FIRE_M: float = 16.0
## A player's read of a tell: about 0.3 s from the windup's first frame.
const REACT_TICKS: int = 18
## Extra clearance the dodge aims for past the zone's edge.
const CLEAR_M: float = 1.2

var stage: ArenaStage
var actions: PlayerActions
var hook: BossHook = null
var standing: bool = false
var _side: float = 1.0


func _init(p_stage: ArenaStage, p_actions: PlayerActions) -> void:
	stage = p_stage
	actions = p_actions
	standing = OS.get_cmdline_user_args().has("--bot-stand")


func sample(_tick: int) -> TickInput:
	if hook == null:
		for h: ArenaHook in stage.hooks:  # the stage's hooks exist once it is set up
			if h is BossHook:
				hook = h
	if hook == null or hook.fight == null:
		return TickInput.new()
	var f: BossFight = hook.fight
	var me: Vector2 = stage.arena.rivet.pos
	var to_boss: Vector2 = f.body.pos - me
	var aim: Vector2 = to_boss.normalized() if to_boss.length() > 0.01 else Vector2.RIGHT
	var fire: bool = to_boss.length() <= FIRE_M and f.state != BossFight.State.DEFEATED
	if standing:
		return _input(Vector2.ZERO, aim, fire, false)
	var dodge: Vector2 = _dodge(f, me)
	if dodge != Vector2.ZERO:
		return _input(dodge, aim, fire, true)
	var band: float = to_boss.length() - HOLD_M
	var move: Vector2 = aim * clampf(band, -1.0, 1.0) + aim.orthogonal() * _side * 0.35
	return _input(move, aim, fire, false)


## The way out of the coming attack's zone, or zero when it is safe (or not yet read).
func _dodge(f: BossFight, me: Vector2) -> Vector2:
	var reading: bool = f.state == BossFight.State.WINDUP and f.t >= REACT_TICKS
	if not reading and f.state != BossFight.State.ACTIVE:
		return Vector2.ZERO
	var a: BossAttack = f.attack
	var r: float = stage.arena.rivet.radius_m + CLEAR_M
	var in_zone: bool = BossZone.hits(a, f.origin, f.aim, me, r)
	if a.shape == BossAttack.Shape.CHARGE and f.state == BossFight.State.ACTIVE:
		in_zone = in_zone or BossZone.body_hits(f.body.pos, f.body.radius_m, a, me, r)
	if not in_zone:
		return Vector2.ZERO
	if a.shape == BossAttack.Shape.CIRCLE:
		return (me - f.origin).normalized()  # out of the ring
	var across: float = (me - f.origin).dot(f.aim.orthogonal())
	_side = 1.0 if across >= 0.0 else -1.0
	return f.aim.orthogonal() * _side


func _input(move: Vector2, aim: Vector2, fire: bool, hurry: bool) -> TickInput:
	var m: Vector2 = move.limit_length(1.0) * TickInput.AXIS_MAX
	var buttons: int = PlayerCommand.pack_aim(aim, actions)
	if fire:
		buttons |= 1 << actions.bit(&"fire")
	if hurry:
		buttons |= 1 << actions.bit(&"sprint")
	return TickInput.new(buttons, roundi(m.x), roundi(m.y))
