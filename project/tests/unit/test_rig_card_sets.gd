extends GutTest
## n8 view: other lanes register card rows through data/tables/card_sets/<lane>.json.


func _write(dir: String, file: String, sets: Dictionary) -> void:
	var f: FileAccess = FileAccess.open(dir.path_join(file), FileAccess.WRITE)
	assert_true(
		f.store_string(
			JSON.stringify({"schema": "gtai.card-set/1", "lane": "t", "doc": "t", "sets": sets})
		)
	)
	f.close()


func test_a_lane_file_adds_and_replaces_rows_over_the_base() -> void:
	var dir: String = TestTmp.dir("card_sets")
	var row: Dictionary = {"strip": "", "anchor_y": 0.5, "width": 2.0, "bust": false, "raw": true}
	_write(dir, "a_street.json", {"p70": {"ped/head_new": row, "thug": row}})
	var later: Dictionary = row.duplicate()
	later["width"] = 3.0
	_write(dir, "b_city.json", {"p70": {"thug": later}, "p99": {"x": row}})
	var m: Dictionary[String, Dictionary] = RigCardSets.merged(dir)
	assert_true(m["p70"].has("ped/head_new"), "a new key joins the art's rows")
	var thug_w: float = m["p70"]["thug"][2]
	assert_almost_eq(thug_w, 3.0, 0.001, "a later file replaces the row")
	assert_true(m.has("p99"), "a lane may open a new art key")
	assert_true(m["p70"].has("rivet"), "the base rows stay")
	var base_w: float = RigCardSets.SETS["p70"]["thug"][2]
	assert_almost_eq(base_w, 1.0, 0.001, "SETS is untouched")


func test_the_shipped_registrations_merge_and_keep_the_base() -> void:
	var all: Dictionary[String, Dictionary] = RigCardSets.all()
	for art: String in RigCardSets.SETS:
		for key: String in RigCardSets.SETS[art]:
			assert_true(all[art].has(key), "%s/%s survives the merge" % [art, key])


func test_row_of_gives_the_positional_row() -> void:
	var r: Array = RigCardSets.row_of(
		{"strip": "res://x.png", "anchor_y": 0.7, "width": 1.5, "bust": true, "raw": false}
	)
	assert_eq(r, ["res://x.png", 0.7, 1.5, true, false])
