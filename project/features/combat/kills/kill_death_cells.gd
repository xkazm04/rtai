class_name KillDeathCells
extends RefCounted
## An n16 death's OWN drawn cells (lane kills-new), render only: the asset lane draws a death per
## street kind as a grid of the kind's fall grid's 5 facings across and the death's frames down
## (tools/art/kill_cells_pack.py, the feet at the cell centre, the fall grid's px per metre). The
## row's `cells` names the grid per view art and card row and each frame's start tick; a victim
## with one draws it from the first tick in place of his fall grid (KillFallCells), facing the
## shooter (the drawing carries which way he falls; the grids' columns are the long fall's, whose
## figure looks the way its angle points), and the pose track keeps only the slide (fx
## `cells_lean`). A kind with none keeps the fall grid.

const META: StringName = &"kill_death_cells"


## The death's grid for a card row in a view art, as "<art>/<file>" (the art's own, else the
## fall grids' FALLBACK art's; "" = none).
static func path_of(extra: KillTrackRows.Extra, art: String, card_row: String) -> String:
	if extra.cells_at.is_empty():
		return ""
	return path_in(extra.grids, art, card_row)


## The file `table` (art -> card row -> file) names for a card row, as "<art>/<file>" ("" = none).
static func path_in(table: Dictionary, art: String, card_row: String) -> String:
	for a: String in [art, StreetWalkerFall.FALLBACK]:
		var v: Variant = table.get(a, {})
		if not v is Dictionary:
			continue
		var rows: Dictionary = v
		if rows.has(card_row):
			return a + "/" + str(rows[card_row])
	return ""


## The frame row at `age` ticks: the last frame whose start tick has passed (-1 before the first).
static func frame_at(extra: KillTrackRows.Extra, age: int) -> int:
	var f: int = -1
	for i: int in extra.cells_at.size():
		if age >= extra.cells_at[i]:
			f = i
	return f


## True when `cells` is a death's own grid (not the victim's fall grid).
static func owns(cells: Sprite2D) -> bool:
	return cells != null and cells.has_meta(META)


## The share of the pose track's lean a death keeps on its drawn frames: 1 for a fall grid, the
## row's fx `cells_lean` (default 0: the drawing holds the pose) for its own cells.
static func lean_of(d: KillNewStyles.Death) -> float:
	return d.extra.num("cells_lean", 0.0) if owns(d.cells) else 1.0


## The way his own drawn cells look (world rad): at the shooter, back up the shot; from frame
## `cells_turn_from` (row fx, -1 = never) along the shot, so the drawn corpse (laid head the way
## its figure looked) lies knocked back along the blow.
static func face_of(d: KillNewStyles.Death, frame: int = -1) -> float:
	var turn: int = roundi(d.extra.num("cells_turn_from", -1.0))
	if turn >= 0 and frame >= turn:
		return d.dir.angle()
	return (-d.dir).angle()


## Shows his own drawn frame this tick (the start ticks; the pin's by its case) facing the shooter
## (the stitch: then its whirl), the copy of his standing card hidden. True once a frame shows.
static func step(d: KillNewStyles.Death, age: int) -> bool:
	var f: int = frame_at(d.extra, age)
	if d.row.style == &"pin":
		f = KillPinArt.frame(d, age)
	KillNewStyles.show_cells(d, f >= 0)
	d.cells.frame_coords = Vector2i(d.cells.frame_coords.x, maxi(f, 0))
	var look: float = face_of(d, f)
	if d.row.style == &"stitch":  # at the shooter, then the drawn spin turned a full circle
		look = KillStitchArt.facing(d, age)
	KillFallCells.face(d.cells, look)
	return f >= 0
