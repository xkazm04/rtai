class_name RivetGunDiag
extends RefCounted
## n17 rivet-strike (DEFECTS #11): a gun shot at a diagonal octant drew the side fire cell, its
## arm level at 0 deg while the round left at 30-45 deg. Where the asset lane drew the gun's
## diagonal fire cells (rivet_eq_<gun>_diag.png, it458: RivetStrips' DIAG order, 3/4 toward right,
## away right, toward left, away left; the gun in his right hand in all four) the diagonal octants
## fire them (RivetStrips.diag_or, as the flamer's), and a shot counts as drawn when it is aimed
## within GUN_TOL of the drawn gun's screen angle (DEG, measured: the flash's biggest hot blob, from
## its root nearest the body to its far tip, against the flashless twin). The flashless twin
## (RivetNoFlash) holds the pose past the flare. `--rivet-gun-diag=off` (CastFlags) = before (the
## side fire cell on the diagonals). Render only.

## Screen angle (deg, y down) of the drawn gun per diagonal cell, keyed "<art>/<gun>".
const DEG: Dictionary[String, PackedFloat32Array] = {
	"p70/pistol": [32.0, -25.0, 146.0, -150.0],
}
## The helmet's centre x per diagonal cell (strip px; the strip's cells centre theirs at ~141 of
## 283): the away cells draw his body off centre to give the raised gun room (cell 1 at 93.5, 3 at
## 191), so each cell is seated on his helmet, not on the canvas centre (a 20 px sideways pop at
## 64 px/m on the shot tick).
const HELMET_X: Dictionary[String, PackedFloat32Array] = {
	"p70/pistol": [140.5, 93.5, 140.5, 191.0],
}
## The boots' pad above the cell bottom (strip px): cells 0/2 at row 177, 1/3 at 179 of 180.
const FOOT_PX: Dictionary[String, float] = {"p70": 1.0}

static var enabled: bool = true


## True when `weapon` fires drawn diagonal cells under `art` (a gun in DEG with its strip shipped).
static func draws(art: String, weapon: StringName) -> bool:
	if not enabled or not DEG.has(art + "/" + String(weapon)):
		return false
	return RivetStrips.has_file(
		RivetStrips.DIR + art + "/rivet_eq_" + String(weapon) + RivetStrips.DIAG
	)


## True for a gun's diagonal strip path (not the flamer's).
static func owns(path: String) -> bool:
	var file: String = path.get_file()
	if not file.begins_with("rivet_eq_") or not file.ends_with(RivetStrips.DIAG):
		return false
	var gun: String = file.trim_prefix("rivet_eq_").trim_suffix(RivetStrips.DIAG)
	return DEG.has(path.get_base_dir().get_file() + "/" + gun)


## Seats `card`'s diagonal cell `cell` on his helmet's centre (a gun's diagonal strip only).
static func seat(card: Sprite2D, cell: int) -> void:
	var on: String = str(card.get_meta(RivetFrames.ON, ""))
	if not owns(on):
		return
	var gun: String = on.get_file().trim_prefix("rivet_eq_").trim_suffix(RivetStrips.DIAG)
	var xs: PackedFloat32Array = HELMET_X.get(on.get_base_dir().get_file() + "/" + gun, [])
	if cell >= 0 and cell < xs.size():
		card.offset.x = -xs[cell]


## True for a gun's diagonal strip while `--rivet-gun-diag=off` holds it off.
static func off(path: String) -> bool:
	return not enabled and owns(path)


## The foot pad (strip px) of the diagonal strip at `path`: a gun's own, else `fallback`.
static func foot_or(path: String, art: String, fallback: float) -> float:
	return FOOT_PX.get(art, 0.0) if owns(path) else fallback


## The drawn gun's screen angle (rad) at octant `o`: its diagonal cell's where drawn, else the
## facing fire cell's (the camera 90, the sides 0 / 180).
static func gun_rad(weapon: StringName, o: int, art: String) -> float:
	var c: int = RivetStrips.DIAG_CELL[o]
	if c < 0 or not RivetStrips.diag or not draws(art, weapon):
		return deg_to_rad(90.0 if o == 2 else 180.0 * RivetFrames.LEFT[o])
	# .get(): a subscript (DEG[key]) on this typed const reads its packed array as 0.0 (Godot 4.7.2)
	var deg: PackedFloat32Array = DEG.get(art + "/" + String(weapon), [])
	return deg_to_rad(deg[c])
