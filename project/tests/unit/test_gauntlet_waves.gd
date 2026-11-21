extends GutTest

const Entry = preload("res://dev/gauntlet/gauntlet.gd")

var run: GauntletRun
var session: GauntletSession
var waves: GauntletWaves


func before_each() -> void:
	run = GauntletRun.new()
	run.seed = 7
	var picker: GauntletPilot = GauntletPilot.new()
	picker.configure(&"average", &"greedy", run.seed)
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	session = GauntletSession.open_street(bus, data, run, picker)
	waves = GauntletWaves.attach(session, run, picker, 1)


func after_each() -> void:
	session.close()


func _enter() -> void:
	session.stage.arena.rivet.pos = Vector2(session.street.current().end_x() + 0.1, 0)
	session.step()


func test_crossing_starts_wave_and_holds_the_seam_until_the_last_kill() -> void:
	session.step()
	assert_eq(run.wave, 0)
	_enter()
	assert_eq(run.wave, 1)
	var arena: CombatArena = session.stage.arena
	var original: Array[Fighter] = arena.hostiles.duplicate()
	var counts: Dictionary = {}
	for member: Fighter in original:
		var id: String = String(member.archetype)
		var previous: int = counts.get(id, 0)
		counts[id] = previous + 1
	var actual: Dictionary = run.waves[0]["enemies"]
	assert_eq(actual, counts)
	assert_gt(original.size(), 0)
	_enter()
	assert_eq(session.street.index, 1)
	assert_eq(arena.hostiles, original)
	assert_false(waves.done)
	assert_true(run.picks.is_empty())
	for member: Fighter in original:
		arena.damage(member, member.max_hp * 10, arena.rivet.id, &"claw")
	session.step()
	assert_true(waves.done)
	assert_true(run.alive)
	assert_false(run.to_result().has("death"))
	var hits: int = run.waves[0]["hits"]
	assert_eq(hits, original.size())
	var seconds: float = run.waves[0]["seconds"]
	assert_almost_eq(seconds, 2 * SimClock.TICK_DT, 0.00001)
	assert_eq(run.picks.size(), 1)
	var offered: Array[StringName] = run.picks[0]["offered"]
	assert_eq(offered.size(), 3)
	var taken: StringName = run.picks[0]["taken"]
	assert_eq(taken, offered[0])
	assert_eq(session.street.forward_limit, INF)


func test_retreating_guard_stays_on_the_road_and_in_the_squad() -> void:
	_enter()
	var arena: CombatArena = session.stage.arena
	var guard_fighter: Fighter = arena.hostiles[0]
	var block: GauntletSegment = session.street.current()
	var turret: Fighter = arena.squad_ai.spawn_member(arena, block.spawns[0], &"sentry_turret")
	turret.pos.x = block.end_x() + turret.radius_m
	guard_fighter.pos.y = block.bounds.end.y + guard_fighter.radius_m
	session.step()
	var road: Rect2 = block.road_bounds(guard_fighter.radius_m)
	assert_between(guard_fighter.pos.y, road.position.y, road.end.y)
	assert_almost_eq(turret.pos.x, session.street.forward_limit, 0.00001)
	assert_true(arena.squad_ai.owns(turret))
	assert_true(arena.squad_ai.owns(guard_fighter))
	assert_true(arena.squad_ai.minds.has(guard_fighter.id))
	assert_false(waves.done)


func test_timeout_keeps_measured_counts_and_omits_time_to_clear() -> void:
	_enter()
	var start: int = session.stage.arena.tick
	waves.step(session.stage, start + GauntletWaves.TIMEOUT_TICKS - 1)
	assert_false(waves.done)
	waves.step(session.stage, start + GauntletWaves.TIMEOUT_TICKS)
	assert_true(waves.done)
	var death: Dictionary = run.to_result()["death"]
	assert_eq(death, {"wave": 1, "by": "timeout"})
	assert_false(run.waves[0].has("seconds"))
	assert_false(run.waves[0].has("guard_deflects"))
	var shots: int = run.waves[0]["shots"]
	assert_eq(shots, 0)
	assert_true(run.picks.is_empty())


func test_written_wave_and_pick_match_the_result_schema() -> void:
	_enter()
	var arena: CombatArena = session.stage.arena
	for member: Fighter in arena.hostiles:
		arena.damage(member, member.max_hp * 10, arena.rivet.id, &"claw")
	session.step()
	var entry: Entry = Entry.new()
	entry.run = run
	var path: String = TestTmp.dir("gauntlet").path_join("result.json")
	var written: bool = entry._write_result(path)
	entry.free()
	assert_true(written)
	var schema: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string("res://data/schemas/gauntlet_run.schema.json")
	)
	var result: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	_check_object(result, schema)
	var wave: Dictionary = result["waves"][0]
	var wave_spec: Dictionary = schema["$defs"]["wave"]
	_check_object(wave, wave_spec)
	var pick: Dictionary = result["picks"][0]
	var pick_spec: Dictionary = schema["properties"]["picks"]["items"]
	_check_object(pick, pick_spec)
	var schema_id: String = schema["properties"]["schema"]["const"]
	var actual_id: String = result["schema"]
	assert_eq(actual_id, schema_id)


func _check_object(value: Dictionary, definition: Dictionary) -> void:
	var required: Array = definition["required"]
	var allowed: Dictionary = definition["properties"]
	for key: String in required:
		assert_true(value.has(key), "required field %s" % key)
	for key: String in value:
		assert_true(allowed.has(key), "unknown field %s" % key)


func test_lethal_projectile_identifies_the_weapon() -> void:
	_enter()
	var arena: CombatArena = session.stage.arena
	var shot: Shot = Shot.new()
	shot.from_rivet = false
	shot.pos = arena.rivet.pos
	shot.vel = Vector2.RIGHT
	shot.damage = arena.rivet.max_hp
	shot.weapon = &"assault-rifle"
	arena.shots.append(shot)
	session.step()
	assert_true(waves.done)
	var death: Dictionary = run.to_result()["death"]
	assert_eq(death, {"wave": 1, "by": "assault-rifle"})
	var damage: float = run.waves[0]["damage_taken"]
	assert_eq(damage, arena.rivet.max_hp)
	assert_false(run.waves[0].has("seconds"))
