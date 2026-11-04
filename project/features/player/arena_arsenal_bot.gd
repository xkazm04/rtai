class_name ArenaArsenalBot
extends InputSource
## rivet-arsenal's scripted player for the carry station (--bot=arsenal --loadout=...): gunplay's
## pit fight (GunplayBot: in, then each wave at reach, fire after a reaction time, strafe) with a
## weapon switch every SWITCH_TICKS: it presses the next slot's number key for one tick, so every
## carried gun is stowed, drawn, carried, aimed and fired in turn.
## Deterministic: reads only the sim.

const SWITCH_TICKS: int = 240
const REACH_M: float = 8.0

var stage: ArenaStage
var actions: PlayerActions
var _fight: GunplayBot
var _slot: int = 0


func _init(p_stage: ArenaStage, p_actions: PlayerActions) -> void:
	stage = p_stage
	actions = p_actions
	_fight = GunplayBot.new(p_stage, p_actions, REACH_M / GunplayBot.REACH_SHARE)


func sample(tick: int) -> TickInput:
	var t: TickInput = _fight.sample(tick)
	var carry: RivetCarry = stage.pilot.carry if stage.pilot != null else null
	if carry == null or tick == 0 or tick % SWITCH_TICKS != 0:
		return t
	for k: int in range(1, RivetCarry.SLOTS + 1):
		var i: int = posmod(carry.current + k, RivetCarry.SLOTS)
		if carry.slots[i] != &"":
			_slot = i
			break
	t.buttons |= 1 << actions.bit(RivetCarry.SLOT_ACTIONS[_slot])
	return t
