extends GutTest
## features/audio hooks: Events and FX cues become sounds (headless, dummy audio driver).

var _tick: int = 0
var _bus: EventBus = null
var _service: AudioService = null
var _hooks: AudioHooks = null


func before_each() -> void:
	_tick = 1000
	_bus = EventBus.new()
	add_child_autofree(_bus)
	_service = AudioService.new(AudioTables.shipped(), 3)
	add_child_autofree(_service)
	_hooks = AudioHooks.new()
	_service.add_child(_hooks)
	_hooks.attach(
		_service, _bus, func() -> int: return _tick, func() -> Vector2: return Vector2.ZERO
	)


func test_the_electroshock_crackle_follows_a_robo_tazer_hit() -> void:
	_bus.player_hit.emit(&"robo-tazer")
	var body: int = _service.played.get(&"player_hit", 0)
	var zap: int = _service.played.get(&"player_hit_robo_tazer", 0)
	assert_eq(body, 1)
	assert_eq(zap, 1)


func test_a_nail_hit_is_only_the_body_blow() -> void:
	_bus.player_hit.emit(&"gloria")
	var zap: int = _service.played.get(&"player_hit_robo_tazer", 0)
	assert_eq(zap, 0)


func test_fx_owned_hits_are_not_doubled() -> void:
	_hooks.fx_cues = true
	_bus.player_hit.emit(&"robo-tazer")
	var body: int = _service.played.get(&"player_hit", 0)
	assert_eq(body, 0, "the FX trigger sink voices it with a position")


func test_a_wave_starts_a_panic() -> void:
	_bus.wave_started.emit(&"dock-9", 1)
	var panic: int = _service.played.get(&"crowd_panic", 0)
	assert_eq(panic, 1)


func test_the_siren_follows_the_wanted_level() -> void:
	_bus.wanted_changed.emit(2)
	assert_true(_service.loops.is_on(&"siren_loop"))
	_bus.wanted_changed.emit(0)
	assert_false(_service.loops.is_on(&"siren_loop"))


func test_the_engine_bed_follows_the_car() -> void:
	_bus.vehicle_entered.emit(7)
	assert_true(_service.loops.is_on(&"engine_loop"))
	_bus.vehicle_exited.emit(7)
	assert_false(_service.loops.is_on(&"engine_loop"))


func test_a_voice_line_queues_behind_the_one_speaking() -> void:
	var s: AudioStream = load("res://assets/audio/voice/rivet-my-hands.ogg") as AudioStream
	assert_true(_service.voice.speak("a", s))
	assert_true(_service.voice.speak("b", s))
	assert_eq(_service.voice.line_id, "a", "b waits, it does not cut a")
	assert_true(_service.voice.speak("d", s))
	assert_true(_service.voice.speak("e", s))
	assert_eq(_service.voice.dropped_ids, ["b"], "the oldest waiting line is the one lost")
	assert_false(_service.voice.speak("c", null))


func test_a_step_comes_every_stride_not_every_frame() -> void:
	_service.frame_s = 1.0 / 60.0
	_hooks.walk_to(Vector2.ZERO, _service.frame_s)
	var x: float = 0.0
	for i: int in 120:
		x += 0.04
		_tick += 1
		_hooks.walk_to(Vector2(x, 0.0), _service.frame_s)
	assert_between(_hooks.steps, 3, 5, "4.8 m at 2.4 m/s with a 1.15 m stride = 4 steps")


func test_standing_still_makes_no_step() -> void:
	_service.frame_s = 1.0 / 60.0
	for i: int in 60:
		_tick += 1
		_hooks.walk_to(Vector2(0.001 * i, 0.0), _service.frame_s)
	assert_eq(_hooks.steps, 0)


