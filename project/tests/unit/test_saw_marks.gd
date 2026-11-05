extends GutTest
## n7-melee: the chainsaw kill reads at 32 px/m (SawMarks, melee_marks.json `saw`): the shipped
## table loads, a grind queues a release slash on the frame the halves part, and the before
## (feel off) keeps the old judder with no slash. Planted: release_m 0 queues no slash.


func _fx(saw: SawMarks) -> KillSplitFx:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	var kills: SignatureKills = SignatureKills.new(table, RngRegistry.new(3).stream(&"combat"))
	var fx: KillSplitFx = autofree(KillSplitFx.new())
	fx.kills = kills
	fx.saw = saw
	kills.tick = 100
	return fx


func _grind(fx: KillSplitFx) -> SignatureKill:
	var row: SignatureKill = fx.kills.table.for_weapon(&"chainsaw")
	var parts: Array[Node2D] = []
	fx.add(7, Vector2(1.0, 0.0), Vector2.RIGHT, row, parts)
	return row


func test_the_shipped_table_loads() -> void:
	var m: SawMarks = SawMarks.load_from(SawMarks.TABLE, true)
	assert_gt(m.clear_m, 0.0)
	assert_gt(m.release_m, 0.0)
	assert_gt(m.shake_m, SawMarks.BEFORE_SHAKE_M, "the held body judders harder than before")


func test_a_grind_queues_the_release_on_the_parting_frame() -> void:
	var fx: KillSplitFx = _fx(SawMarks.load_from(SawMarks.TABLE, true))
	var row: SignatureKill = _grind(fx)
	assert_eq(fx._releases.size(), 1)
	assert_eq(int(fx._releases[7].w), 100 + row.hitstop_ticks + row.grind_ticks)
	fx.forget(7)
	assert_eq(fx._releases.size(), 0)


func test_feel_off_is_the_before() -> void:
	var m: SawMarks = SawMarks.load_from(SawMarks.TABLE, false)
	assert_eq(m.release_m, 0.0)
	assert_eq(m.clear_m, 0.0)
	assert_eq(m.shake_m, SawMarks.BEFORE_SHAKE_M)


func test_planted_release_zero_queues_no_slash() -> void:
	var m: SawMarks = SawMarks.load_from(SawMarks.TABLE, true)
	m.release_m = 0.0
	var fx: KillSplitFx = _fx(m)
	@warning_ignore("return_value_discarded")
	_grind(fx)
	assert_eq(fx._releases.size(), 0)
