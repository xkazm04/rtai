class_name ArsenalAuditTables
extends RefCounted
## Compare the shipped rows before runtime loaders substitute default rows, art ids or textures.

const DIR: String = "res://data/tables/"

var files: ArsenalAuditFiles
var arsenal: Dictionary
var arts: Dictionary[String, Dictionary]
var fx: Dictionary[String, Dictionary]
var guns: Dictionary[String, Dictionary]
var melee: Dictionary
var pitch_art: Dictionary
var muzzles: Dictionary
var kicks: Dictionary
var feel: Dictionary[String, Dictionary]
var round_fx: Dictionary
var errors: Array[String] = []
var missing_resources: Dictionary[String, Dictionary] = {}


func _init(lookup: Callable) -> void:
	files = ArsenalAuditFiles.new()
	files.exists = lookup
	arsenal = _read(ArsenalTable.TABLE, ArsenalTable.SCHEMA)
	var art: Dictionary = _read(WeaponArt.TABLE, WeaponArt.SCHEMA)
	arts = _index(art)
	fx = _index(art, "fx")
	guns = _index(_read(DIR + "weapons.json", "gtai.weapons/1"))
	var quest: Dictionary = _read(DIR + "combat.json", "gtai.combat/1").get("weapons", {})
	guns.merge(quest)
	melee = _read(DIR + "melee_weapons.json", "gtai.melee-weapons/1").get("weapons", {})
	pitch_art = _read(HeldPitchArt.TABLE, HeldPitchArt.SCHEMA).get("pitches", {})
	muzzles = _read(RivetMuzzle.TABLE, RivetMuzzle.SCHEMA).get("strips", {})
	kicks = _read(DIR + "arena.json", "gtai.arena/1").get("rig_kick", {})
	feel = _index(_read(DIR + "hit_feel.json", "gtai.hit_feel/1"))
	var effects: Dictionary = NoirLook.read_params(RivetNoFlash.FX)
	round_fx = effects.get("weapons", {})
	_check_resources(effects)
	if round_fx.is_empty():
		errors.append("missing gun_fx weapon rows")
	var roster: Dictionary = arsenal.get("weapons", {})
	if roster.is_empty():
		errors.append("missing arsenal weapon roster")


func held(id: String, pitch: String, base: String) -> Dictionary:
	var issues: Array[String] = []
	var key: StringName = RivetGunDiag.art_key(id)
	var aliases: Dictionary = arsenal.get("art_stand_in", {})
	var shown: String = aliases.get(id, id)
	var art: Dictionary = arts.get(key, {})
	if pitch == "top":
		if shown != key:
			issues.append("art_stand_in -> " + shown)
		files.require_file(str(art.get("held", "")), "own held art", issues)
		var parts: Dictionary = art.get("parts", {})
		for part: String in parts:
			if part != "mag":
				files.references(parts[part], issues)
		return ArsenalAuditFiles.result(issues, "own held part on the posed gun claw")
	var view: Dictionary = pitch_art.get(pitch.trim_prefix("p"), {})
	var rows: Dictionary = view.get("weapons", {})
	var pitched: Dictionary = rows.get(id, {})
	files.references(pitched, issues)
	if files.has(base + ".png"):
		files.require_file(base.get_base_dir() + "/" + RivetStrips.BASE, "base strip", issues)
		files.check_strip(base + ".png", RivetFrames.EQ_CELLS, [0, 1, 2, 3, 4, 7], issues)
		return ArsenalAuditFiles.result(issues, "own equipped facing and rest cells")
	if shown != key or not pitched.get("enabled", true) or not files.has(str(art.get("held", ""))):
		issues.append("no usable own pitch part")
	files.require_file(
		str(pitched.get("art", "")), "equipped strip or active own pitch art", issues
	)
	return ArsenalAuditFiles.result(issues, "own enabled pitch part on the base figure")


func pickup(id: String, pitch: String, art: Dictionary) -> Dictionary:
	var issues: Array[String] = []
	for key: String in ["pickup", "icon"]:
		files.require_file(str(art.get(key, "")), key, issues)
	if not WeaponRackView.ORDER.has(id):
		issues.append("absent from rack ORDER")
	if pitch != "top":
		for form: String in [pitch, WeaponShowcase.ICON]:
			files.require_file(WeaponShowcase.path_of(id, form), form, issues)
	return ArsenalAuditFiles.result(
		issues,
		(
			"pickup and icon on rack"
			if pitch == "top"
			else "pickup, icon, pitch showcase and rack icon"
		)
	)


