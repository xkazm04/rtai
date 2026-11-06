class_name VehicleViews
extends RefCounted
## n8 vehicles: which drawn rotation of a car card shows for a heading (VehicleCards). Five views
## per half turn (nose to the camera, three-quarter toward, side, three-quarter away, tail; 45
## degrees apart, the other half mirrored), or nine for a FINE row: the four 22.5-degree
## in-betweens sit in columns 5-8 (A-D: between views 0-1, 1-2, 2-3, 3-4).

const COLS: int = 5
const FINE_COLS: int = 9
const VIEW_DEG: float = 45.0
const FINE_DEG: float = 22.5
## The atlas cell's side in px (tools/art/vehicle_cards.py CELL_PX): the atlas width / it = columns.
const CELL_PX: int = 448
## Per view art key, the rows whose in-betweens are drawn (vehicle_cards.py prints them; the unit
## test checks them against the atlas). Missing: five views a row.
const FINE: Dictionary[String, PackedInt32Array] = {"p70": [0, 1, 2, 4, 7, 8]}


## The view for a nose angle `a_deg` (ground, y down: 90 = nose down the screen): x = the cell
## column (0-4 drawn; 5-8 the in-betweens when `fine`), y = 1 when mirrored, z = the view's own
## nose angle (the card turns by the rest).
static func view_of(a_deg: float, fine: bool = false) -> Vector3:
	var a: float = wrapf(a_deg, -180.0, 180.0)
	var flip: bool = absf(a) > 90.0
	var s: float = 1.0 if a >= 0.0 else -1.0
	var a2: float = (s * 180.0 - a) if flip else a
	var step: float = FINE_DEG if fine else VIEW_DEG
	var i: int = clampi(roundi((90.0 - a2) / step), 0, roundi(180.0 / step))
	var c: float = 90.0 - step * i
	var col: int = i
	if fine:
		col = (i >> 1) if i % 2 == 0 else COLS + (i >> 1)
	return Vector3(col, 1.0 if flip else 0.0, (s * 180.0 - c) if flip else c)


## The drawn nose angle (degrees, ground) of column `col` in its unmirrored half.
static func nose_deg(col: int) -> float:
	return 90.0 - VIEW_DEG * col if col < COLS else 67.5 - VIEW_DEG * (col - COLS)


## The columns of card atlas `tex` (COLS when null).
static func cols_of(tex: Texture2D) -> int:
	return COLS if tex == null else maxi(COLS, floori(float(tex.get_width()) / CELL_PX))


## The FINE rows of the atlas for view art key `art`, `cols` wide (none under FINE_COLS).
static func fine_rows(cols: int, art: String) -> PackedInt32Array:
	if cols < FINE_COLS or not FINE.has(art):
		return PackedInt32Array()
	return FINE[art]
