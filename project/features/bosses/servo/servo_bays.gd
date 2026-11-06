class_name ServoBays
extends RefCounted
## Where the rack art's bays are, and the docked drone drawn in one (render only). The sim's
## cells (ServoRack.cell_pos: the drones' launch points) sit up to 0.36 m off the art's bays
## (rows 0.5 m apart, the art's 0.65 m), so the docked drones and the empty bays are drawn on the
## art's bay centres (rack3.png, measured from its hubs) and the art's printed quad drone shows
## round the docked hub, the sheet's quad drones in the bays. Three rows only (the data's 3).

const ART_PPM: float = 96.0
## rack3.png's bay centres (px from its centre across, px from its top down; inner column last).
const BAY_X_PX: Array[float] = [-70.0, -0.7, 69.5]
const BAY_Y_PX: Array[float] = [163.4, 101.0, 38.2]
## rack3.png's top edge below the wing's centre (px): its bottom sits on rack.png's (141 / 2).
const TOP_PX: float = -133.5
## The art's rotor discs round each hub (px off the hub, px radius).
const ROTOR_OFF_PX: Vector2 = Vector2(18.0, 13.0)
const ROTOR_R_PX: float = 11.0

var rack: ServoRack = null
## The wing's centre across from the body (m) and behind it (m), as ServoRig._wings draws it.
var wing_c_m: float = 0.0
var wing_back_m: float = 0.765
var px: float = 32.0
## The docked hub's side (m).
var hub_m: float = 0.22


## True when the art bays apply (three rows, the data's rack); else draw on rack.cell_pos.
func on_art() -> bool:
	return rack.rows() == 3


## The rig's wing side of cell `i`: +1 for the rack's columns with across < 0.
func side(i: int) -> float:
	return 1.0 if i % rack.cols() < rack.cols() / 2 else -1.0


## Bay `i`'s centre on the ground for a body at `o` facing `fwd`, drawn `k` big. `side` is the
## rig's (fwd.orthogonal()): the rack's columns with across < 0 lie on its +1 side.
func pos(i: int, o: Vector2, fwd: Vector2, k: float) -> Vector2:
	if not on_art():
		return rack.cell_pos(i)
	var per_row: int = rack.cols()
	var col: int = i % per_row
	var half: int = per_row / 2
	var s: float = side(i)
	var inner: int = (half - 1 - col) if col < half else (col - half)
	var x_px: float = BAY_X_PX[BAY_X_PX.size() - 1 - mini(inner, BAY_X_PX.size() - 1)]
	var row: int = mini(floori(float(i) / per_row), BAY_Y_PX.size() - 1)
	var y_px: float = TOP_PX + BAY_Y_PX[row]
	var across: float = wing_c_m + x_px * k / ART_PPM * -1.0
	return o + fwd.orthogonal() * s * across + fwd * (-wing_back_m + y_px * k / ART_PPM)


## Every cell's bay centre (`on`, three rows), or the sim's cells; the +1 wing shakes.
func points(o: Vector2, fwd: Vector2, k: float, shake: Vector2, on: bool) -> Array[Vector2]:
	var art: bool = on and on_art()
	var pts: Array[Vector2] = []
	for i: int in rack.state.size():
		var at: Vector2 = pos(i, o, fwd, k) if art else rack.cell_pos(i)
		pts.append(at + (shake if art and side(i) > 0.0 else Vector2.ZERO))
	return pts


## The docked drone: light rotor rings over the art's round an ink-rimmed cream hub.
func docked(c: CanvasItem, at_px: Vector2, rot: float, k: float, tint: Color) -> void:
	var pal: PaletteTokens = PaletteTokens.shared()
	var cream: Color = pal.color(&"paper_2") * tint
	var sc: float = k * px / ART_PPM
	var h: float = hub_m * 0.5 * k * px
	c.draw_set_transform(at_px, rot)
	for sx: float in [-1.0, 1.0]:
		for sy: float in [-1.0, 1.0]:
			var rc: Vector2 = Vector2(ROTOR_OFF_PX.x * sx, ROTOR_OFF_PX.y * sy) * sc
			c.draw_arc(rc, ROTOR_R_PX * sc, 0.0, TAU, 14, cream, 1.0)
	c.draw_rect(Rect2(-h - 1.0, -h - 1.0, h * 2.0 + 2.0, h * 2.0 + 2.0), pal.color(&"ink") * tint)
	c.draw_rect(Rect2(-h, -h, h * 2.0, h * 2.0), cream)
	c.draw_set_transform(Vector2.ZERO)
