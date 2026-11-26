class_name PlayBaselinePilot
extends GauntletTestPlayer
## n31 melee 01b: the gauntlet's average bot. A held blade's melee press goes out as primary
## (a human swings a blade with fire; the bot only knows the claw's melee key). The bot's own
## weapon switches are dropped so it stays on the one weapon the hook holds.

var blade: bool = false
var _actions: PlayerActions


func bind(run: GauntletRun, session: ArenaSession) -> void:
	super.bind(run, session)
	_actions = session.actions


func sample(tick: int) -> TickInput:
	var input: TickInput = super.sample(tick)
	var drop: int = _bit(&"weapon_next") | _bit(&"weapon_prev")
	for slot: StringName in RivetCarry.SLOT_ACTIONS:
		drop |= _bit(slot)
	input.buttons &= ~drop
	if blade and (input.buttons & _bit(&"melee")) != 0:
		input.buttons = (input.buttons & ~_bit(&"melee")) | _bit(&"fire")
	return input


func _bit(action: StringName) -> int:
	var bit: int = _actions.bit(action)
	return 1 << bit if bit >= 0 else 0
