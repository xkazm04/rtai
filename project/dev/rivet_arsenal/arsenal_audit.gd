class_name ArsenalAudit
extends RefCounted
## Asset completeness at shipped defaults, one row per arsenal id and camera pitch.
## Top: CutRig/RigGrip pose a rotating held part (and swing it); HeldMuzzle uses its local tip.
## No facing, fire, left, strike, wind-up or measured strip muzzle cells apply there.
## Held: own WeaponArt row at top, no art_stand_in. Raised: own equipped facing/rest cells,
## or an enabled HeldPitchArt part on the base rig. Named LOD/empty parts must also exist.
## Fire8 denotes the renderer's octant coverage: side/camera cells 5/6, four drawn diagonals,
## DEG, HELMET_X, FOOT_PX and both noflash twins. The up octant uses its facing + game FX.
## Streams use RivetStrips' flame angles and foot pad. The bottle is a throw with no gun muzzle.
## Rocket fire8 includes visible rear exhaust in all four diagonals (ArsenalAuditFiles).
## Left requires the three drawn facings. ONE_HAND forbids mirroring; other grips' generic
## mirror is not evidence that their hands, hose or belt are correct for the individual weapon.
## Muzzle requires an equipped row and a populated row for every existing diag/left strip.
## Reload: parts.mag at every pitch for magazine users, plus RivetReload's standing right/left
## strips where WeaponMagView hides the part. Tubes, tanks, belts and thrown bottles have no mag.
## Recoil checks class and override values. Cased rounds resolve WeaponArt.casing to their sprite.
## Pickup: own pickup/icon and rack membership, plus angled floor showcase and flat rack icon.
## Melee strikes occupy equipped cells 5/6; RivetWindup selects separate windup and left strips.
## HOLE counts are per cell; one missing shared part can affect several pitches. table_errors
## lists invalid inputs; missing_resources records file holes even for FX with no weapon owner.

const PITCHES: Array[String] = ["top", "p55", "p70"]
const COLUMNS: Array[String] = [
	"held",
	"fire8",
	"left",
	"muzzle",
	"reload",
	"recoil",
	"casing",
	"pickup",
	"strike",
	"windup",
	"left_strike",
	"left_windup"
]
const TOP: String = "cutout rig poses the held part continuously"
const MELEE: String = "melee has no gun discharge"

var _tables: ArsenalAuditTables


func build(lookup: Callable = FileAccess.file_exists) -> Dictionary[String, Variant]:
	_tables = ArsenalAuditTables.new(lookup)
	var weapons: Dictionary[String, Dictionary] = {}
	var holes: Dictionary[String, String] = {}
	var counts: Dictionary[String, int] = {}
	var roster: Dictionary = _tables.arsenal.get("weapons", {})
	for id: String in roster:
		var rows: Dictionary[String, Dictionary] = {}
		counts[id] = 0
		if not (_tables.guns.has(id) or _tables.melee.has(id)):
			_tables.errors.append("unknown weapon " + id)
		for pitch: String in PITCHES:
			var cells: Dictionary = _row(id, pitch, str(roster[id]))
			rows[pitch] = cells
			for column: String in COLUMNS:
				var c: Dictionary = cells[column]
				if c.status == "HOLE":
					holes["%s/%s/%s" % [id, pitch, column]] = c.reason
					counts[id] += 1
		weapons[id] = rows
	_tables.errors.sort()
	return {
		"schema": "gtai.arsenal-audit/1",
		"weapons": weapons,
		"holes": holes,
		"holes_per_weapon": counts,
		"total_holes": holes.size(),
		"missing_resources": _tables.missing_resources,
		"table_errors": _tables.errors
	}


func _row(id: String, pitch: String, grip: String) -> Dictionary[String, Dictionary]:
	var key: String = WeaponArtKey.of(id)
	var base: String = RivetStrips.DIR + pitch + "/rivet_eq_" + key
	var gun: Dictionary = _tables.guns.get(id, {})
	var art: Dictionary = _tables.arts.get(key, {})
	var melee: bool = _tables.melee.has(id)
	var top: bool = pitch == "top"
	var cells: Dictionary[String, Dictionary] = {}
	cells.held = _tables.held(id, pitch, base)
	cells.pickup = _tables.pickup(key, pitch, art)
	cells.reload = _tables.reload(key, pitch, grip, gun)
	cells.casing = _tables.casing(id, gun, art)
	cells.recoil = ArsenalAuditFiles.cell("n/a", MELEE) if melee else _tables.recoil(id, grip)
	var hand: String = "fixed weapon hand" if RivetStrips.ONE_HAND.has(id) else "own left facing"
	cells.left = (
		_strip(base + "_left.png", RivetFrames.LEFT_CELLS, [0, 1, 2], hand)
		if not top
		else ArsenalAuditFiles.cell("n/a", TOP)
	)
	var skip: String = TOP if top else (MELEE if melee else "")
	if grip == "thrown":
		skip = "bottle thrown by hand"
	if skip.is_empty():
		cells.fire8 = _tables.files.fire(base, pitch, key, str(gun.get("kind", "")) == "cone")
		cells.muzzle = _muzzle(base, pitch)
	else:
		cells.fire8 = ArsenalAuditFiles.cell("n/a", skip)
		cells.muzzle = ArsenalAuditFiles.cell("n/a", skip)
	for column: String in ["strike", "windup", "left_strike", "left_windup"]:
		if melee and not top:
			cells[column] = _swing(column, base)
		else:
			cells[column] = ArsenalAuditFiles.cell("n/a", TOP if melee else "no melee swing")
	return cells


func _swing(column: String, base: String) -> Dictionary:
	match column:
		"strike":
			return _strip(base + ".png", RivetFrames.EQ_CELLS, [5, 6], "side and camera strike")
		"windup":
			return _strip(
				base + RivetWindup.FILE, RivetWindup.CELLS, [0, 1], "side and camera windup"
			)
		"left_strike":
			return _strip(base + RivetWindup.LEFT_STRIKE_FILE, 1, [0], "drawn left strike")
		_:
			return _strip(base + RivetWindup.LEFT_FILE, 1, [0], "drawn left windup")


func _strip(path: String, count: int, cells: Array, why: String) -> Dictionary:
	var issues: Array[String] = []
	_tables.files.check_strip(path, count, cells, issues)
	return ArsenalAuditFiles.result(issues, why)


func _muzzle(base: String, pitch: String) -> Dictionary:
	var issues: Array[String] = []
	var rows: Dictionary = _tables.muzzles.get(pitch, {})
	for suffix: String in ["", "_diag", "_left"]:
		var key: String = base.get_file() + suffix
		var present: bool = _tables.files.has(base + suffix + ".png")
		if suffix != "" and not present and not rows.has(key):
			continue
		var row: Dictionary = rows.get(key, {})
		var cells: Dictionary = row.get("cells", {})
		if cells.is_empty():
			issues.append("no muzzle row for " + key)
		elif not present:
			issues.append("muzzle row names missing " + key + ".png")
	return ArsenalAuditFiles.result(
		issues, "measured rows for equipped and shipped diag/left strips"
	)
