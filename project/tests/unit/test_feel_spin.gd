extends GutTest
## Lane n7-ranged: the Gatling's spin-up tremor (hit_feel.json spin_rumble_px). It grows with the
## barrels' spin, stops once they reach firing speed (the fire kick takes over), and --feel=off or
## a weapon without the row means none.


func _cam(weapon: StringName) -> FeelCam:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(5)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	arena.gun = GunHand.make(WeaponTable.shipped(), weapon, reg.stream(&"gunplay"))
	return FeelCam.attach(arena, null, HitFeel.shipped())


func _peak(cam: FeelCam, spin: int) -> float:
	cam._arena.gun.trigger.spin = spin
	var peak: float = 0.0
	for t: int in range(100, 160):
		peak = maxf(peak, cam.spin_tremor(t).length())
	return peak


func test_the_tremor_grows_with_the_spin_and_stops_at_speed() -> void:
	var cam: FeelCam = _cam(&"gatling")
	var full: int = cam._arena.gun.trigger.spec.spin_ticks
	assert_gt(full, 0, "the gatling spins up")
	assert_eq(_peak(cam, 0), 0.0, "barrels still: none")
	var low: float = _peak(cam, full / 4)
	var high: float = _peak(cam, full - 1)
	assert_gt(low, 0.0)
	assert_gt(high, low, "grows with the spin")
	assert_lte(high, cam.feel.spin_row(&"gatling") * 1.42, "inside its row")
	assert_eq(_peak(cam, full), 0.0, "at speed the fire kick takes over")


func test_off_and_other_weapons_mean_no_tremor() -> void:
	var cam: FeelCam = _cam(&"gatling")
	cam.feel.enabled = false
	assert_eq(_peak(cam, 10), 0.0, "--feel=off")
	var pistol: FeelCam = _cam(&"pistol")
	assert_eq(_peak(pistol, 10), 0.0, "no spin, no row")
