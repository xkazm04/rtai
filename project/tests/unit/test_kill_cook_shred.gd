extends GutTest
## Lane kills-new (n16): the baton's overload trembles only while he cooks and never under
## --reduced-motion; the Gatling's shred tears the row's scrap count, every `scrap_every` ticks,
## off his figure, and no more however the frames fall.


func _death(row_id: StringName) -> KillNewStyles.Death:
	var d: KillNewStyles.Death = KillNewStyles.Death.new()
	d.serial = 4
	d.extra = KillTrackRows.of(row_id)
	d.feet_px = Vector2(0.0, 100.0)
	d.head_px = Vector2(0.0, 40.0)
	d.height = 64.0
	return d


func test_the_cook_trembles_only_while_he_cooks() -> void:
	var d: KillNewStyles.Death = _death(&"baton_overload")
	var from: int = roundi(d.extra.num("cook_from", -1.0))
	var to: int = roundi(d.extra.num("cook_to", -1.0))
	assert_gt(to, from, "the row cooks for a while")
	assert_eq(KillCookArt.tremble(d, from - 1, false), 0.0, "held still before the cook")
	assert_ne(KillCookArt.tremble(d, from, false), 0.0, "trembles while cooking")
	assert_eq(
		KillCookArt.tremble(d, from, false), -KillCookArt.tremble(d, from + 1, false), "a buzz"
	)
	assert_eq(KillCookArt.tremble(d, to, false), 0.0, "still once he falls")
	for age: int in range(from, to):
		assert_eq(KillCookArt.tremble(d, age, true), 0.0, "no tremble under reduced motion")


func test_the_shred_tears_its_scraps_on_their_ticks_and_no_more() -> void:
	var d: KillNewStyles.Death = _death(&"gatling_shred")
	d.born = 100
	var art: KillShredArt = KillShredArt.new()
	art.add_death(d)
	var every: int = roundi(d.extra.num("scrap_every", 0.0))
	var count: int = roundi(d.extra.num("scraps", 0.0))
	assert_gt(count, 0)
	art.pose(100 + every * 2, 32.0, false)  # frames skipped: the tears catch up
	assert_eq(art._shreds[0].tears.size(), 3)
	art.pose(100 + 400, 32.0, false)
	assert_eq(
		art._shreds[0].tears.size(), mini(count, roundi(d.extra.num("cells_at", 0.0)) / every)
	)
	for p: Vector2 in art._shreds[0].tears:
		assert_between(p.y, d.head_px.y, d.feet_px.y, "torn off his figure, feet to head")
	art.forget(d.serial)
	assert_eq(art._shreds.size(), 0)
