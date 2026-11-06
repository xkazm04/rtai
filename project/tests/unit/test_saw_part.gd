extends GutTest
## n7-melee: the chainsaw's halves leave forward along the saw's push as well as off each side of
## the cut (signature_kills.json chainsaw split_follow), so neither half falls back under Rivet;
## `--saw-part=off` (BrutalityHook.saw_part_off) restores the brutality night's sideways part.

const PUSH: Vector2 = Vector2(-1.0, 0.0)
## Widest angle (degrees) between a half's flight and the push that still lands it clear of Rivet.
const MAX_OFF_PUSH_DEG: float = 62.0


func _kills(table: SignatureKillTable) -> SignatureKills:
	return SignatureKills.new(table, RngRegistry.new(11).stream(&"brutality"))


## The angles (degrees) between each half's launch and the push, read once the grind lets go.
func _half_angles(table: SignatureKillTable) -> Array[float]:
	var k: SignatureKills = _kills(table)
	var e: KillEvent = KillEvent.make(3, Vector2(2.0, 2.0), PUSH, &"chainsaw")
	e.human = true
	assert_true(k.on_kill(e), "the chainsaw takes its signature kill")
	var out: Array[float] = []
	for i: int in GibSim.CAPACITY:
		if k.gibs.live(i):
			out.append(rad_to_deg(absf(k.gibs.vel[i].angle_to(PUSH))))
	return out


func test_the_chainsaw_row_reads_its_follow() -> void:
	var row: SignatureKill = SignatureKillTable.load_table().for_weapon(&"chainsaw")
	assert_almost_eq(row.split_follow, 0.8, 0.001)
	var katana: SignatureKill = SignatureKillTable.load_table().for_weapon(&"katana")
	assert_almost_eq(katana.split_follow, GibSim.SPLIT_FOLLOW, 0.001, "other cuts keep their look")


func test_both_halves_leave_forward_along_the_push() -> void:
	var angles: Array[float] = _half_angles(SignatureKillTable.load_table())
	assert_eq(angles.size(), 2)
	for a: float in angles:
		assert_lt(a, MAX_OFF_PUSH_DEG, "half %.0f deg off the push" % a)


func test_saw_part_off_is_the_sideways_before() -> void:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	BrutalityHook.saw_part_off(table)
	for a: float in _half_angles(table):
		assert_gt(a, MAX_OFF_PUSH_DEG, "the before parts the halves sideways")