func reload(id: String, pitch: String, grip: String, gun: Dictionary) -> Dictionary:
	if gun.is_empty():
		return ArsenalAuditFiles.cell("n/a", "melee has no magazine")
	if grip == "shoulder":
		return ArsenalAuditFiles.cell("n/a", "single shell loaded into tube")
	if RivetHeldView.NO_MAG.has(grip):
		return ArsenalAuditFiles.cell("n/a", "bottle, fuel tank or belt box (%s)" % grip)
	if gun.get("magazine", 0) == 0:
		return ArsenalAuditFiles.cell("n/a", "unlimited ammunition")
	var issues: Array[String] = []
	var art: Dictionary = arts.get(id, {})
	var parts: Dictionary = art.get("parts", {})
	var mag: String = parts.get("mag", "")
	files.require_file(mag, "own parts.mag", issues)
	if pitch != "top":
		var base: String = RivetStrips.DIR + pitch + "/" + RivetReload.PREFIX + id
		files.check_strip(base + ".png", RivetFrames.EQ_CELLS, range(RivetFrames.EQ_CELLS), issues)
		files.check_strip(
			base + "_left.png", RivetFrames.LEFT_CELLS, range(RivetFrames.LEFT_CELLS), issues
		)
	return ArsenalAuditFiles.result(
		issues, "magazine part" if pitch == "top" else "magazine part and both reload strips"
	)


func casing(id: String, gun: Dictionary, art: Dictionary) -> Dictionary:
	if gun.is_empty():
		return ArsenalAuditFiles.cell("n/a", "melee has no rounds")
	var row: Dictionary = round_fx.get(id, {})
	var metres: float = row.get("casing_m", 0)
	var cased: bool = metres > 0 or art.get("projectile_fx") == "tracer"
	if not cased and id != "assault-rifle":
		return ArsenalAuditFiles.cell(
			"n/a", "caseless projectile (%s)" % art.get("projectile_fx", gun.get("kind", "unknown"))
		)
	var issues: Array[String] = []
	var name: String = art.get("casing", "")
	var effect: Dictionary = fx.get(name, {})
	files.require_file(str(effect.get("art", "")), "casing FX row/art", issues)
	return ArsenalAuditFiles.result(issues, "casing resolves to on-disk FX art")


func recoil(id: String, grip: String) -> Dictionary:
	var classes: Dictionary = arsenal.get("classes", {})
	var row: Dictionary = classes.get(grip, {})
	var kick: Variant = row.get("kick")
	if not (kick is float or kick is int):
		return ArsenalAuditFiles.cell("HOLE", "missing numeric class kick for " + grip)
	var why: String = "%s kick %s" % [grip, kick]
	if kicks.has(id):
		if not (kicks[id] is float or kicks[id] is int):
			return ArsenalAuditFiles.cell("HOLE", "invalid arena rig_kick")
		why += ", arena rig_kick %s" % kicks[id]
	var hit: Dictionary = feel.get(id.replace("-", "_"), {})
	if hit.has("fire_kick_px"):
		if not (hit.fire_kick_px is float or hit.fire_kick_px is int):
			return ArsenalAuditFiles.cell("HOLE", "invalid hit-feel fire_kick_px")
		why += ", fire_kick_px %s" % hit.fire_kick_px
	return ArsenalAuditFiles.cell("ok", why)


func _read(path: String, schema: String) -> Dictionary:
	var table: DataTable = DataTable.open(path, schema)
	errors.append_array(table.errors())
	_check_resources(table.raw)
	return table.raw


func _check_resources(table: Dictionary) -> void:
	var missing: Array[String] = []
	files.references(table, missing)
	for why: String in missing:
		missing_resources[why.trim_prefix("missing ")] = ArsenalAuditFiles.cell("HOLE", why)


func _index(table: Dictionary, key: String = "weapons") -> Dictionary[String, Dictionary]:
	var by_id: Dictionary[String, Dictionary] = {}
	for row: Dictionary in table.get(key, []):
		by_id[row.id] = row
	return by_id
