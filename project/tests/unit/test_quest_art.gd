extends GutTest
## Quest 1's art by id (data/tables/collect_call_art.json via ArtIds / QuestArt): every row loads,
## the rig captures carry their drawn size, and an unknown id draws a placeholder (no crash).

const IDS: Array[StringName] = [
	&"rivet",
	&"rivet_lod",
	&"rivet_peek",
	&"rivet_peek_lod",
	&"cop",
	&"mertz",
	&"juno",
	&"dumpster",
	&"payphone",
	&"road_straight_tone",
	&"curb_straight_tone",
	&"tuckin_crate",
	&"fx_arcball",
	&"fx_fire",
]


func test_every_id_the_views_name_loads() -> void:
	var art: ArtIds = QuestArt.shared()
	for id: StringName in IDS:
		assert_true(art.has(id), "table has %s" % id)
		assert_gt(art.texture(id).get_width(), 4, "%s is real art, not the placeholder" % id)


func test_rivet_draws_at_the_base_form() -> void:
	var art: ArtIds = QuestArt.shared()
	for id: StringName in [&"rivet", &"rivet_lod", &"rivet_peek", &"rivet_peek_lod", &"cop"]:
		var px: Vector2 = Vector2(art.texture(id).get_size())
		assert_almost_eq(art.size_m(id).x, px.x / 120.0, 0.01, "%s at true scale" % id)
		assert_almost_eq(art.size_m(id).y, px.y / 120.0, 0.01, "%s at true scale" % id)
	# owner verdict 1: only slightly larger than a human (the night capture was 3.1 x 3.9 m)
	assert_lt(art.size_m(&"rivet").y, art.size_m(&"cop").y, "shorter frame than the gun-out cop")
	# n5-cast: both re-captured from the slim rigs; Rivet's core is about 1.1x a cop's footprint
	assert_lt(art.size_m(&"cop").x, 1.6, "the slim cop, not the 1.85 m pre-slim capture")


func test_rows_without_a_size_use_the_fallback() -> void:
	assert_eq(QuestArt.shared().size_m(&"mertz", Vector2(2, 2)), Vector2(2, 2))


func test_unknown_id_is_a_placeholder() -> void:
	var art: ArtIds = ArtIds.new(QuestArt.TABLE, QuestArt.SCHEMA, "test")
	assert_eq(art.texture(&"no_such_art").get_size(), Vector2(4, 4))
