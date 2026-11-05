class_name BossBot
extends InputSource
## `--bot=boss --boss=<id>`: a scripted player for boss clips and numbers (deterministic: it reads
## only the sim). It holds a band of HOLD_M from the boss and fires at it once the boss is in
## FIRE_M. The dodging bot reads the tell like a player: REACT_TICKS after a windup begins it
## checks whether it stands in the attack's zone (BossZone, the same numbers that land the hit)
## and, if so, sprints out sideways of the aim, and rolls if it is still in the zone ROLL_LEFT
## ticks before the active window. `--bot-stand` is the standing bot: the same band, but it never
## strafes or dodges (the other end of each attack's hit rate). `--bot-human` is the middle
## (BossBotRead). With cover between it and the boss (BossMoves.solids, the arena's props) the
## dodging bot walks round it sideways for a line of sight, as a player would; a sidestep into
## cover turns to the open side, and walled on both sides in an active attack it rolls.

const HOLD_M: float = 8.0
const FIRE_M: float = 16.0
## A player's read of a tell: about 0.3 s from the windup's first frame.
const REACT_TICKS: int = 18
## Extra clearance the dodge aims for past the zone's edge.
const CLEAR_M: float = 1.2
## Still in the zone this close to the active window: roll (its i-frames cover the hit).
const ROLL_LEFT: int = 8
## A charge is rolled on its body, not its tell: pressed when the body is this many ticks away,
## so it meets the roll's i-frames (rivet_motion.json roll iframe_from 2 .. iframe_to 14).
const CHARGE_ROLL_TICKS: int = 7
## Closer than this to the fight floor's edge, the bot heads back toward its middle.
const EDGE_M: float = 3.0
## How far ahead a sidestep looks for cover.
const BLOCK_M: float = 1.5
## An add (or a boss script's body: a drone) this close is shot before the boss.
const ADD_M: float = 7.0

var stage: ArenaStage
var actions: PlayerActions
var hook: BossHook = null
var standing: bool = false
var _side: float = 1.0
## `--bot-human`: reads ~70 % of tells, late by a human's spread, aim sways (BossBotRead).
var _human: BossBotRead = null
## `--ghost=<id>`: the bot takes that ghost's soul and uses its melee on the fight (BossBotGhost).
var _ghost: BossBotGhost = null
var _bits: int = 0


func _init(p_stage: ArenaStage, p_actions: PlayerActions) -> void:
	stage = p_stage
	actions = p_actions
	standing = OS.get_cmdline_user_args().has("--bot-stand")


func sample(tick: int) -> TickInput:
	if hook == null:
		_find_hook()
	if hook == null or hook.fight == null:
		return TickInput.new()
	var f: BossFight = hook.fight
	var me: Vector2 = stage.arena.rivet.pos
	var to_boss: Vector2 = f.body.pos - me
	var foe: Vector2 = _target(me, f.body.pos) - me  # the nearest add inside ADD_M, else King
	var aim: Vector2 = foe.normalized() if foe.length() > 0.01 else Vector2.RIGHT
	if _human != null:
		aim = BossBotRead.sway(aim, tick)
		for threat: BossFight in [f] + hook.adds.fights:
			_human.see(threat)
	var fire: bool = foe.length() <= FIRE_M and f.state != BossFight.State.DEFEATED
	_bits = _ghost.buttons(tick, hook, me, actions) if _ghost != null else 0
	var band: float = to_boss.length() - (_ghost.hold_m(f, HOLD_M) if _ghost != null else HOLD_M)
	var off_floor: bool = not hook.bounds.grow(-EDGE_M).has_point(me)
	var home: Vector2 = (hook.bounds.get_center() - me).normalized()
	if standing:  # holds the same band, never strafes, never dodges
		var hold: Vector2 = home if off_floor else aim * clampf(band, -1.0, 1.0)
		return _input(hold, aim, fire, false, false)
	for threat: BossFight in [f] + hook.adds.fights:
		if threat.state == BossFight.State.DEFEATED:
			continue
		var dodge: Vector2 = _unblock(_dodge(threat, me), me)
		if dodge != Vector2.ZERO:
			var roll: bool = _rolls(threat, me, dodge)
			return _input(dodge, aim, fire and not roll, true, roll)
	var away: Vector2 = f.moves.threat_away(me, stage.arena.rivet.radius_m + CLEAR_M)
	if away != Vector2.ZERO:  # the boss script's own late hazards (Servo's drop rings)
		return _input(away, aim, fire, true, false)
	var move: Vector2 = aim * clampf(band, -1.0, 1.0) + aim.orthogonal() * _side * 0.35
	if stage.walls.blocks(me, f.body.pos):  # cover in the line (a wreck, crates): walk round it
		move = to_boss.normalized().orthogonal() * _side + to_boss.normalized() * 0.25
	if off_floor:  # drifting off the floor: head back in
		move = home
	return _input(move, aim, fire, false, false)


