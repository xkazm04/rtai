class_name ArenaArsenalBot
extends InputSource
## rivet-arsenal's scripted player for the carry station (--bot=arsenal --loadout=...): gunplay's
## pit fight (GunplayBot: in, then each wave at reach, fire after a reaction time, strafe) with a
## weapon switch every SWITCH_TICKS: it presses the next slot's number key for one tick, so every
## carried gun is stowed, drawn, carried, aimed and fired in turn, and reloaded once halfway
## through its turn (the reload key), so every class's reload plays on camera.
## When no shot has left for stuck_ticks while a guard stands (on the city block a guard holds
## behind a kerb car or a corner and the strafe never opens a line), it walks straight at him until
## it fires again, so the block's fight keeps moving.
## With a melee weapon drawn (StagePilot.wielding) it walks into MELEE_IN_M of the nearest standing
## guard and only swings (a held fire) inside MELEE_SWING_M, so a katana, baton or chainsaw meets a
## body on the city block instead of cutting air at gun reach.
## Deterministic: reads only the sim.

const SWITCH_TICKS: int = 240
const REACH_M: float = 8.0
## Melee: stop walking in at this range; swing only inside MELEE_SWING_M (the claw reach is 1.4).
const MELEE_IN_M: float = 1.1
const MELEE_SWING_M: float = 1.6
## A walk-in that moved less than STALL_M over STALL_TICKS (cover in the way) side-steps for
## SIDESTEP_TICKS, keeping its side round the cover; only a blocked side-step flips the side.
## A prop in the straight line (stage.walls) slides it round on that side at once.
const STALL_TICKS: int = 20
const STALL_M: float = 0.15
const SIDESTEP_TICKS: int = 45

var stage: ArenaStage
var actions: PlayerActions
## Ticks in reach without a shot before it walks straight at the guard (a test can plant a fault).
var stuck_ticks: int = 120
## Walks into melee reach with a melee weapon drawn (false: the old stand-off at gun reach).
var melee_close_in: bool = true
var _fight: GunplayBot
var _slot: int = 0
var _fired_tick: int = 0
var _walk_from: Vector2 = Vector2.ZERO
var _walk_tick: int = 0
var _side_until: int = -1
var _side: float = 1.0


func _init(p_stage: ArenaStage, p_actions: PlayerActions) -> void:
	stage = p_stage
	actions = p_actions
	_fight = GunplayBot.new(p_stage, p_actions, REACH_M / GunplayBot.REACH_SHARE)


## A bot that never closes in: neither its own walk at the guard nor GunplayBot's flank round
## the cover (a scenario's planted fault).
func never_close_in(ticks: int) -> void:
	stuck_ticks = ticks
	_fight.flank_after = ticks


func sample(tick: int) -> TickInput:
	var t: TickInput = _close_in(_fight.sample(tick), tick)
	if melee_close_in and stage.pilot != null and stage.pilot.wielding():
		t = _melee_in(t, tick)
	var carry: RivetCarry = stage.pilot.carry if stage.pilot != null else null
	if carry != null and tick % SWITCH_TICKS == SWITCH_TICKS / 2:
		t.buttons |= 1 << actions.bit(&"reload")
	if carry == null or tick == 0 or tick % SWITCH_TICKS != 0:
		return t
	for k: int in range(1, RivetCarry.SLOTS + 1):
		var i: int = posmod(carry.current + k, RivetCarry.SLOTS)
		if carry.slots[i] != &"":
			_slot = i
			break
	t.buttons |= 1 << actions.bit(RivetCarry.SLOT_ACTIONS[_slot])
	return t


## Melee drawn: walk at the nearest standing guard until MELEE_IN_M, hold fire outside the swing.
func _melee_in(t: TickInput, tick: int) -> TickInput:
	var foe: Fighter = _nearest()
	if foe == null or _fight._next < ArenaPitBot.ENTRY.size():
		return t
	var at: Vector2 = stage.arena.rivet.pos
	var to: Vector2 = foe.pos - at
	var b: int = t.buttons
	if to.length() > MELEE_SWING_M:
		b &= ~(1 << actions.bit(&"fire"))
	if to.length() <= MELEE_IN_M:
		_walk_tick = tick
		_walk_from = at
		return TickInput.new(b, 0, 0)
	if tick - _walk_tick >= STALL_TICKS:
		if at.distance_to(_walk_from) < STALL_M:
			if tick < _side_until:
				_side = -_side  # the side-step itself is blocked: try the other way round
			_side_until = tick + SIDESTEP_TICKS
		_walk_tick = tick
		_walk_from = at
	var dir: Vector2 = to.normalized()
	var covered: bool = stage.walls != null and stage.walls.blocks(at, foe.pos)
	if tick < _side_until or covered:
		dir = (dir * 0.35 + dir.orthogonal() * _side).normalized()
	var m: Vector2 = dir * TickInput.AXIS_MAX
	return TickInput.new(b, roundi(m.x), roundi(m.y))


func _nearest() -> Fighter:
	var rivet: Vector2 = stage.arena.rivet.pos
	var foe: Fighter = null
	for f: Fighter in stage.pit.standing:
		if f.alive() and (foe == null or rivet.distance_to(f.pos) < rivet.distance_to(foe.pos)):
			foe = f
	return foe


## Walks straight at the nearest standing guard after stuck_ticks in reach without a shot.
func _close_in(t: TickInput, tick: int) -> TickInput:
	var rivet: Vector2 = stage.arena.rivet.pos
	var foe: Fighter = _nearest()
	var fired: bool = t.buttons & (1 << actions.bit(&"fire")) != 0
	var entering: bool = _fight._next < ArenaPitBot.ENTRY.size()  # its way in is not a fight
	if fired or entering or foe == null or rivet.distance_to(foe.pos) > _fight.reach_m + 0.5:
		_fired_tick = tick
		return t
	if tick - _fired_tick < stuck_ticks:
		return t
	var m: Vector2 = (foe.pos - rivet).normalized() * TickInput.AXIS_MAX
	return TickInput.new(t.buttons, roundi(m.x), roundi(m.y))
