@abstract class_name QuestDriver
extends RefCounted
## What plays a contract in a headless quest scenario (QuestPlay): the scripted stand-in for
## the player and for any world system that does not exist yet. prepare() runs before the
## contract is offered (the world as the previous scene left it), act() once per tick before
## the sim steps, done() ends the play.


## The world before the offer. Default: nothing to set up.
func prepare() -> void:
	pass


@abstract func act() -> void

@abstract func done() -> bool


## What this driver stands in for, one line per stubbed system (scenario evidence).
func stubbed() -> Array[String]:
	return []
