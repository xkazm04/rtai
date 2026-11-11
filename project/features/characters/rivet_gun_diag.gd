class_name RivetGunDiag
extends RefCounted
## n17 rivet-strike (DEFECTS #11): a gun shot at a diagonal octant drew the side fire cell, its
## arm level at 0 deg while the round left at 30-45 deg. Where the asset lane drew the gun's
## diagonal fire cells (rivet_eq_<gun>_diag.png, it458: RivetStrips' DIAG order, 3/4 toward right,
## away right, toward left, away left; the gun in his right hand in all four) the diagonal octants
## fire them (RivetStrips.diag_or, as the flamer's), and a shot counts as drawn when it is aimed
## within GUN_TOL of the drawn gun's screen angle (DEG, measured: the flash's biggest hot blob, from
## its root nearest the body to its far tip, against the flashless twin), when the aim lies within
## FIT_TOL of it: nearer the side or the camera the facing cells stand (RivetFireCam's choice). The
## flashless twin
## (RivetNoFlash) holds the pose past the flare. `--rivet-gun-diag=off` (CastFlags) = before (the
## side fire cell on the diagonals). Render only.

## Screen angle (deg, y down) of the drawn gun per diagonal cell, keyed "<art>/<gun>".
const DEG: Dictionary[String, PackedFloat32Array] = {
	"p70/pistol": [32.0, -25.0, 146.0, -150.0],
	"p70/machine_pistol": [40.0, -31.0, 139.0, -149.0],
	# the barrel's axis by eye at 2x (+-5 deg): these flashes fan off the barrel, the tool misreads
	"p70/plasma_rifle": [23.0, -45.0, 155.0, -138.0],
	"p70/gatling": [30.0, -43.0, 150.0, -141.0],
	"p70/hand_cannon": [38.0, -33.0, 124.0, -149.0],
	"p70/gloria": [35.0, -41.0, 150.0, -138.0],
	"p70/electro_gun": [24.0, -41.0, 150.0, -139.0],
	"p70/rocket_launcher": [18.0, -39.0, 161.0, -151.0],
	# p55 (it458/it462): barrel axes by eye at 2x (pistol, machine pistol: the flash read)
	"p55/pistol": [37.0, -42.0, 145.0, -138.0],
	"p55/machine_pistol": [39.0, -40.0, 137.0, -145.0],
	"p55/plasma_rifle": [27.0, -45.0, 149.0, -139.0],
	"p55/gatling": [35.0, -37.0, 146.0, -149.0],
	"p55/hand_cannon": [34.0, -36.0, 146.0, -146.0],
	"p55/gloria": [32.0, -52.0, 145.0, -146.0],
	"p55/electro_gun": [27.0, -34.0, 145.0, -145.0],
	"p55/rocket_launcher": [23.0, -34.0, 159.0, -152.0],
}
## The helmet's centre x per diagonal cell (strip px; the strip's cells centre theirs at ~141 of
## 283): the away cells draw his body off centre to give the raised gun room (cell 1 at 93.5, 3 at
## 191), so each cell is seated on his helmet, not on the canvas centre (a 20 px sideways pop at
## 64 px/m on the shot tick).
const HELMET_X: Dictionary[String, PackedFloat32Array] = {
	"p70/pistol": [140.5, 93.5, 140.5, 191.0],
	"p70/machine_pistol": [127.5, 89.5, 126.5, 163.5],
	# the dome's run centre 12-28 px under its top (a raised gun or pack widens the widest run)
	"p70/plasma_rifle": [172.5, 132.5, 169.5, 209.5],
	"p70/gatling": [146.8, 110.0, 152.0, 190.0],
	"p70/hand_cannon": [142.0, 97.0, 141.5, 186.5],
	"p70/gloria": [160.5, 129.8, 160.5, 192.0],
	"p70/electro_gun": [112.5, 77.0, 111.5, 148.0],
	"p70/rocket_launcher": [130.0, 90.2, 130.0, 165.5],
	# p55: the dome's run centre as above
	"p55/pistol": [97.5, 66.5, 96.5, 126.5],
	"p55/machine_pistol": [99.5, 65.0, 101.5, 135.0],
	"p55/plasma_rifle": [133.0, 98.2, 133.0, 169.2],
	"p55/gatling": [131.2, 100.5, 136.5, 171.5],
	"p55/hand_cannon": [113.0, 80.0, 116.5, 149.5],
	"p55/gloria": [114.0, 90.0, 110.5, 135.0],
	"p55/electro_gun": [96.8, 67.2, 97.0, 126.0],
	"p55/rocket_launcher": [83.5, 51.5, 88.5, 119.5],
}
## The boots' pad above the cell bottom (strip px), keyed "<art>/<gun>": cell height - 1 - boot row
## (the pistol's cells 0/2 at row 177 and 1/3 at 179 of 180). The other guns ship the asset lane's
## TALL cells (it463: the drawn cell + 60 clear rows, so a down-aimed flash is not cut at the cell
## floor), so their pads are about 60 px more (the machine pistol's boots at 172 of 235).
const FOOT_PX: Dictionary[String, float] = {
	"p70/pistol": 1.0,
	"p70/machine_pistol": 62.0,
	"p70/plasma_rifle": 62.0,
	"p70/gatling": 62.0,
	"p70/hand_cannon": 61.5,
	"p70/gloria": 62.0,
	"p70/electro_gun": 61.0,
	"p70/rocket_launcher": 62.0,
	# p55: the delivered cells (no tall cut), boots at row 167-171 of 170-172
	"p55/pistol": 2.0,
	"p55/machine_pistol": 2.0,
	"p55/plasma_rifle": 1.0,
	"p55/gatling": 2.0,
	"p55/hand_cannon": 1.5,
	"p55/gloria": 2.0,
	"p55/electro_gun": 2.0,
	"p55/rocket_launcher": 2.0,
}

## Half an octant: within it the diagonal is the drawn gun nearest the aim.
const FIT_TOL: float = PI / 8.0

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


## True when `rig`'s aim (none: the facing's) lies within FIT_TOL of the drawn diagonal gun at `o`.
static func fits(rig: CutRig, weapon: StringName, o: int, art: String) -> bool:
	var aim: float = RivetStrips.aim_of(rig)
	return is_nan(aim) or absf(angle_difference(aim, gun_rad(weapon, o, art))) <= FIT_TOL


## True for a gun's diagonal strip while `--rivet-gun-diag=off` holds it off.
static func off(path: String) -> bool:
	return not enabled and owns(path)


## The foot pad (strip px) of the diagonal strip at `path`: a gun's own, else `fallback`.
static func foot_or(path: String, art: String, fallback: float) -> float:
	var gun: String = path.get_file().trim_prefix("rivet_eq_").trim_suffix(RivetStrips.DIAG)
	return FOOT_PX.get(art + "/" + gun, 0.0) if owns(path) else fallback


## The drawn gun's screen angle (rad) at octant `o`: its diagonal cell's where drawn, else the
## facing fire cell's (the camera 90, the sides 0 / 180).
static func gun_rad(weapon: StringName, o: int, art: String) -> float:
	var c: int = RivetStrips.DIAG_CELL[o]
	if c < 0 or not RivetStrips.diag or not draws(art, weapon):
		return deg_to_rad(90.0 if o == 2 else 180.0 * RivetFrames.LEFT[o])
	# .get(): a subscript (DEG[key]) on this typed const reads its packed array as 0.0 (Godot 4.7.2)
	var deg: PackedFloat32Array = DEG.get(art + "/" + String(weapon), [])
	return deg_to_rad(deg[c])
