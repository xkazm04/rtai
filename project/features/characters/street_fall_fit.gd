class_name StreetFallFit
extends RefCounted
## n17 npc-react (owner: "policemen are changing sizes on hit"; DEFECTS 22): the fall grids (the
## 5-row between grids: buckle, mid-fall, knees, chest down, lying) were drawn 1.04-1.24 x their
## kind's walk on the buckle and mid-fall rows (tools/art/street_fall_size.py, by figure area at the
## sizes the game draws both), so a dying man grew on the frame after the thrown-back hit cell (film
## fall_std_cop_head_cap 64 px/m t67 -> t68). Each row draws at FIT_K[row] of its scale, about the
## feet (the cell centre): the buckle and mid-fall at the walk, the knees halfway to the chest-down
## row, the chest-down and lying rows as drawn (owner n11: bodies keep their length). Keyed
## "<art>/<file>"; a grid absent = as drawn. FIT_ON false = as drawn (the before). Render only.

const FIT_ON: bool = true
const FIT_K: Dictionary[String, Array] = {
	"p70/cop_patrol_between_fall.png": [0.96, 0.89, 0.97, 1.0, 1.0],
	"p70/swat_between_fall.png": [0.94, 0.87, 0.99, 1.0, 1.0],
	"p70/ped_suit_between_fall.png": [1.0, 0.96, 0.96, 1.0, 1.0],
	"p70/ped_hat_between_fall.png": [1.0, 0.91, 0.96, 1.0, 1.0],
	"p70/ped_hood_between_fall.png": [0.99, 0.9, 0.94, 1.0, 1.0],
	"p70/ped_cap_between_fall.png": [1.0, 0.94, 1.0, 1.0, 1.0],
	"p70/ped_punk_between_fall.png": [0.86, 0.8, 0.93, 1.0, 1.0],
	"p70/ped_shopper_between_fall.png": [0.94, 0.86, 0.93, 1.0, 1.0],
	"p70/ped_jogger_between_fall.png": [1.0, 0.93, 0.94, 1.0, 1.0],
	"p70/ped_worker_between_fall.png": [1.0, 0.93, 1.0, 1.0, 1.0],
}
const BASE: StringName = &"street_fall_fit_base"


## The size step the card's current row draws at (1.0: no fit for its grid, or FIT_ON off).
static func k(card: Sprite2D) -> float:
	if not FIT_ON or card == null or card.texture == null:
		return 1.0
	var path: String = card.texture.resource_path
	var key: String = path.get_base_dir().get_file() + "/" + path.get_file()
	if not FIT_K.has(key):
		return 1.0
	var ks: Array = FIT_K[key]
	return ks[clampi(card.frame_coords.y, 0, ks.size() - 1)]


## Draws `cells` (a death copy's fall grid, KillFallCells) at its row's size step: the scale it was
## given at the cut times k.
static func fit(cells: Sprite2D) -> void:
	if not cells.has_meta(BASE):
		cells.set_meta(BASE, cells.scale)
	var base: Vector2 = cells.get_meta(BASE)
	cells.scale = base * k(cells)
