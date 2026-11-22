class_name GhostReelInput
extends InputSource

var stage: ArenaStage
var reel: GhostReel


static func attach(p_stage: ArenaStage, actions: PlayerActions) -> GhostReelInput:
	var i: GhostReelInput = GhostReelInput.new()
	i.stage = p_stage
	p_stage.pilot.ghosts.transform_unlocked = true
	i.reel = GhostReel.new(actions)
	p_stage.hooks.append(i.reel)
	return i


func sample(tick: int) -> TickInput:
	return reel.sample(stage, tick)
