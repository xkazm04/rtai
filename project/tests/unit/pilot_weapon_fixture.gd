class_name PilotWeaponFixture
extends RefCounted
## Bind the fixture inventory and press its shortcut through the same pilot used for the attack.


static func draw(stage: CollectCallStage, carry: RivetCarry, slot: int) -> void:
	var pilot: StagePilot = stage.pilot
	pilot.carry = carry
	var shortcut: int = 1 << pilot.actions.bit(RivetCarry.SLOT_ACTIONS[slot])
	pilot.drive(stage, TickInput.new(shortcut))
	stage.intent.clear()
