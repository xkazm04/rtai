extends GutTest
## Lane n8 street: the street cast's per-pitch card rows (StreetCardSets).


func test_every_street_strip_loads_with_whole_frames() -> void:
	for art: String in StreetCardSets.SETS:
		var rows: Dictionary = StreetCardSets.rows_for(art)
		for key: String in rows:
			var row: Array = rows[key]
			assert_eq(row.size(), 5, "%s/%s row shape" % [art, key])
			var tex: Texture2D = load(str(row[0])) as Texture2D
			assert_not_null(tex, "%s/%s loads" % [art, key])
			if tex != null:
				assert_eq(
					tex.get_width() % RigHeadCard.FRAMES, 0, "%s/%s whole frames" % [art, key]
				)


func test_p70_street_rows_point_at_p70_art() -> void:
	var rows: Dictionary = StreetCardSets.rows_for("p70")
	assert_true(rows.has("cop/head_cap"), "the patrol cap has a p70 row")
	for key: String in rows:
		var row: Array = rows[key]
		assert_true(str(row[0]).contains("/p70/"), "%s is drawn for 70, not 55" % key)


func test_an_art_without_street_rows_is_empty() -> void:
	assert_eq(StreetCardSets.rows_for("").size(), 0)
	assert_eq(StreetCardSets.rows_for("nope").size(), 0)
