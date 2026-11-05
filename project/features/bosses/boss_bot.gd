class_name BossBot
extends InputSource
## `--bot=boss --boss=<id>`: a scripted player for boss clips and numbers (deterministic: it reads
## only the sim). It holds a band of HOLD_M from the boss and fires at it once the boss is in
## FIRE_M. The dodging bot reads the tell like a player: REACT_TICKS after a windup begins it
## checks whether it stands in the attack's zone (BossZone, the same numbers that land the hit)
## and, if so, sprints out sideways of the aim, and rolls if it is still in the zone ROLL_LEFT
## ticks before the active window. `--bot-stand`
## is the standing bot: the same band, but it never strafes or dodges (the other end of each
## attack's hit rate).

const HOLD_M: float = 8.0
const FIRE_M: float = 16.0
## A player's read of a tell: about 0.3 s from the windup's first frame.
const REACT_TICKS: int = 18
## Extra clearance the dodge aims for past the zone's edge.
const CLEAR_M: float = 1.2
## Still in the zone this close to the active window: roll (its i-frames cover the hit).
const ROLL_LEFT: int = 8
## An add this close is shot before King.
const ADD_M: float = 7.0

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
	var foe: Vector2 = _target(me, f.body.pos) - me  # the nearest add inside ADD_M, else King
	var aim: Vector2 = foe.normalized() if foe.length() > 0.01 else Vector2.RIGHT
	var fire: bool = foe.length() <= FIRE_M and f.state != BossFight.State.DEFEATED
	var band: float = to_boss.length() - HOLD_M
	if standing:  # holds the same band, never strafes, never dodges
		return _input(aim * clampf(band, -1.0, 1.0), aim, fire, false, false)
	for threat: BossFight in [f] + hook.adds.fights:
		if threat.state == BossFight.State.DEFEATED:
			continue
		var dodge: Vector2 = _dodge(threat, me)
		if dodge != Vector2.ZERO:
			var roll: bool = (
				threat.state == BossFight.State.WINDUP and threat.tell_left() <= ROLL_LEFT
			)
			return _input(dodge, aim, fire and not roll, true, roll)
	var move: Vector2 = aim * clampf(band, -1.0, 1.0) + aim.orthogonal() * _side * 0.35
	return _input(move, aim, fire, false, false)


## The nearest standing add within ADD_M of Rivet (the gang closes in: shoot it first), else King.
func _target(me: Vector2, boss_at: Vector2) -> Vector2:
	var best: Vector2 = boss_at
	var best_d: float = ADD_M
	for a: BossFight in hook.adds.fights:
		var d: float = me.distance_to(a.body.pos)
		if a.state != BossFight.State.DEFEATED and d < best_d:
			best = a.body.pos
			best_d = d
	return best


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


func _input(move: Vector2, aim: Vector2, fire: bool, hurry: bool, roll: bool) -> TickInput:
	var m: Vector2 = move.limit_length(1.0) * TickInput.AXIS_MAX
	var buttons: int = PlayerCommand.pack_aim(aim, actions)
	if fire:
		buttons |= 1 << actions.bit(&"fire")
	if hurry:
		buttons |= 1 << actions.bit(&"sprint")
	if roll:
		buttons |= 1 << actions.bit(&"roll")
	return TickInput.new(buttons, roundi(m.x), roundi(m.y))