func test_a_run_over_is_a_thud_and_a_kill_adds_the_death() -> void:
	var bus: EventBus = EventBus.new()
	add_child_autofree(bus)
	if not bus.has_signal(&"pedestrian_struck"):  # the vehicles lane declares it once merged
		bus.add_user_signal(
			"pedestrian_struck",
			[{"name": "victim_id", "type": TYPE_INT}, {"name": "killed", "type": TYPE_BOOL}]
		)
	var hooks: AudioHooks = AudioHooks.new()
	_service.add_child(hooks)
	hooks.attach(_service, bus, func() -> int: return _tick, func() -> Vector2: return Vector2.ZERO)
	@warning_ignore("return_value_discarded")
	bus.emit_signal("pedestrian_struck", 5, false)
	var thud: int = _service.played.get(&"hit_flesh", 0)
	var death: int = _service.played.get(&"death", 0)
	assert_eq(thud, 1)
	assert_eq(death, 0)
	_tick += 50
	@warning_ignore("return_value_discarded")
	bus.emit_signal("pedestrian_struck", 6, true)
	death = _service.played.get(&"death", 0)
	assert_eq(death, 1)


func test_a_tackle_is_a_body_thud_where_the_defender_fell() -> void:
	var bus: EventBus = EventBus.new()
	add_child_autofree(bus)
	if not bus.has_signal(&"actor_knocked_down"):  # the bodies lane declares it once merged
		(
			bus
			. add_user_signal(
				"actor_knocked_down",
				[
					{"name": "attacker_id", "type": TYPE_INT},
					{"name": "defender_id", "type": TYPE_INT},
					{"name": "defender_class", "type": TYPE_STRING_NAME},
					{"name": "at", "type": TYPE_VECTOR2},
				]
			)
		)
	var hooks: AudioHooks = AudioHooks.new()
	_service.add_child(hooks)
	hooks.attach(_service, bus, func() -> int: return _tick, func() -> Vector2: return Vector2.ZERO)
	@warning_ignore("return_value_discarded")
	bus.emit_signal("actor_knocked_down", 1, 7, &"human", Vector2(3.0, 4.0))
	assert_eq(_played(&"body_fall"), 1)
	assert_eq(_service.bank.missing.size(), 0, "the three takes load")


func test_cash_up_dings_and_cash_down_is_silent() -> void:
	_bus.cash_changed.emit(100, -20)
	assert_eq(_played(&"cash_ding"), 0)
	_bus.cash_changed.emit(300, 200)
	assert_eq(_played(&"cash_ding"), 1)


func test_a_contract_pings_when_it_starts_and_confirms_when_done() -> void:
	_bus.contract_started.emit(&"collect-call")
	_bus.contract_completed.emit(&"collect-call")
	assert_eq(_played(&"objective_ping"), 1)
	assert_eq(_played(&"ui_confirm"), 1)


func _played(id: StringName) -> int:
	return _service.played.get(id, 0)


func test_a_robo_tazer_wind_up_charges_and_a_boss_gets_its_stinger() -> void:
	_bus.attack_telegraphed.emit(&"robo-tazer")
	assert_eq(_played(&"tazer_charge"), 1)
	assert_eq(_played(&"attack_telegraphed"), 0)
	_bus.attack_telegraphed.emit(&"slam")
	assert_eq(_played(&"attack_telegraphed"), 1)
	_bus.boss_engaged.emit(&"robo-tazer")
	assert_eq(_played(&"boss_stinger"), 1)


func test_rivets_kill_punches_only_where_the_stage_asks() -> void:
	_bus.actor_killed.emit(1, 9, &"shot")
	assert_eq(_played(&"rivet_kill"), 0, "the FX sink owns it in the riot")
	_hooks.rivet_id = 1
	_bus.actor_killed.emit(2, 8, &"shot")
	assert_eq(_played(&"rivet_kill"), 0, "someone else's kill")
	_bus.actor_killed.emit(1, 7, &"shot")
	assert_eq(_played(&"rivet_kill"), 1)


func test_the_riot_roar_swells_with_the_gunfire_and_fades_after() -> void:
	var bed: RiotBed = RiotBed.new()
	for i: int in 120:
		_service.played[&"shot"] = _service.played.get(&"shot", 0) + 1
		bed.step(_service, 1.0 / 60.0)
	assert_gt(bed.intensity, 0.3, "two seconds of fire")
	assert_true(_service.loops.is_on(&"crowd_roar"))
	var peak: float = bed.intensity
	for i: int in 60 * 20:
		bed.step(_service, 1.0 / 60.0)
	assert_lt(bed.intensity, peak * 0.1, "twenty quiet seconds")
	assert_false(_service.loops.is_on(&"crowd_roar"))
