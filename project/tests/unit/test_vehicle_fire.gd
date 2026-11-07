extends GutTest
## features/vehicles VehicleFire: a wreck burns for BURN_S seconds (shrinking over the last
## FADE_S), intact cars never do, and each burning wreck holds one `fire` light until it goes out.


func _service() -> VehicleService:
	var svc: VehicleService = VehicleService.new()
	svc.profiles = VehicleProfile.load_all()
	svc.world = VehicleWorld.new()
	return svc


func _fire(svc: VehicleService, lights: LightLayer = null) -> VehicleFire:
	var fire: VehicleFire = autofree(VehicleFire.new())
	fire.service = svc
	fire.lights = lights
	return fire


func test_flame_burns_then_fades_out() -> void:
	assert_eq(VehicleFire.flame(-0.1), 0.0)
	assert_eq(VehicleFire.flame(0.0), 1.0)
	assert_eq(VehicleFire.flame(VehicleFire.BURN_S - VehicleFire.FADE_S), 1.0)
	assert_almost_eq(VehicleFire.flame(VehicleFire.BURN_S - VehicleFire.FADE_S * 0.5), 0.5, 1e-4)
	assert_eq(VehicleFire.flame(VehicleFire.BURN_S), 0.0)


func test_only_young_wrecks_burn() -> void:
	var svc: VehicleService = _service()
	var intact: VehicleBody = svc.spawn_parked(&"sedan", Vector2(0, 0), Vector2.RIGHT)
	var young: VehicleBody = svc.spawn_parked(&"sedan", Vector2(10, 0), Vector2.RIGHT)
	var old: VehicleBody = svc.spawn_parked(&"sedan", Vector2(20, 0), Vector2.RIGHT)
	young.state = VehicleBody.State.WRECK
	young.wreck_t = 3.0
	old.state = VehicleBody.State.WRECK
	old.wreck_t = VehicleFire.BURN_S + 1.0
	var ids: PackedInt32Array = _fire(svc).burning()
	assert_eq(ids.size(), 1)
	assert_true(ids.has(young.id))
	assert_false(ids.has(intact.id))


func test_a_burning_wreck_holds_one_fire_light_until_it_goes_out() -> void:
	var svc: VehicleService = _service()
	var b: VehicleBody = svc.spawn_parked(&"sedan", Vector2(10, 0), Vector2.RIGHT)
	b.state = VehicleBody.State.WRECK
	var lights: LightLayer = autofree(LightLayer.new())
	var fire: VehicleFire = _fire(svc, lights)
	fire._process(0.0)
	assert_eq(fire._lit.size(), 0, "no fire light in daylight")
	lights.grade = &"night"
	fire._process(0.0)
	fire._process(0.0)
	assert_eq(fire._lit.size(), 1)
	assert_eq(lights.dropped, 0)
	b.wreck_t = VehicleFire.BURN_S
	fire._process(0.0)
	assert_eq(fire._lit.size(), 0)


func test_the_pitch_fire_sheets_exist_and_top_draws_none() -> void:
	for art: String in ["p55", "p70"]:
		assert_true(ResourceLoader.exists(VehicleFire.PITCH_SHEET % art), art)
	if ViewMode.shared().art == "":
		assert_null(VehicleFire.pitch_sheet(), "top: the flat burst, no pitch sheet")
	VehicleFire.pitch_art = false
	assert_null(VehicleFire.pitch_sheet())
	VehicleFire.pitch_art = true
