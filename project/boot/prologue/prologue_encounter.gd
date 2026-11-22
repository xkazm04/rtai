class_name PrologueEncounter
extends ArenaHook
## Runs after combat and reads the interact edge StagePilot decoded for this tick.

var lines: PrologueLines


func _init(feed: PrologueLines) -> void:
	lines = feed


func step(stage: ArenaStage, tick: int) -> void:
	lines.advance(tick, stage.press_left)
