class_name StreetFallBetween
extends RefCounted
## n11 combat (critique it6: from the mid-fall frame to the lying one the arms and the head jumped,
## a pose pop at the game's view). A kind here has the asset lane's two in-between cells drawn
## (knees and hands landing, chest down, one leg bent) as rows 2 and 3 of a 5-row fall grid
## (tools/art/street_fall_between.py): StreetWalkerFall.path_of draws that grid instead, its
## frames on AT. The lying frame still starts at StreetWalkerFall.FALL_AT's last, so the corpse
## hand-over (StreetDeadPlan, StreetDeadHeading) is unchanged. ON false = the 3-row grids.

const ON: bool = true
## The 3-row grid -> its 5-row grid with the in-betweens (both "<art>/<file>").
const GRIDS: Dictionary[String, String] = {
	"p70/cop_patrol_long_fall.png": "p70/cop_patrol_between_fall.png",
}
const FRAMES: int = 5
## Each row's start, of the death family's progress: buckle, mid-fall, fall1, fall2, lying.
const AT: PackedFloat32Array = [0.0, 0.18, 0.26, 0.33, 0.4]


## The grid drawn for a fall grid path: its in-between grid when it has one.
static func swap(path: String) -> String:
	return GRIDS[path] if ON and GRIDS.has(path) else path


## The fall frames a grid at `path` has down.
static func rows_of(path: String) -> int:
	return FRAMES if path.ends_with("_between_fall.png") else StreetWalkerFall.FALL_FRAMES


## True when the card draws a fall grid (either row count).
static func is_fall_card(card: Sprite2D) -> bool:
	return card.vframes == StreetWalkerFall.FALL_FRAMES or card.vframes == FRAMES
