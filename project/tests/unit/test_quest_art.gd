extends GutTest
## Quest 1's art by id (data/tables/collect_call_art.json via ArtIds / QuestArt): every row loads,
## the rig captures carry their drawn size, and an unknown id draws a placeholder (no crash).

const IDS: Array[StringName] = [
	&"rivet",
	&"rivet_peek",
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
	var k: float = 1.1 / 1.3
	assert_almost_eq(art.size_m(&"rivet").x, 3.1 * k, 0.001)
	assert_almost_eq(art.size_m(&"rivet").y, 3.9 * k, 0.001)
	assert_eq(art.size_m(&"cop"), Vector2(1.85, 3.23), "no draw_k = 1")


func test_rows_without_a_size_use_the_fallback() -> void:
	assert_eq(QuestArt.shared().size_m(&"mertz", Vector2(2, 2)), Vector2(2, 2))


func test_unknown_id_is_a_placeholder() -> void:
	var art: ArtIds = ArtIds.new(QuestArt.TABLE, QuestArt.SCHEMA, "test")
	assert_eq(art.texture(&"no_such_art").get_size(), Vector2(4, 4))
