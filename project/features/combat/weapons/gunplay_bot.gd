class_name GunplayBot
extends InputSource
## Lane gunplay's scripted player for the arena pit (deterministic: it reads only the sim): the
## pit bot's way in, then it fights each wave at its weapon's own reach: it closes on the nearest
## standing guard until inside `reach_m` (a share of the table row's range, never past 9 m, so a
## 48 or 64 px/m close-up following Rivet frames the impact), fires after a human's reaction
## time, and strafes across the guard's line. So the 7 m flamethrower gets into the flame. It
## holds fire while a prop stands in the line (rockets would burst in its own cover); blocked for
## FLANK_AFTER ticks it commits to one side and closes in, so it rounds the cover instead of
## rocking on the spot while a guard shoots over the crates.

const STRAFE_TICKS: int = 45
const REACT_TICKS: int = 30
const REACH_SHARE: float = 0.75
const MAX_REACH_M: float = 9.0
const FLANK_AFTER: int = 30
const FOLLOW_M: float = 4.0

var stage: ArenaStage
var actions: PlayerActions
var reach_m: float = MAX_REACH_M
## Blocked ticks before it rounds the cover (a test can switch the flank off with a huge value).
var flank_after: int = FLANK_AFTER
## Dev capture (`--lone`): with no foe left to shoot, walk after a burning guard (fire held), so
## the camera keeps his panic run and his death in frame.
var follow_burning: bool = false
var _next: int = 0
var _in_range_since: int = -1
var _blocked_since: int = -1
var _flank: float = 1.0


func _init(p_stage: ArenaStage, p_actions: PlayerActions, range_m: float) -> void:
	stage = p_stage
	actions = p_actions
	reach_m = minf(range_m * REACH_SHARE, MAX_REACH_M)


func sample(tick: int) -> TickInput:
	var rivet: Vector2 = stage.arena.rivet.pos
	var entry: Array[Vector2] = ArenaPitBot.ENTRY
	if _next < entry.size():
		var to: Vector2 = stage.plan.base + entry[_next] - rivet
		if to.length() <= ArenaPitBot.REACH_M:
			_next += 1
		return _input(to.normalized(), to.normalized(), false)
	var spot: Vector2 = stage.plan.base + entry[entry.size() - 1]
	var foe: Fighter = _nearest(rivet)
	if foe == null:
		_in_range_since = -1
		var lit: Fighter = _burning() if follow_burning else null
		if lit != null:
			var to_lit: Vector2 = lit.pos - rivet
			var walk: Vector2 = to_lit.normalized() if to_lit.length() > FOLLOW_M else Vector2.ZERO
			return _input(walk, to_lit.normalized(), false)
		return _input((spot - rivet).limit_length(1.0), Vector2.DOWN, false)
	var to_foe: Vector2 = foe.pos - rivet
	var aim: Vector2 = to_foe.normalized()
	var close: bool = to_foe.length() <= reach_m
	_in_range_since = (tick if _in_range_since < 0 else _in_range_since) if close else -1
	var lane: bool = _lane(rivet, foe.pos)
	var fire: bool = close and lane and tick - _in_range_since >= REACT_TICKS
	var side: float = 1.0 if (tick / STRAFE_TICKS) % 2 == 0 else -1.0
	var approach: Vector2 = aim if not close else Vector2.ZERO
	# a prop in the line: no shot into its own cover, a wider sidestep to find a lane
	var strafe: float = 0.6 if lane else 1.0
	if lane:
		_blocked_since = -1
	elif _blocked_since < 0:
		_blocked_since = tick
		_flank = side
	if not lane and tick - _blocked_since >= flank_after:
		side = _flank  # one way round the cover, and in
		approach = aim * 0.5
	return _input(aim.orthogonal() * side * strafe + approach, aim, fire, to_foe.length())


## True when a round can fly from Rivet to the foe (a lobbed bottle flies over the props).
func _lane(from: Vector2, to: Vector2) -> bool:
	var gun: GunHand = stage.arena.gun
	if stage.walls == null or (gun != null and gun.trigger.spec.kind == WeaponSpec.Kind.THROWN):
		return true
	return not stage.walls.blocks(from, to)


## The nearest standing guard that is not burning, stunned or down (they are already done).
func _nearest(at: Vector2) -> Fighter:
	var best: Fighter = null
	var areas: FightAreas = stage.arena.areas
	for f: Fighter in stage.pit.standing:
		var fx: FighterFx = areas.effect(f) if areas != null else null
		if not f.alive() or (fx != null and fx.burn_ticks > 0):
			continue
		if best == null or at.distance_to(f.pos) < at.distance_to(best.pos):
			best = f
	return best


## A standing guard still on fire (the lone capture follows him), or null.
func _burning() -> Fighter:
	var areas: FightAreas = stage.arena.areas
	if areas == null:
		return null
	for f: Fighter in stage.pit.standing:
		var fx: FighterFx = areas.effect(f)
		if f.alive() and fx != null and fx.burn_ticks > 0:
			return f
	return null


## `foe_m`: the foe's distance, sent as the cursor's (a thrown weapon lands on him).
func _input(move: Vector2, aim: Vector2, fire: bool, foe_m: float = 0.0) -> TickInput:
	var m: Vector2 = move.limit_length(1.0) * TickInput.AXIS_MAX
	var buttons: int = PlayerCommand.pack_aim(aim, actions, foe_m)
	if fire:
		buttons |= 1 << actions.bit(&"fire")
	return TickInput.new(buttons, roundi(m.x), roundi(m.y))
