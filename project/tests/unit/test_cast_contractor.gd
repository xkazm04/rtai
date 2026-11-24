extends GutTest
## Contractor card, n28: the row is off, so today's drawing is unchanged; the eight-drawing walk is
## a measured anchor table (five facings of eight drawings) that is ready for the card to read.

const ID: StringName = &"contractor"


func test_row_is_off_so_the_card_off_path_is_unchanged() -> void:
	CastCards._library = null
	var cards: CastCards = CastCards.shipped()
	assert_null(cards.lookup(ID, "p70"))
	assert_null(cards.lookup(ID, "p55"))
	assert_not_null(cards.lookup(&"robot_gunner", "p70"), "other rows are untouched")


func test_anchor_table_has_five_facings_of_eight_drawings() -> void:
	assert_eq(CastContractorAnchors.WALK70.size(), 40)
	assert_eq(CastContractorAnchors.WALK55.size(), 40)
	assert_eq(CastContractorAnchors.WALK, CastContractorAnchors.EIGHT, "the eight is selected")
	assert_true(CastCardKinds.anchored(CastContractorAnchors.EIGHT))
	assert_eq(CastCardKinds.four_of(CastContractorAnchors.EIGHT), CastContractorAnchors.FOUR)
	assert_eq(CastCardKinds.foe_marks(CastContractorAnchors.EIGHT, false).size(), 40)
	assert_eq(CastCardKinds.foe_marks(CastContractorAnchors.EIGHT, true).size(), 40)
	assert_eq(
		CastCardKinds.foe_step(CastContractorAnchors.EIGHT), CastContractorAnchors.WALK_STEP_M
	)
	assert_between(CastContractorAnchors.WALK_STEP_M, 0.1, 0.5)


func test_walk_sheet_names_resolve_to_shipped_art() -> void:
	for pitch: String in ["p55", "p70"]:
		var dir: String = RigHeadCard.ART_DIR + pitch + "/"
		assert_true(ResourceLoader.exists(dir + CastContractorAnchors.EIGHT), pitch)
		assert_true(ResourceLoader.exists(dir + CastContractorAnchors.FOUR), pitch)
