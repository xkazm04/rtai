class_name CastCardKinds
extends RefCounted
## Which shipped sheets are anchored (eight-row planted walks) or padded below the boot.
## Kept free of StreetCopWalk so the walk code can ask without a script cycle.
## The riot, SWAT and lancer eights share the sergeant's centred touchdown.
const CENTRE_STANCE: bool = true
const RUN_MPS: float = 4.0


static func anchored(path: String) -> bool:
	return (
		path.get_file()
		in [
			StreetMulroneyAnchors.EIGHT,
			CastWardenAnchors.EIGHT,
			CastRiotAnchors.EIGHT,
			CastSwatAnchors.EIGHT,
			CastSwatAnchors.RUN_EIGHT,
			CastLancerAnchors.EIGHT,
			CastGunnerAnchors.EIGHT,
			CastDoorAnchors.SHEET,
		]
	)


## Peg's noose hangs below her boots. Standing cells allow 32 texels below the ground.
static func padded(path: String) -> bool:
	var file: String = path.get_file()
	return (
		(file.begins_with("appliance_warden_") or file.begins_with("robot_gunner_"))
		and not file.ends_with("_fall.png")
	)


## The shipped four-drawing sheet a foe's eight-drawing walk replaces ("" for any other file).
static func four_of(file: String) -> String:
	match file:
		CastRiotAnchors.EIGHT:
			return CastRiotAnchors.FOUR
		CastSwatAnchors.EIGHT, CastSwatAnchors.RUN_EIGHT:
			return CastSwatAnchors.FOUR
		CastLancerAnchors.EIGHT:
			return CastLancerAnchors.FOUR
		CastGunnerAnchors.EIGHT:
			return CastGunnerAnchors.FOUR
	return ""


## Sole and torso marks per facing and drawing for the foe eights (empty for any other file).
static func foe_marks(file: String, low: bool) -> Array[Vector4]:
	match file:
		CastRiotAnchors.EIGHT:
			return CastRiotAnchors.WALK55 if low else CastRiotAnchors.WALK70
		CastSwatAnchors.EIGHT:
			return CastSwatAnchors.WALK55 if low else CastSwatAnchors.WALK70
		CastSwatAnchors.RUN_EIGHT:
			return CastSwatAnchors.RUN55 if low else CastSwatAnchors.RUN70
		CastLancerAnchors.EIGHT:
			return CastLancerAnchors.WALK55 if low else CastLancerAnchors.WALK70
		CastGunnerAnchors.EIGHT:
			return CastGunnerAnchors.WALK55 if low else CastGunnerAnchors.WALK70
		CastDoorAnchors.SHEET:
			return CastDoorAnchors.WALK55 if low else CastDoorAnchors.WALK70
	return []


## Metres of ground one drawing spans on a foe eight.
static func foe_step(file: String) -> float:
	match file:
		CastRiotAnchors.EIGHT:
			return CastRiotAnchors.WALK_STEP_M
		CastSwatAnchors.EIGHT:
			return CastSwatAnchors.WALK_STEP_M
		CastSwatAnchors.RUN_EIGHT:
			return CastSwatAnchors.RUN_STEP_M
		CastLancerAnchors.EIGHT:
			return CastLancerAnchors.WALK_STEP_M
		CastGunnerAnchors.EIGHT:
			return CastGunnerAnchors.WALK_STEP_M
		CastDoorAnchors.SHEET:
			return CastDoorAnchors.WALK_STEP_M
	return 0.0


## Drawings per facing: the door carrier's shipped four, else eight for an eight or anchored sheet.
static func rows(path: String, patrol_eight: bool) -> int:
	if path.get_file() == CastDoorAnchors.SHEET:
		return 4
	return 8 if patrol_eight or anchored(path) else 4


## The door carrier keeps its shipped 192 px sheet; other anchored sheets are 256 px.
static func cell_ratio(path: String, ratio: float) -> float:
	return 1.0 if path.get_file() == CastDoorAnchors.SHEET else ratio


## A walk cell's fill: the padded and eight-drawing cells carry the 256/192 cell ratio.
static func fill(path: String, table: Dictionary[String, float], ratio: float) -> float:
	var file: String = path.get_file()
	if file == StreetMulroneyAnchors.EIGHT or padded(path):
		return ratio
	var four: String = four_of(file)
	var key: String = path.get_base_dir().get_file() + "/" + (four if four else file)
	return table.get(key, 1.0) * (ratio if four else 1.0)


## The eight-drawing sheet a riot or SWAT host draws in place of its shipped four ("" = none).
## SWAT swaps to its run above the patrol's run speed.
static func eight_for(file: String, speed_mps: float) -> String:
	if file in [CastRiotAnchors.FOUR, CastRiotAnchors.EIGHT]:
		return CastRiotAnchors.WALK
	if file not in [CastSwatAnchors.FOUR, CastSwatAnchors.EIGHT, CastSwatAnchors.RUN_EIGHT]:
		return ""
	var run: bool = speed_mps > RUN_MPS and CastSwatAnchors.WALK == CastSwatAnchors.EIGHT
	return CastSwatAnchors.RUN_EIGHT if run else CastSwatAnchors.WALK


static func running(file: String, patrol_run: String) -> bool:
	return file in [patrol_run, CastSwatAnchors.RUN_EIGHT]
