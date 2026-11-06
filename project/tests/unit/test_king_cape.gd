extends GutTest
## King's cape follows his charging attacks and the slam's leap (render only): drawn in through
## the tell, flared through the dash, settling back after; the slam lands it wide; the coin fan
## and the decree leave it at rest.


func _fight(attack: StringName, state: BossFight.State, t: int) -> BossFight:
	var spec: BossSpec = BossSpec.shipped(&"king")
	var f: BossFight = BossFight.new(spec, RngRegistry.new(5).stream(spec.rng), Vector2(10, 4))
	f.attack = spec.attacks[attack]
	f.state = state
	f.t = t
	return f


func test_the_charge_gathers_then_flares_then_settles() -> void:
	var tell: float = KingCape._reach(_fight(&"charge", BossFight.State.WINDUP, 60))
	var dash: float = KingCape._reach(_fight(&"charge", BossFight.State.ACTIVE, 30))
	assert_almost_eq(tell, KingCape.GATHER_K, 0.001, "drawn in through the tell")
	assert_almost_eq(dash, KingCape.FLARE_K, 0.001, "flared behind the dash")
	var early: float = KingCape._reach(_fight(&"charge", BossFight.State.RECOVER, 2))
	var late: float = KingCape._reach(_fight(&"charge", BossFight.State.RECOVER, 60))
	assert_gt(early, 1.0, "still out just after he stops (follow-through)")
	assert_almost_eq(late, 1.0, 0.001, "settled")


func test_the_reach_eases_never_snaps() -> void:
	var a: float = KingCape._reach(_fight(&"ram", BossFight.State.WINDUP, 0))
	var b: float = KingCape._reach(_fight(&"ram", BossFight.State.WINDUP, 6))
	assert_almost_eq(a, 1.0, 0.001, "the tell's first tick is still at rest")
	assert_between(b, KingCape.GATHER_K, 1.0, "half-way drawn in")


func test_other_attacks_leave_the_cape_at_rest() -> void:
	for id: StringName in [&"coin_fan", &"decree"]:
		assert_eq(KingCape._reach(_fight(id, BossFight.State.ACTIVE, 10)), 1.0, String(id))
		assert_eq(KingCape._spread(_fight(id, BossFight.State.RECOVER, 0)), 1.0, String(id))


func test_the_slam_lands_the_hem_wide_then_settles() -> void:
	var leap: float = KingCape._reach(_fight(&"press_slam", BossFight.State.ACTIVE, 12))
	assert_almost_eq(leap, KingCape.FLARE_K, 0.001, "trailing behind the leap")
	var mid_air: float = KingCape._spread(_fight(&"press_slam", BossFight.State.ACTIVE, 12))
	assert_eq(mid_air, 1.0, "not spread before he lands")
	var land: float = KingCape._spread(_fight(&"press_slam", BossFight.State.RECOVER, 0))
	var later: float = KingCape._spread(_fight(&"press_slam", BossFight.State.RECOVER, 40))
	assert_gt(land, 1.05, "spread wide as he lands")
	assert_almost_eq(later, 1.0, 0.001, "settled")
	assert_eq(KingCape._spread(_fight(&"charge", BossFight.State.RECOVER, 0)), 1.0, "only the slam")
