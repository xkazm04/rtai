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
	"p70/cop_riot_long_fall.png": "p70/cop_riot_between_fall.png",
	"p70/swat_long_fall.png": "p70/swat_between_fall.png",
	"p70/ped_suit_long_fall.png": "p70/ped_suit_between_fall.png",
	"p70/thug_long_fall.png": "p70/thug_between_fall.png",
	"p70/ped_worker_long_fall.png": "p70/ped_worker_between_fall.png",
	"p70/ped_hood_long_fall.png": "p70/ped_hood_between_fall.png",
	"p70/ped_cap_long_fall.png": "p70/ped_cap_between_fall.png",
	"p70/ped_elder_long_fall.png": "p70/ped_elder_between_fall.png",
	"p70/ped_hat_long_fall.png": "p70/ped_hat_between_fall.png",
	"p70/ped_jogger_long_fall.png": "p70/ped_jogger_between_fall.png",
	"p70/ped_punk_long_fall.png": "p70/ped_punk_between_fall.png",
	"p70/ped_shopper_long_fall.png": "p70/ped_shopper_between_fall.png",
}
const FRAMES: int = 5
## Each row's start, of the death family's progress: buckle, mid-fall, fall1, fall2, lying.
const AT: PackedFloat32Array = [0.0, 0.18, 0.26, 0.33, 0.4]
## The in-betweens land face down, so the body then lies in a face-down pose (StreetDeadPlan's A
## and D): a back pose after them flipped the body over in one frame (it14 film).
const FACE_DOWN: PackedInt32Array = [0, 3]

## The head's screen heading (deg, y down) of each column's chest-down and lying rows, as drawn:
## down, down-right, right, up-right, and the away column lies up-right too.
const HEAD_DEG: PackedFloat32Array = [90.0, 45.0, 0.0, -45.0, -45.0]
## KEEP_HEADING false = the corpse takes StreetDeadHeading's heading off the blow (it14: it turned
## about 120 degrees from the chest-down cell in one frame).
const KEEP_HEADING: bool = true
## it18: the dead70 face-down diagonals are drawn at about 55 degrees on screen, this grid's
## chest-down and lying rows at about 22, so any dead70 cell still turned at the hand-over. Such a
## body lies as its own grid's lying row (drawn face down for this camera, at this column's angle).
## LIE_IN_GRID false = the dead70 cell nearest the column's heading.
const LIE_IN_GRID: bool = true


## The grid drawn for a fall grid path: its in-between grid when it has one.
static func swap(path: String) -> String:
	return GRIDS[path] if ON and GRIDS.has(path) else path


## The fall frames a grid at `path` has down.
static func rows_of(path: String) -> int:
	return FRAMES if path.ends_with("_between_fall.png") else StreetWalkerFall.FALL_FRAMES


## True when the card draws a fall grid (either row count).
static func is_fall_card(card: Sprite2D) -> bool:
	return card.vframes == StreetWalkerFall.FALL_FRAMES or card.vframes == FRAMES


## True when the card fell through the drawn in-betweens (so it lies face down).
static func lands_face_down(card: Sprite2D) -> bool:
	return card.texture != null and card.texture.resource_path.ends_with("_between_fall.png")


## The unit screen direction the head lies in on a fall card's column (mirrored with the card).
static func head_of(card: Sprite2D) -> Vector2:
	var h: Vector2 = Vector2.from_angle(deg_to_rad(HEAD_DEG[clampi(card.frame_coords.x, 0, 4)]))
	return Vector2(-h.x, h.y) if card.flip_h else h


## `card`'s lying sprite (StreetDeadPlan.NODE, so the rest layer keeps it): its own grid
## (`grid`), else the drawn sheet `drawn`, else the plan poses at `path`.
static func lying_sprite(card: Sprite2D, path: String, drawn: String, grid: bool) -> Sprite2D:
	if grid:
		return StreetDead70.sprite(card, card.texture.resource_path, card.hframes, card.vframes)
	if drawn.is_empty():
		return StreetDead70.sprite(card, path, StreetDeadPlan.POSES, 1)
	return StreetDead70.sprite(card, drawn, StreetDead70.COLS, StreetDead70.ROWS)


## Shows the lying row of `card`'s column on `plan`, where the card stands, moved by `shift` (px:
## the push off the neighbours, the pull back from a wall) and rocked by `turn` (rad).
static func lie(card: Sprite2D, plan: Sprite2D, shift: Vector2, turn: float) -> void:
	plan.frame_coords = Vector2i(card.frame_coords.x, FRAMES - 1)
	plan.flip_h = card.flip_h
	plan.global_transform = Transform2D(turn, card.global_scale, 0.0, card.global_position + shift)
