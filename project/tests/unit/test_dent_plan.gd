extends GutTest
## features/souls DentPlan: every part it draws loads from art/dent and is measured (both pivots
## in parts.json), and Dent stands at his form row's size against base Rivet.


func test_every_part_loads_with_both_pivots() -> void:
	var p: BodyPlan = DentPlan.build()
	var lib: PartLibrary = PartLibrary.of(p.art_dir)
	for part: String in DentPlan.parts(p):
		assert_not_null(lib.tex(part), "%s.png loads" % part)
		assert_true(lib.pivots_a.has(part) and lib.pivots_b.has(part), "%s is measured" % part)


func test_no_rivet_only_parts() -> void:
	var p: BodyPlan = DentPlan.build()
	assert_false(p.has_collar(), "no collar: vermilion is Rivet's alone")
	assert_false(p.has_hand(), "the hand is drawn on the forearm")
	assert_false(p.has_hose())


func test_size_follows_the_form_row() -> void:
	var row: GhostFormDef = GhostFormTable.load_default().form(&"dent")
	var base: BodyPlan = RivetPlan.build(RivetPlan.FORM_BASE)
	var p: BodyPlan = DentPlan.build(row.size_k)
	assert_almost_eq(p.size_k, base.size_k * row.size_k, 0.0001)
