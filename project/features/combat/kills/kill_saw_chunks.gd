class_name KillSawChunks
extends RefCounted
## n16 kills-polish item 3 ("a chainsaw grind that throws drawn chunks"; asset lane A5, it418):
## through the grind the saw's bite throws the row's `saw_chunks` drawn pieces (meat, bone chips,
## a rib, a tooth), one every grind / n ticks, out through the body away from the saw. Each flies
## FLY_TICKS on a low arc, spinning, and lands to lie on the street (the aftermath) for as long as
## KillSplitFx keeps the kill. Render only: the cell, the throw and the spin come from a hash of
## the serial and the chunk, so a replay draws the same pieces. `--saw-chunks=off` = the before.

const ART: Texture2D = preload("res://features/combat/weapons/art/gore/saw_chunks.png")
## The cells thrown in turn (tools/art/saw_chunks_cells.py: 0-3 meat, 4-5 bone, 6 rib, 9 tooth;
## the cloth scraps 7-8 are a kind's and stay out).
const ORDER: Array[int] = [0, 4, 1, 6, 2, 5, 3, 9]
## A cell's side on the street (m: the largest piece ~0.42 m, a comic oversize to read at 32;
## at 0.36 the meat sank into the blood pool at 64 px/m).
const CELL_M: float = 0.46
const FLY_TICKS: int = 18
const ARC_M: float = 0.55
## How far a chunk lands (m) and its spread about the throw (rad).
const THROW_M: Vector2 = Vector2(1.3, 2.6)
const SPREAD: float = 1.5

static var _off: int = -1


## True under `--saw-chunks=off` (no chunks: the before).
static func off() -> bool:
	if _off < 0:
		_off = 1 if ArenaArgs.parse().text("--saw-chunks") == "off" else 0
	return _off == 1


## Draws `count` chunks of a grind born at `born` lasting `ticks`, thrown from `bite` (px) along
## `back` (rad), at sim tick `tick`.
static func draw(
	ci: CanvasItem, serial: int, bite: Vector2, back: float, timing: Vector4i, ppm: float
) -> void:
	var born: int = timing.x
	var ticks: int = timing.y
	var count: int = timing.z
	var tick: int = timing.w
	if count <= 0 or off():
		return
	var cell: float = ART.get_height()
	var side: float = CELL_M * ppm
	for i: int in count:
		var age: int = tick - (born + i * maxi(ticks, 1) / count)
		if age < 0:
			continue
		var s: float = minf(float(age) / FLY_TICKS, 1.0)
		var a: float = back + (KillSplitFx._h(serial, i * 13 + 5100) - 0.5) * SPREAD
		var far: float = lerpf(THROW_M.x, THROW_M.y, KillSplitFx._h(serial, i * 13 + 5200)) * ppm
		var up: float = 4.0 * ARC_M * ppm * s * (1.0 - s)
		var p: Vector2 = bite + Vector2.from_angle(a) * far * s - Vector2(0.0, up)
		var spin: float = (KillSplitFx._h(serial, i * 13 + 5300) - 0.5) * 14.0 * s
		var k: int = ORDER[i % ORDER.size()]
		ci.draw_set_transform(p, spin, Vector2.ONE)
		ci.draw_texture_rect_region(
			ART, Rect2(-side * 0.5, -side * 0.5, side, side), Rect2(cell * k, 0.0, cell, cell)
		)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
