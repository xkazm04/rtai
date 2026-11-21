extends GutTest


func test_each_block_has_a_distinct_landmark_and_shipped_frontage_and_furniture() -> void:
	var t: DataTable = DataTable.open(GauntletStreet.TABLE, GauntletStreet.SCHEMA)
	var city: DataTable = DataTable.open(PropCards.TABLE, "gtai.city-facades/1")
	var furniture: Dictionary = city.object(city.raw, "props")
	var seen: Array[String] = []
	for row: Dictionary in t.array(t.raw, "segments"):
		var block: GauntletSegment = GauntletSegment.new(t, row, 0.0)
		var deck: Dictionary = block.dressing
		var landmark: String = deck["landmark"]
		assert_false(seen.has(landmark), "%s repeats a landmark" % block.id)
		seen.append(landmark)
		assert_true(GauntletFrontage.FRONTS.has(deck["front"]), String(block.id))
		assert_true(GauntletFrontage.ROOFS.has(deck["front"]), String(block.id))
		var art: Array[String] = [deck["high"], deck["low"]]
		for fixture: Dictionary in deck["fixtures"]:
			var name_of_art: String = fixture["art"]
			art.append(name_of_art)
		for id: String in art:
			assert_has(furniture, id)
			assert_true(ResourceLoader.exists(GauntletLandmarks.FLAT % id), id)
	assert_true(t.ok() and city.ok())
