class_name WeaponArtKey
extends RefCounted
## Resolve gameplay ids before looking up held, showcase and strip art.


## Quest and replay ids predate the snake_case asset filenames.
static func of(weapon: StringName) -> StringName:
	return &"assault_rifle" if weapon == &"assault-rifle" else weapon
