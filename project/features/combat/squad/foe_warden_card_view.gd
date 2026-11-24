class_name FoeWardenCardView
extends RefCounted
## The yard supplies its current holder before the cast feed samples each simulation tick.
## A release (timeout, roll, melee escape or death) starts recovery on that holder alone.
const ID: StringName = &"appliance_warden"
const HELD_FROM: StringName = &"cast_catch_from"
const RELEASED: StringName = &"cast_catch_released"


static func set_catch(h: Fighter, held: bool, tick: int) -> void:
	if held:
		if not h.has_meta(HELD_FROM):
			h.set_meta(HELD_FROM, tick)
	elif h.has_meta(HELD_FROM):
		h.remove_meta(HELD_FROM)
		h.set_meta(RELEASED, tick)


static func attack_row(h: Fighter, mind: SquadMind, tick: int) -> int:
	if h.has_meta(HELD_FROM):
		return 1 if h.get_meta(HELD_FROM) == tick else 2
	if h.swing_left > 0:
		return 0
	if h.has_meta(RELEASED):
		var release_tick: int = h.get_meta(RELEASED)
		var since_release: int = tick - release_tick
		if since_release < CastCardPose.RECOVERY_TICKS:
			return 3
	if mind == null or h.swing_tick < 0 or mind.agent.cooldown <= 0:
		return -1
	var age: int = tick - h.swing_tick - mind.agent.arch.telegraph_ticks
	if age == 0:
		return 1
	return 3 if age > 0 and age <= CastCardPose.RECOVERY_TICKS else -1
