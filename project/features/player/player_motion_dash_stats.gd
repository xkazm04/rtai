class_name PlayerMotionDashStats
extends RefCounted
## Snapshot completed dash starts at the wave boundary. Each stage owns its own baseline.

const BASELINE: StringName = &"wave_start_dashes"


static func begin(stage: ArenaStage) -> void:
	stage.set_meta(BASELINE, stage.pilot.motion.dashes)


static func finish(stage: ArenaStage, row: Dictionary) -> void:
	var initial: int = stage.get_meta(BASELINE)
	row["dashes"] = stage.pilot.motion.dashes - initial
