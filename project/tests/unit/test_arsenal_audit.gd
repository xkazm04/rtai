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
