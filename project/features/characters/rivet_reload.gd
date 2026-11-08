class_name RivetReload
extends RefCounted
## n9 it10: Rivet's drawn reload (the library's claw reload, REQUEST it9). A weapon with a
## rivet_reload_<weapon>.png under the art key shows it while CutRig.reload_k >= 0: the equipped
## sheet's layout, cells 0-4 the reload pose per facing (EQ_OCT), cells 5-7 the 3-frame reload at
## 3/4 toward right (magazine out, magazine in, ready) keyed by the reload phase. The left facings
## take rivet_reload_<weapon>_left.png (3 drawn views, never mirrored). A walk wins over it: a
## standing reload pose carried across the ground is the glide the owner rejected (DECISION
## rivet/reload-vs-walk); --rivet-reload=off keeps the at-rest cell through a reload (d9).

const PREFIX: String = "rivet_reload_"
const SEQ_OCT: int = 1
const SEQ_CELL: int = 5
const SEQ_FRAMES: int = 3
static var enabled: bool = true


## Standing (no walk grid): the drawn diagonal fire strip (RivetStrips.diag_or), else the reload.
static func held_or(rig: CutRig, art: String, weapon: StringName, path: String) -> String:
	return path_or(rig, art, weapon, RivetStrips.diag_or(rig, art, weapon, path))


## `path`, or the weapon's drawn reload strip while he reloads standing.
static func path_or(rig: CutRig, art: String, weapon: StringName, path: String) -> String:
	if not on(rig) or weapon == &"" or path.is_empty():
		return path
	var left: String = "_left" if RivetFrames.LEFT[RivetFrames.oct_of(rig)] == 1 else ""
	var file: String = RivetStrips.DIR + art + "/" + PREFIX + String(weapon) + left + ".png"
	return file if ResourceLoader.exists(file) else path


## True while a reload plays and the drawn reload is on.
static func on(rig: CutRig) -> bool:
	return enabled and rig.reload_k >= 0.0 and not rig.dead


## True when `card` shows a reload strip.
static func shows(card: Sprite2D) -> bool:
	var file: String = str(card.get_meta(RivetFrames.ON, "")).get_file() if card != null else ""
	return file.begins_with(PREFIX)


## The reload strip's cell for octant `o` (right strip: 8 cells, Vector2i(cell, flip)).
static func cell_of(rig: CutRig, o: int) -> Vector2i:
	if o == SEQ_OCT:
		return Vector2i(SEQ_CELL + clampi(int(rig.reload_k), 0, SEQ_FRAMES - 1), 0)
	return Vector2i(RivetFrames.EQ_OCT[o], 0)
