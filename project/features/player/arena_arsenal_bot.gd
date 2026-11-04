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
## Deterministic: reads only the sim.

const SWITCH_TICKS: int = 240
const REACH_M: float = 8.0

var stage: ArenaStage
var actions: PlayerActions
## Ticks in reach without a shot before it walks straight at the guard (a test can plant a fault).
var stuck_ticks: int = 120
var _fight: GunplayBot
var _slot: int = 0
var _fired_tick: int = 0


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


## Walks straight at the nearest standing guard after stuck_ticks in reach without a shot.
func _close_in(t: TickInput, tick: int) -> TickInput:
	var rivet: Vector2 = stage.arena.rivet.pos
	var foe: Fighter = null
	for f: Fighter in stage.pit.standing:
		if f.alive() and (foe == null or rivet.distance_to(f.pos) < rivet.distance_to(foe.pos)):
			foe = f
	var fired: bool = t.buttons & (1 << actions.bit(&"fire")) != 0
	var entering: bool = _fight._next < ArenaPitBot.ENTRY.size()  # its way in is not a fight
	if fired or entering or foe == null or rivet.distance_to(foe.pos) > _fight.reach_m + 0.5:
		_fired_tick = tick
		return t
	if tick - _fired_tick < stuck_ticks:
		return t
	var m: Vector2 = (foe.pos - rivet).normalized() * TickInput.AXIS_MAX
	return TickInput.new(t.buttons, roundi(m.x), roundi(m.y))
