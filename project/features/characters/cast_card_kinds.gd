class_name CastCardKinds
extends RefCounted
## Which shipped sheets are anchored (eight-row planted walks) or padded below the boot.
## Kept free of StreetCopWalk so the walk code can ask without a script cycle.
## The riot, SWAT and lancer eights share the sergeant's centred touchdown.
const CENTRE_STANCE: bool = true


static func anchored(path: String) -> bool:
	return (
		path.get_file()
		in [
			StreetMulroneyAnchors.EIGHT,
			CastWardenAnchors.EIGHT,
			CastRiotAnchors.EIGHT,
		]
	)


## Peg's noose hangs below her boots. Standing cells allow 32 texels below the ground.
static func padded(path: String) -> bool:
	return path.get_file().begins_with("appliance_warden_") and not path.ends_with("_fall.png")


## The shipped four-drawing sheet a foe's eight-drawing walk replaces ("" for any other file).
static func four_of(file: String) -> String:
	match file:
		CastRiotAnchors.EIGHT:
			return CastRiotAnchors.FOUR
	return ""


## Sole and torso marks per facing and drawing for the foe eights (empty for any other file).
static func foe_marks(file: String, low: bool) -> Array[Vector4]:
	match file:
		CastRiotAnchors.EIGHT:
			return CastRiotAnchors.WALK55 if low else CastRiotAnchors.WALK70
	return []


## Metres of ground one drawing spans on a foe eight.
static func foe_step(file: String) -> float:
	match file:
		CastRiotAnchors.EIGHT:
			return CastRiotAnchors.WALK_STEP_M
	return 0.0


## A walk cell's fill: the padded and eight-drawing cells carry the 256/192 cell ratio.
static func fill(path: String, table: Dictionary[String, float], ratio: float) -> float:
	var file: String = path.get_file()
	if file == StreetMulroneyAnchors.EIGHT or padded(path):
		return ratio
	var four: String = four_of(file)
	var key: String = path.get_base_dir().get_file() + "/" + (four if four else file)
	return table.get(key, 1.0) * (ratio if four else 1.0)


## The eight-drawing sheet a riot (later SWAT) host draws in place of its four ("" = none).
static func eight_for(file: String, _speed_mps: float) -> String:
	return CastRiotAnchors.WALK if file in [CastRiotAnchors.FOUR, CastRiotAnchors.EIGHT] else ""
