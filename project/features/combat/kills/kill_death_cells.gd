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
## n17 npc-react (owner: "policemen are changing sizes on hit"): the cops' pistol snap was drawn
## ~1.2-1.3 x the walk through its standing frames (film b_patrol64 t62 -> t63; its first frame
## also 0.12-0.32 m under the point). Each frame row draws at FIT_K[row] of its scale (the head
## thrown back and the buckle at the walk's size, the pitch forward halfway, the corpse as drawn:
## bodies keep their length), scaled about the feet, and the first row is lifted FIT_LIFT texture
## px per facing column so the boot stands on the point (JOURNAL n17 20:20-20:45). Keyed
## "<art>/<file>": the p55 snaps stand on the point already. FIT_ON false = as drawn (the before).
const FIT_ON: bool = true
const FIT_K: Dictionary[String, Array] = {
	"p70/cop_patrol_pistol_snap.png": [0.85, 0.85, 0.92, 1.0],
	"p70/cop_riot_pistol_snap.png": [0.8, 0.8, 0.9, 1.0],
	"p70/swat_pistol_snap.png": [0.8, 0.8, 0.9, 1.0],
	# n17: the machine pistol's stitch stood 1.09-1.41 x the walk by figure area (film
	# dr_machine_pistol t176 -> t177: 47 -> 58 px); its whirl and collapse at the walk, corpse 1.0
	"p70/cop_patrol_smg_stitch.png": [0.85, 0.8, 0.8, 0.88, 1.0],
	"p70/cop_riot_smg_stitch.png": [0.95, 0.93, 0.9, 0.93, 1.0],
	"p70/swat_smg_stitch.png": [0.86, 0.82, 0.8, 0.87, 1.0],
	"p70/ped_suit_smg_stitch.png": [0.92, 0.88, 0.88, 0.95, 1.0],
	# the gatling shred's first rows 1.11-1.25 x (film o_gatling t95: head ~35 vs ~30 px)
	"p70/cop_patrol_gatling_shred.png": [0.84, 0.8, 1.0],
	"p70/cop_riot_gatling_shred.png": [0.92, 0.88, 1.0],
	"p70/swat_gatling_shred.png": [0.84, 0.8, 1.0],
	"p70/ped_suit_gatling_shred.png": [0.88, 0.84, 1.0],
	# the baton overload's three standing rows 1.09-1.32 x by area (the arcs read as bulk: one k for
	# the three, so the jolt does not pump), the lying row as drawn
	"p70/cop_patrol_baton_overload.png": [0.87, 0.87, 0.87, 1.0],
	"p70/cop_riot_baton_overload.png": [0.95, 0.95, 0.95, 1.0],
	"p70/swat_baton_overload.png": [0.87, 0.87, 0.87, 1.0],
	"p70/ped_suit_baton_overload.png": [0.94, 0.94, 0.94, 1.0],
	# the nail pin's two standing rows (film o_gloria t63 -> t64: cap ~30 -> ~36 px) and the claw
	# throw's (o_claw_shock t126 -> t127: ~1.1 x; its flung arms over-read by area); lying as drawn
	"p70/cop_patrol_nail_pin.png": [0.87, 0.87, 1.0],
	"p70/cop_riot_nail_pin.png": [0.93, 0.93, 1.0],
	"p70/swat_nail_pin.png": [0.85, 0.85, 1.0],
	"p70/ped_suit_nail_pin.png": [0.94, 0.94, 1.0],
	"p70/cop_patrol_claw_throw.png": [0.92, 0.92, 1.0, 1.0],
	"p70/cop_riot_claw_throw.png": [0.95, 0.95, 1.0, 1.0],
	"p70/swat_claw_throw.png": [0.92, 0.92, 1.0, 1.0],
}
const FIT_LIFT: Dictionary[String, Array] = {
	"p70/cop_patrol_pistol_snap.png": [21, 15, 5, 10, 22],
	"p70/cop_riot_pistol_snap.png": [57, 25, 24, 15, 57],
	"p70/swat_pistol_snap.png": [17, 11, 5, 15, 18],
	"p70/cop_patrol_smg_stitch.png": [0, 0, 0, 0, 0],
	"p70/cop_riot_smg_stitch.png": [0, 0, 0, 0, 0],
	"p70/swat_smg_stitch.png": [0, 0, 0, 0, 0],
	"p70/ped_suit_smg_stitch.png": [0, 0, 0, 0, 0],
	"p70/cop_patrol_gatling_shred.png": [0, 0, 0, 0, 0],
	"p70/cop_riot_gatling_shred.png": [0, 0, 0, 0, 0],
	"p70/swat_gatling_shred.png": [0, 0, 0, 0, 0],
	"p70/ped_suit_gatling_shred.png": [0, 0, 0, 0, 0],
	"p70/cop_patrol_baton_overload.png": [0, 0, 0, 0, 0],
	"p70/cop_riot_baton_overload.png": [0, 0, 0, 0, 0],
	"p70/swat_baton_overload.png": [0, 0, 0, 0, 0],
	"p70/ped_suit_baton_overload.png": [0, 0, 0, 0, 0],
	"p70/cop_patrol_nail_pin.png": [0, 0, 0, 0, 0],
	"p70/cop_riot_nail_pin.png": [0, 0, 0, 0, 0],
	"p70/swat_nail_pin.png": [0, 0, 0, 0, 0],
	"p70/ped_suit_nail_pin.png": [0, 0, 0, 0, 0],
	"p70/cop_patrol_claw_throw.png": [0, 0, 0, 0, 0],
	"p70/cop_riot_claw_throw.png": [0, 0, 0, 0, 0],
	"p70/swat_claw_throw.png": [0, 0, 0, 0, 0],
}
const BASE: StringName = &"kill_death_cells_base"


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


## The slide (m) his body takes along the blow: row fx `cells_slide_m` while his own drawn cells
## show (a drawn corpse hangs off its anchor differently from the fall grid), else row `slide_m`.
static func slide_m_of(d: KillNewStyles.Death) -> float:
	if owns(d.cells) and d.extra.fx.has("cells_slide_m"):
		return d.extra.num("cells_slide_m", d.extra.slide_m)
	return d.extra.slide_m


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
	fit(d.cells, f)
	return f >= 0


## Draws frame `f` of a FIT grid at its row's size step, the first row lifted onto the point;
## any other grid as drawn.
static func fit(cells: Sprite2D, f: int) -> void:
	var key: String = key_of(cells)
	if not FIT_ON or not FIT_K.has(key):
		return
	if not cells.has_meta(BASE):
		cells.set_meta(BASE, cells.scale)
	var ks: Array = FIT_K[key]
	var k: float = ks[clampi(f, 0, ks.size() - 1)]
	var base: Vector2 = cells.get_meta(BASE)
	cells.scale = base * (k if f >= 0 else 1.0)
	var lifts: Array = FIT_LIFT[key]
	var lift: float = lifts[cells.frame_coords.x]
	cells.offset = Vector2(0.0, -lift) if f == 0 else Vector2.ZERO


## A grid's FIT key, "<art>/<file>" of its texture ("" = none).
static func key_of(cells: Sprite2D) -> String:
	if cells == null or cells.texture == null:
		return ""
	var path: String = cells.texture.resource_path
	return path.get_base_dir().get_file() + "/" + path.get_file()
