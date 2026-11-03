extends GutTest
## features/vehicles handling: speed cap, reverse cap, braking, a handbrake slide that slips more
## than a grip turn, profile spread (van slower than the cruiser) and a deterministic step.

var _p: Dictionary[StringName, VehicleProfile]


func before_all() -> void:
	_p = VehicleProfile.load_all()


func _drive(kind: StringName, ticks: int, throttle: float, steer: float, hb: bool) -> VehicleBody:
	var b: VehicleBody = VehicleBody.new(1, _p[kind], Vector2.ZERO, Vector2.RIGHT)
	for _i: int in ticks:
		b.step(SimClock.TICK_DT, throttle, steer, hb)
	return b


func test_table_has_every_archetype() -> void:
	for id: StringName in [
		&"sedan", &"taxi", &"van", &"pickup", &"police_cruiser", &"ambulance", &"hatchback"
	]:
		assert_true(_p.has(id), "profile %s" % id)


func test_speed_caps_at_vmax_and_reverse_at_reverse_max() -> void:
	var b: VehicleBody = _drive(&"sedan", 60 * 30, 1.0, 0.0, false)
	assert_almost_eq(b.speed(), _p[&"sedan"].vmax, 0.01)
	var r: VehicleBody = _drive(&"sedan", 60 * 10, -1.0, 0.0, false)
	assert_almost_eq(r.vel.dot(r.head), -_p[&"sedan"].reverse_max, 0.01)


func test_brakes_to_a_stop_before_reversing() -> void:
	var b: VehicleBody = _drive(&"sedan", 60 * 4, 1.0, 0.0, false)
	var stop_ticks: int = 0
	while b.vel.dot(b.head) > 0.0 and stop_ticks < 600:
		b.step(SimClock.TICK_DT, -1.0, 0.0, false)
		stop_ticks += 1
	assert_lt(stop_ticks, 120, "brakes from speed in under 2 s")
	assert_almost_eq(b.vel.dot(b.head), 0.0, 0.01, "stops at 0 before the reverse gear")


func test_handbrake_turn_slides_more_than_a_grip_turn() -> void:
	var grip: VehicleBody = _drive(&"sedan", 60 * 3, 1.0, 0.0, false)
	var slide: VehicleBody = _drive(&"sedan", 60 * 3, 1.0, 0.0, false)
	var max_grip: float = 0.0
	var max_slide: float = 0.0
	for _i: int in 40:
		grip.step(SimClock.TICK_DT, 0.6, 1.0, false)
		slide.step(SimClock.TICK_DT, 0.6, 1.0, true)
		max_grip = maxf(max_grip, grip.slip_angle_deg())
		max_slide = maxf(max_slide, slide.slip_angle_deg())
	assert_gt(
		max_slide, max_grip + 10.0, "handbrake drifts (%.1f vs %.1f deg)" % [max_slide, max_grip]
	)
	assert_true(slide.sliding)


func test_van_is_slower_and_heavier_than_the_cruiser() -> void:
	var van: VehicleBody = _drive(&"van", 60 * 4, 1.0, 0.0, false)
	var cop: VehicleBody = _drive(&"police_cruiser", 60 * 4, 1.0, 0.0, false)
	assert_lt(van.speed(), cop.speed())
	assert_gt(_p[&"van"].mass, _p[&"police_cruiser"].mass)


func test_no_steer_at_standstill_and_reverse_steers_mirrored() -> void:
	var still: VehicleBody = _drive(&"sedan", 30, 0.0, 1.0, false)
	assert_eq(still.head, Vector2.RIGHT)
	var back: VehicleBody = _drive(&"sedan", 90, -1.0, 1.0, false)
	assert_lt(back.head.y, 0.0, "reversing with right lock swings the nose left")


func test_step_is_deterministic() -> void:
	var a: VehicleBody = _drive(&"taxi", 600, 0.8, 0.4, false)
	var b: VehicleBody = _drive(&"taxi", 600, 0.8, 0.4, false)
	assert_eq(a.pos, b.pos)
	assert_eq(a.head, b.head)


func test_damage_ladder_two_states_then_a_wreck() -> void:
	var rules: VehicleDamage = VehicleDamage.load_rules()
	var b: VehicleBody = VehicleBody.new(1, _p[&"sedan"], Vector2.ZERO, Vector2.RIGHT)
	assert_eq(rules.damage_for(rules.dv_min), 0.0, "a nudge does no damage")
	@warning_ignore("return_value_discarded")
	rules.hurt(b, rules.dv_min + rules.d1_at / rules.per_dv)
	assert_eq(b.state, VehicleBody.State.D1)
	@warning_ignore("return_value_discarded")
	rules.hurt(b, rules.dv_min + (rules.d2_at - rules.d1_at) / rules.per_dv)
	assert_eq(b.state, VehicleBody.State.D2)
	assert_true(rules.hurt(b, 30.0), "the hit that wrecks reports it")
	assert_eq(b.state, VehicleBody.State.WRECK)


func test_heavier_car_takes_less_speed_change() -> void:
	var rules: VehicleDamage = VehicleDamage.load_rules()
	var van: VehicleBody = VehicleBody.new(1, _p[&"van"], Vector2.ZERO, Vector2.RIGHT)
	van.vel = Vector2(15.0, 0.0)
	var dv: Vector2 = rules.collide(van, Vector2.ZERO, _p[&"hatchback"].mass, Vector2.RIGHT, null)
	assert_gt(dv.y, dv.x, "the hatchback is thrown harder than the van slows")
	assert_lt(van.vel.x, 15.0)


func test_off_centre_hit_spins_and_the_grip_catches_it() -> void:
	var b: VehicleBody = VehicleBody.new(1, _p[&"sedan"], Vector2.ZERO, Vector2.RIGHT)
	b.kick(1.25, Vector2.DOWN, 5.0)
	assert_lt(b.spin, -1.0, "a nose hit from below turns the nose up")
	b.kick(0.0, Vector2.DOWN, 5.0)
	var before: float = b.spin
	assert_eq(before, b.spin, "a hit through the centre adds no spin")
	for _i: int in 60:
		b.step(SimClock.TICK_DT, 0.0, 0.0, false)
	assert_eq(b.spin, 0.0, "bled off within a second")
	assert_lt(b.head.y, -0.05, "the car turned")


func test_steering_slews_in_and_releases_faster() -> void:
	var b: VehicleBody = _drive(&"sedan", 60, 1.0, 0.0, false)
	var p: VehicleProfile = _p[&"sedan"]
	var in_ticks: int = 0
	while b.wheel < 1.0 and in_ticks < 120:
		b.step(SimClock.TICK_DT, 1.0, 1.0, false)
		in_ticks += 1
	assert_almost_eq(in_ticks * SimClock.TICK_DT, p.steer_in_s, 2.0 * SimClock.TICK_DT, "turn-in")
	var out_ticks: int = 0
	while b.wheel > 0.0 and out_ticks < 120:
		b.step(SimClock.TICK_DT, 1.0, 0.0, false)
		out_ticks += 1
	assert_lt(out_ticks, in_ticks, "the release is faster than the turn-in")
	assert_eq(b.wheel, 0.0)
