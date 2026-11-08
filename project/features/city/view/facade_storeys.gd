class_name FacadeStoreys
extends RefCounted
## A style's wall as whole storeys (n10 world, the owner's half height at the true 70 camera): the
## sheet keeps an upper and a ground storey row at the elevation's own proportions, and a wall
## stacks them from the ground up, showing as many storeys as fit instead of squashing a full
## tall elevation into a short wall. Render only.

## cell px of a storey's natural aspect (the sheet's); a wall scales them by at most these limits
const FIT_MIN: float = 0.72
const FIT_MAX: float = 1.3

var _sheet: Texture2D
var _bays: int
var _upper_h: float
var _ground_h: float
var _cell_w: float


func _init(sheet: Texture2D, bays: int, upper_h: float, ground_h: float) -> void:
	_sheet = sheet
	_bays = bays
	_upper_h = upper_h
	_ground_h = ground_h
	_cell_w = sheet.get_width() / float(bays)


## How many upper storeys fit `lift` px over the ground storey of a bay `w` px wide: the count that
## leaves the ratio natural height : lift nearest 1, within the limits (at least the ground storey).
static func upper_count(lift: float, ground: float, upper: float) -> int:
	if upper <= 0.0:
		return 0
	var best: int = 0
	var best_cost: float = INF
	for n: int in 8:
		var k: float = lift / (ground + upper * n)
		var cost: float = absf(log(k))
		if k >= FIT_MIN and k <= FIT_MAX and cost < best_cost:
			best = n
			best_cost = cost
	return best


## Draws a bay filling `wall` (its bottom the ground line): `pick` = the ground cell, the top cell.
func draw_bay(item: RID, wall: Rect2, pick: Vector2i) -> void:
	var w: float = wall.size.x
	var ground: float = w * _ground_h / _cell_w
	var upper: float = w * _upper_h / _cell_w
	var count: int = upper_count(wall.size.y, ground, upper)
	var k: float = wall.size.y / (ground + upper * count)
	var y: float = wall.end.y - ground * k
	var bottom: Rect2 = Rect2(pick.x * _cell_w, _upper_h, _cell_w, _ground_h)
	_blit(item, Rect2(wall.position.x, y, w, ground * k), bottom)
	for f: int in count:
		y -= upper * k
		var bay: int = (pick.y + f) % _bays
		var top: Rect2 = Rect2(bay * _cell_w, 0.0, _cell_w, _upper_h)
		_blit(item, Rect2(wall.position.x, y, w, upper * k), top)


func _blit(item: RID, dst: Rect2, src: Rect2) -> void:
	RenderingServer.canvas_item_add_texture_rect_region(item, dst, _sheet.get_rid(), src)