func _find_hook() -> void:
	for h: ArenaHook in stage.hooks:  # the stage's hooks exist once it is set up
		if h is BossHook:
			hook = h
			if OS.get_cmdline_user_args().has("--bot-human"):
				_human = BossBotRead.new(hook.stream(&"boss_bot"))
			var g: String = BossHook._arg(OS.get_cmdline_user_args(), "--ghost")
			_ghost = BossBotGhost.new(StringName(g)) if g != "" else null


## The nearest standing add within ADD_M of Rivet (the gang closes in: shoot it first), else King.
func _target(me: Vector2, boss_at: Vector2) -> Vector2:
	var best: Vector2 = boss_at
	var best_d: float = ADD_M
	for a: BossFight in hook.adds.fights:
		var d: float = me.distance_to(a.body.pos)
		if a.state != BossFight.State.DEFEATED and d < best_d:
			best = a.body.pos
			best_d = d
	for b: Fighter in hook.fight.moves.bodies():  # the boss script's own bodies (drones)
		var d: float = me.distance_to(b.pos)
		if b.alive() and d < best_d:
			best = b.pos
			best_d = d
	return best


## The way out of the coming attack's zone, or zero when it is safe (or not yet read).
func _dodge(f: BossFight, me: Vector2) -> Vector2:
	var reading: bool = f.state == BossFight.State.WINDUP and f.t >= REACT_TICKS
	if not reading and f.state != BossFight.State.ACTIVE:
		return Vector2.ZERO
	if _human != null and not _human.reacts(f):
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


## A sidestep into cover (a wall, a crate, the wreck) turns to the other side when that is open
## (servo's ask: the crate-slowed dodging bot).
func _unblock(dodge: Vector2, me: Vector2) -> Vector2:
	var out: Vector2 = sidestep(stage.walls, me, dodge)
	_side = -_side if out != dodge else _side
	return out


## Roll: still in the zone just before the active window, or walled in on an active attack.
## A charge is rolled on its body, CHARGE_ROLL_TICKS away along the lane (a dash crosses 14 m:
## the tell's end is too early).
func _rolls(f: BossFight, me: Vector2, dodge: Vector2) -> bool:
	var charge: bool = f.attack.shape == BossAttack.Shape.CHARGE
	if f.state == BossFight.State.WINDUP:
		return not charge and f.tell_left() <= ROLL_LEFT
	if f.state != BossFight.State.ACTIVE:
		return false
	if charge:
		var gap: float = (me - f.body.pos).dot(f.aim) - f.body.radius_m
		if gap >= -0.5 and gap <= f.attack.move_mps / 60.0 * float(CHARGE_ROLL_TICKS):
			return true
	return walled(stage.walls, me, dodge)


## `dodge`, or its opposite when cover stands within BLOCK_M along it and the other side is open.
static func sidestep(walls: ArenaWalls, me: Vector2, dodge: Vector2) -> Vector2:
	if dodge == Vector2.ZERO or not walled(walls, me, dodge) or walled(walls, me, -dodge):
		return dodge
	return -dodge


## Cover within BLOCK_M along `dir` (walled on both sides in an active attack, the bot rolls).
static func walled(walls: ArenaWalls, me: Vector2, dir: Vector2) -> bool:
	return walls != null and walls.blocks(me, me + dir.normalized() * BLOCK_M)


func _input(move: Vector2, aim: Vector2, fire: bool, hurry: bool, roll: bool) -> TickInput:
	var m: Vector2 = move.limit_length(1.0) * TickInput.AXIS_MAX
	var buttons: int = PlayerCommand.pack_aim(aim, actions) | _bits
	if fire:
		buttons |= 1 << actions.bit(&"fire")
	if hurry:
		buttons |= 1 << actions.bit(&"sprint")
	if roll:
		buttons |= 1 << actions.bit(&"roll")
	return TickInput.new(buttons, roundi(m.x), roundi(m.y))
