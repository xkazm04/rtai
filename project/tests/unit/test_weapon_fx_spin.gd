extends GutTest
## n7-ranged: the Gatling's spin-up whirl (WeaponFxSpin, hit_feel.json spin_whirl_m) shows only
## while the barrels turn below speed, never under --feel=off, and turns once per sim tick.


func after_each() -> void:
	WeaponFxSpin.reset()


func _gatling(spin: int) -> Trigger:
	var spec: WeaponSpec = WeaponSpec.new()
	spec.id = &"gatling"
	spec.spin_ticks = 30
	var trig: Trigger = Trigger.new(spec)
	trig.spin = spin
	return trig


func test_the_whirl_shows_only_below_speed() -> void:
	WeaponFxSpin.reset(HitFeel.shipped())
	assert_gt(WeaponFxSpin.width_m(_gatling(12)), 0.0, "spinning up: the whirl shows")
	assert_eq(WeaponFxSpin.width_m(_gatling(0)), 0.0, "at rest: nothing")
	assert_eq(WeaponFxSpin.width_m(_gatling(30)), 0.0, "at speed the flash takes over")


func test_feel_off_draws_no_whirl() -> void:
	var hf: HitFeel = HitFeel.shipped()
	hf.enabled = false
	WeaponFxSpin.reset(hf)
	assert_eq(WeaponFxSpin.width_m(_gatling(12)), 0.0)


func test_a_gun_without_a_row_draws_no_whirl() -> void:
	WeaponFxSpin.reset(HitFeel.shipped())
	var trig: Trigger = _gatling(12)
	trig.spec.id = &"pistol"
	assert_eq(WeaponFxSpin.width_m(trig), 0.0)


func test_the_turn_steps_once_per_tick_and_holds_in_a_stop() -> void:
	var a: float = WeaponFxSpin.phase(100, 1.0)
	var b: float = WeaponFxSpin.phase(101, 1.0)
	assert_almost_eq(b - a, WeaponFxSpin.TURN_MAX, 0.001, "one tick at full spin")
	assert_eq(WeaponFxSpin.phase(101, 1.0), b, "a held frame (hit-stop) does not turn it")
	assert_lt(WeaponFxSpin.TURN_MAX, TAU / 6.0, "under 60 deg a tick: no backwards strobe")
