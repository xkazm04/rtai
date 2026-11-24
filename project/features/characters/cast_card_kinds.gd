class_name CastCardKinds
extends RefCounted
## Which shipped sheets are anchored (eight-row planted walks) or padded below the boot.
## Kept free of StreetCopWalk so the walk code can ask without a script cycle.


static func anchored(path: String) -> bool:
	return path.get_file() in [StreetMulroneyAnchors.EIGHT, CastWardenAnchors.EIGHT]


## Peg's noose hangs below her boots. Standing cells allow 32 texels below the ground.
static func padded(path: String) -> bool:
	return path.get_file().begins_with("appliance_warden_") and not path.ends_with("_fall.png")
