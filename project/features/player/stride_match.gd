class_name StrideMatch
extends RefCounted
## Right-profile stride proposal. Re-measure with tools/film/foot_slide.py --strips after a recut.
## Each row holds the boot travel in packed texels for the two stances, then the number of pose
## advances between the contact and release samples and the number of columns in the strip.
## Right-profile walk8 uses contacts 0/4 through 3/7. Run8 releases at 2/6 before flight.

const ROOT: String = "res://features/characters/art/view/"
const PROFILE_ROW: int = 2
const STANCES: Dictionary[String, Vector4] = {
	ROOT + "p55/rivet_walk8.png": Vector4(34.0, 28.5, 3, 8),
	ROOT + "p55/rivet_walk_eq_pistol.png": Vector4(21.5, 21.0, 1, 4),
	ROOT + "p55/rivet_run8.png": Vector4(86.0, 84.5, 2, 8),
	ROOT + "p55/rivet_run8_eq_pistol.png": Vector4(86.0, 85.5, 2, 8),
	ROOT + "p70/rivet_walk8.png": Vector4(32.0, 30.5, 3, 8),
	ROOT + "p70/rivet_walk_eq_pistol.png": Vector4(21.5, 30.5, 1, 4),
	ROOT + "p70/rivet_run8.png": Vector4(104.5, 98.0, 2, 8),
	ROOT + "p70/rivet_run8_eq_pistol.png": Vector4(103.5, 98.0, 2, 8),
}


## Ground distance for one full cycle at this stance's cadence. Output units follow px_per_texel.
static func cycle_length(travel: float, advances: int, cols: int, px_per_texel: float) -> float:
	if advances <= 0 or cols <= 0 or travel <= 0.0 or px_per_texel <= 0.0:
		return 0.0
	return travel * px_per_texel * cols / advances


## Cycles per second. Speed and cycle length must use the same distance unit.
static func cadence(speed: float, length: float, cap: float) -> float:
	return clampf(speed / length, 0.0, maxf(cap, 0.0)) if length > 0.0 else 0.0


## The displayed support foot selects the next interval. Other directions and art keep their cycle.
static func profile_cycle(card: Sprite2D, px_per_texel: float, fallback: float) -> float:
	if card == null or card.texture == null or card.frame_coords.y != PROFILE_ROW:
		return fallback
	var row: Vector4 = STANCES.get(card.texture.resource_path, Vector4.ZERO)
	if int(row.w) != card.hframes or px_per_texel <= 0.0:
		return fallback
	var travel: float = row.x if card.frame_coords.x * 2 < card.hframes else row.y
	return cycle_length(travel, int(row.z), card.hframes, px_per_texel)
