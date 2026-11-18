extends GutTest

const KNOWN: String = "res://dev/rivet_arsenal/arsenal_known_holes.json"

var _matrix: Dictionary
var _known: Dictionary


func before_all() -> void:
	_matrix = ArsenalAudit.new().build()
	var table: DataTable = DataTable.open(KNOWN, "gtai.arsenal-known-holes/1")
	assert_true(table.ok(), str(table.errors()))
	_known = table.object(table.raw, "holes")


func test_every_hole_is_known() -> void:
	var errors: Array[String] = _matrix.table_errors
	assert_eq(errors.size(), 0, str(errors))
	var missing: Dictionary = _matrix.missing_resources
	assert_eq(missing.size(), 0, str(missing))
	for key: String in _matrix.holes:
		assert_true(_known.has(key), "NEW hole %s: %s" % [key, _matrix.holes[key]])


func test_every_known_hole_still_exists() -> void:
	var holes: Dictionary = _matrix.holes
	for key: String in _known:
		assert_true(holes.has(key), "FIXED hole, remove " + key)
		assert_false(str(_known[key]).is_empty(), "missing reason for " + key)


func test_matrix_covers_roster_and_counts_each_hole_once() -> void:
	var roster: Dictionary = DataTable.open(ArsenalTable.TABLE, ArsenalTable.SCHEMA).raw.weapons
	assert_gt(roster.size(), 0)
	var weapons: Dictionary = _matrix.weapons
	var holes: Dictionary = _matrix.holes
	var counts: Dictionary[String, int] = _matrix.holes_per_weapon
	assert_eq(weapons.size(), roster.size())
	var total: int = 0
	for id: String in roster:
		var count: int = 0
		for pitch: String in ["top", "p55", "p70"]:
			var row: Dictionary = _matrix.weapons[id][pitch]
			assert_eq(row.size(), 12)
			for col: String in row:
				var c: Dictionary = row[col]
				assert_has(["ok", "HOLE", "n/a"], str(c.status))
				assert_false(str(c.reason).is_empty())
				if c.status == "HOLE":
					assert_has(holes, "%s/%s/%s" % [id, pitch, col])
					count += 1
		assert_eq(counts[id], count)
		total += count
	var reported: int = _matrix.total_holes
	assert_eq(reported, total)


func test_missing_declared_art_is_a_hole_without_touching_the_file() -> void:
	var art: String = "res://features/combat/weapons/art/pistol/icon.png"
	var missing: Callable = func(path: String) -> bool:
		return path != art and FileAccess.file_exists(path)
	var matrix: Dictionary = ArsenalAudit.new().build(missing)
	var missing_resources: Dictionary = matrix.missing_resources
	var holes: Dictionary = matrix.holes
	assert_has(missing_resources, art)
	assert_eq(str(missing_resources[art].status), "HOLE")
	for pitch: String in ArsenalAudit.PITCHES:
		var c: Dictionary = matrix.weapons.pistol[pitch].pickup
		assert_eq(str(c.status), "HOLE")
		assert_string_contains(str(c.reason), art)
		assert_has(holes, "pistol/%s/pickup" % pitch)


func test_top_and_thrown_use_rig_paths() -> void:
	for col: String in ["fire8", "left", "muzzle"]:
		assert_eq(str(_matrix.weapons.pistol.top[col].status), "n/a")
	for pitch: String in ArsenalAudit.PITCHES:
		assert_eq(str(_matrix.weapons.molotov[pitch].fire8.status), "n/a")
		assert_eq(str(_matrix.weapons.molotov[pitch].reload.status), "n/a")
		assert_eq(str(_matrix.weapons.katana[pitch].recoil.status), "n/a")


func test_rocket_fire_checks_each_diagonal_and_rejects_unequal_cell_widths() -> void:
	var base: String = TestTmp.dir("arsenal_audit").path_join("rivet_eq_rocket_launcher")
	var eq: Image = Image.create_empty(RivetFrames.EQ_CELLS, 1, false, Image.FORMAT_RGBA8)
	eq.fill(Color.GRAY)
	assert_eq(eq.save_png(base + ".png"), OK)
	assert_eq(eq.save_png(base + RivetNoFlash.SUFFIX), OK)

	# A gray pose in every cell. Place one flash behind each helmet: first pair facing
	# right, last pair facing left. Reading cell zero four times must fail the left pair.
	var width: int = 256
	var diag: Image = Image.create_empty(
		width * RivetStrips.DIAG_CELLS, 1, false, Image.FORMAT_RGBA8
	)
	diag.fill(Color.GRAY)
	assert_eq(diag.save_png(base + "_diag" + RivetNoFlash.SUFFIX), OK)
	for i: int in RivetStrips.DIAG_CELLS:
		var rear: int = 0 if i < 2 else width - 1
		diag.set_pixel(i * width + rear, 0, Color.ORANGE)
	assert_eq(diag.save_png(base + RivetStrips.DIAG), OK)
	var valid: Dictionary = ArsenalAuditFiles.new().fire(base, "p55", "rocket_launcher", false)
	assert_eq(str(valid.status), "ok", str(valid.reason))

	# Both twins still match and every pose has ink, but one extra column breaks the layout.
	eq.resize(RivetFrames.EQ_CELLS + 1, 1, Image.INTERPOLATE_NEAREST)
	assert_eq(eq.save_png(base + ".png"), OK)
	assert_eq(eq.save_png(base + RivetNoFlash.SUFFIX), OK)
	var invalid: Dictionary = ArsenalAuditFiles.new().fire(base, "p55", "rocket_launcher", false)
	assert_eq(str(invalid.status), "HOLE", str(invalid.reason))
	assert_string_contains(str(invalid.reason), base.get_file() + ".png")
