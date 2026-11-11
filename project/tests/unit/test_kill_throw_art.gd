extends GutTest
## Lane kills-new (n16): Rivet's bare-claw finisher (claw_throw, KillThrowArt). The discharge lofts
## him in a low hop that ends where he lands, the slide carries him back along the blow and on
## through the skid, and the hop and slide are the same at the same tick.

const PPM: float = 32.0


func _death(dir: Vector2 = Vector2.RIGHT) -> KillNewStyles.Death:
	var d: KillNewStyles.Death = KillNewStyles.Death.new()
	d.extra = KillTrackRows.of(&"claw_throw")
	d.dir = dir
	return d


func test_the_hop_lifts_him_off_the_street_and_lands_him() -> void:
	var d: KillNewStyles.Death = _death()
	var from: int = roundi(d.extra.num("lift_from", -1.0))
	var land: int = roundi(d.extra.num("land_at", -1.0))
	assert_gt(land, from, "the row names the hop")
	assert_eq(KillThrowArt.lift(d, from, PPM), Vector2.ZERO, "on his toes, not yet off")
	var top: Vector2 = KillThrowArt.lift(d, (from + land) / 2, PPM)
	assert_almost_eq(top.y, -d.extra.num("lift_m", 0.0) * PPM, 0.5, "the top of the hop, up")
	assert_eq(top.x, 0.0, "the hop only lifts")
	assert_eq(KillThrowArt.lift(d, land, PPM), Vector2.ZERO, "landed")
	assert_eq(KillThrowArt.lift(d, 400, PPM), Vector2.ZERO, "and stays down")


func test_the_throw_carries_him_back_along_the_blow_then_skids() -> void:
	var d: KillNewStyles.Death = _death(Vector2.DOWN)
	var land: int = roundi(d.extra.num("land_at", 0.0))
	assert_eq(KillThrowArt.slide(d, 0, PPM), Vector2.ZERO, "the claw lands where he stands")
	var at_land: Vector2 = KillThrowArt.slide(d, land, PPM)
	var rest: Vector2 = KillThrowArt.slide(d, 400, PPM)
	assert_almost_eq(
		rest, Vector2.DOWN * d.extra.slide_m * PPM, Vector2.ONE * 0.01, "along the blow"
	)
	assert_gt(at_land.length(), rest.length() * 0.5, "most of the way in the air")
	assert_lt(at_land.length(), rest.length(), "then the skid")
	var last: float = -1.0
	for age: int in 60:
		var run: float = KillThrowArt.slide(d, age, PPM).length()
		assert_gte(run, last, "never slides back (tick %d)" % age)
		last = run


func test_no_blood_and_the_fight_barely_stops() -> void:
	var row: SignatureKill = SignatureKillTable.load_table().for_weapon(&"claw_shock")
	assert_eq(row.spray, 0, "a discharge, not a wound")
	assert_eq(row.blot_m, 0.0)
	assert_lte(row.hitstop_ticks, 6)
