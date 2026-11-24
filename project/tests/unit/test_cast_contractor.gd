extends GutTest
## Contractor card, n28: the row is on (white hat, pale lemon vest); the eight-drawing walk is
## a measured anchor table (five facings of eight drawings) that the card reads.

const ID: StringName = &"contractor"


func test_row_is_on_and_other_rows_are_untouched() -> void:
	CastCards._library = null
	var cards: CastCards = CastCards.shipped()
	assert_not_null(cards.lookup(ID, "p70"))
	assert_not_null(cards.lookup(ID, "p55"))
	assert_null(cards.lookup(&"patrol_cop", "p70"))
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


func _on_cards() -> CastCards:
	var table: DataTable = DataTable.open(CastCards.TABLE, CastCards.SCHEMA)
	table.raw.archetypes.contractor.enabled = true
	return CastCards.from_table(table)


func test_row_on_draws_his_sheets_through_the_shared_card_path() -> void:
	var cards: CastCards = _on_cards()
	for pitch: String in ["p55", "p70"]:
		var sheets: CastCards.Sheets = cards.lookup(ID, pitch)
		assert_not_null(sheets, pitch)
		var dir: String = RigHeadCard.ART_DIR + pitch + "/"
		assert_eq(sheets.walk, dir + CastContractorAnchors.WALK)
		assert_eq(sheets.attack, dir + "contractor_attack.png")
		assert_eq(sheets.hit, dir + "contractor_cast_hit.png", "not quest 1's contractor_hit.png")
		assert_eq(sheets.fall, dir + "contractor_cast_fall.png")


func test_row_on_leaves_quest_1_sheets_and_other_rows_alone() -> void:
	var cards: CastCards = _on_cards()
	assert_not_null(cards.lookup(&"robot_gunner", "p70"))
	assert_null(cards.lookup(&"patrol_cop", "p70"))
	var sheets: CastCards.Sheets = cards.lookup(ID, "p70")
	assert_ne(sheets.hit.get_file(), "contractor_hit.png")
	assert_ne(sheets.fall.get_file(), "contractor_fall.png")
