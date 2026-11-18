class_name WeaponArtKey
extends RefCounted
## Resolve gameplay ids before looking up held, showcase and strip art.

static var _rifle_key: StringName = &""


## The gameplay id predates the asset schema. Only its own spelling counts as own art.
static func of(weapon: StringName) -> StringName:
	if weapon != &"assault-rifle":
		return weapon
	if _rifle_key == &"":
		var alias: StringName = ArsenalTable.shipped().art_id(weapon)
		_rifle_key = alias if alias == String(weapon).replace("-", "_") else weapon
	return _rifle_key
