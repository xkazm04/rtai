extends GutTest
## n11 combat it32 (owner: "character reactions on being shot/killed is poor"): a rocket kill
## stood the victim upright in his living pose for the signature's own hold (4 sim ticks) while
## the blast played round him; the camera's kill hit-stop is wall time only (SimClock.hold), so
## the hold added to it. A blast signature's body leaves on the first tick after the kill.

const BLASTS: Array[StringName] = [&"rocket_launcher", &"dent_blast"]


func _kills() -> SignatureKills:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	table.gore_full = SignatureKillTable.gore_from_args("full")
	return SignatureKills.new(table, RngRegistry.new(7).stream(&"brutality"))


func _moved_after(weapon: StringName, ticks: int) -> float:
	var k: SignatureKills = _kills()
	var e: KillEvent = KillEvent.make(3, Vector2(5.0, 5.0), Vector2(1.0, 0.0), weapon)
	e.human = true
	assert_true(k.on_kill(e), "%s takes its signature kill" % weapon)
	var start: PackedVector2Array = k.gibs.pos.duplicate()
	for t: int in ticks:
		k.step(t)
	var most: float = 0.0
	for i: int in GibSim.CAPACITY:
		if k.gibs.live(i):
			most = maxf(most, k.gibs.pos[i].distance_to(start[i]))
	return most


func test_a_blast_kill_throws_the_body_on_the_first_tick() -> void:
	for w: StringName in BLASTS:
		assert_gt(_moved_after(w, 1), 0.01, "%s: the body is moving one tick after the kill" % w)


func test_a_blast_row_holds_no_sim_ticks_of_its_own() -> void:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	for w: StringName in BLASTS:
		assert_eq(table.for_weapon(w).hitstop_ticks, 0, "%s: the camera's hit-stop is the hold" % w)
