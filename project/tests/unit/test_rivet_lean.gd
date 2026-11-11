extends GutTest
## n17 rivet-strike item 2: RivetLean's curve (back through the wind-up, in from contact, upright
## over the recovery) and its per-weapon data.

const PH: Vector3 = Vector3(7.0 / 60.0, 5.0 / 60.0, 22.0 / 60.0)
const LEAN: Vector2 = Vector2(5.0, 9.0)


func test_winds_back_then_strikes_in_then_rights_itself() -> void:
	assert_almost_eq(RivetLean.deg_at(LEAN, 0.0, PH), 0.0, 1e-4, "upright at the press")
	assert_lt(RivetLean.deg_at(LEAN, PH.x * 0.99, PH), -4.5, "back off the target")
	assert_almost_eq(RivetLean.deg_at(LEAN, PH.x, PH), LEAN.y, 1e-4, "in on the contact")
	assert_almost_eq(RivetLean.deg_at(LEAN, PH.x + PH.y * 0.9, PH), LEAN.y, 1e-4, "held")
	var end: float = PH.x + PH.y + PH.z
	assert_almost_eq(RivetLean.deg_at(LEAN, end, PH), 0.0, 1e-4, "upright after the recovery")
	assert_almost_eq(RivetLean.deg_at(LEAN, end + 0.1, PH), 0.0, 1e-4, "upright in the hold")


func test_recovery_eases_monotonically() -> void:
	var prev: float = LEAN.y
	for i: int in 11:
		var t: float = PH.x + PH.y + PH.z * float(i) / 10.0
		var d: float = RivetLean.deg_at(LEAN, t, PH)
		assert_true(d <= prev + 1e-4, "no bounce at step %d" % i)
		prev = d


func test_blades_lean_the_claw_and_guns_do_not() -> void:
	for id: StringName in [&"katana", &"plasma_sword", &"chainsaw", &"electro_baton"]:
		var l: Vector2 = RivetLean.of(id)
		assert_gt(l.y, l.x, "%s leans in further than back" % id)
		assert_gt(l.x, 0.0, "%s winds back" % id)
	assert_eq(RivetLean.of(&""), Vector2.ZERO, "the claw strikes upright")
	assert_eq(RivetLean.of(&"pistol"), Vector2.ZERO, "a gun has no lean")


func test_a_strike_stands_planted_only_while_it_plays() -> void:
	var rig: CutRig = autofree(CutRig.new())
	rig.clips.strike_t = -1.0
	assert_false(RivetLean.held(rig), "no strike: the gait bobs")
	rig.clips.strike_t = 0.05
	assert_true(RivetLean.held(rig), "a strike cell stands planted")
	RivetLean.enabled = false
	assert_false(RivetLean.held(rig), "off = the before")
	RivetLean.enabled = true
