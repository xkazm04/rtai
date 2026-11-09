extends GutTest
## RivetStrips.has_file: the per-step file probe of Rivet's strip choice, asked once per path.

const REAL: String = "res://features/characters/art/view/p70/rivet_frames.png"
const MISSING: String = "res://features/characters/art/view/p70/rivet_no_such_strip.png"


func test_answers_what_the_resource_loader_answers() -> void:
	assert_true(ResourceLoader.exists(REAL), "the fixture strip is shipped")
	assert_true(RivetStrips.has_file(REAL))
	assert_false(ResourceLoader.exists(MISSING), "the fixture path is absent")
	assert_false(RivetStrips.has_file(MISSING))


func test_a_second_ask_does_not_probe_again() -> void:
	var path: String = MISSING + ".memo"
	assert_false(RivetStrips.has_file(path))
	RivetStrips._exists[path] = true  # a probe would answer false: this reads the memo
	assert_true(RivetStrips.has_file(path))
	assert_true(RivetStrips._exists.erase(path))


func test_strip_of_still_picks_the_base_for_a_weapon_with_no_strip() -> void:
	var base: String = RivetStrips.DIR + "p70/" + RivetStrips.BASE
	assert_eq(RivetStrips.strip_of("p70", &"no_such_weapon"), base)
	assert_eq(RivetStrips.strip_of("", &""), "", "no art key, no strip")
