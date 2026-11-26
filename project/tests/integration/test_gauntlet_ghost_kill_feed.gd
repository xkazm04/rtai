extends GutTest
## n31 merge (ghost's NEED on melee's feed): in the gauntlet street a kill by Tonnage's dump
## (weapon `stomp`, test_tonnage_dump_kills pins the dump -> stomp half) plays `tonnage_crush`,
## and Ohm's and Kerf's deploy kills play their own rows (`also_weapons`), through the street's
## BrutalityHook. A dump kill beyond crush_m (`stomp_wave`) keeps the thrown standard death.

var session: GauntletSession
var arena: CombatArena
var rows: Array[StringName] = []


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	session = GauntletSession.open_street(bus, data, GauntletRun.new())
	arena = session.stage.arena
	rows.clear()
	@warning_ignore("return_value_discarded")
	session.kills_hook.kills.killed.connect(_on_killed)


func after_each() -> void:
	session.close()


func _on_killed(_id: int, _serial: int, row: SignatureKill, _at: Vector2, _dir: Vector2) -> void:
	rows.append(row.id)


func _kill(weapon: StringName, kind: StringName = &"shot") -> Fighter:
	var at: Vector2 = arena.rivet.pos + Vector2.DOWN * 2.0
	var cop: Fighter = arena.squad_ai.spawn_member(arena, at, &"patrol_cop")
	cop.pos = at
	arena.hit_dir = Vector2.DOWN
	arena.hit_at = cop.pos - Vector2.DOWN * cop.radius_m
	arena.damage(cop, 99.0, arena.rivet.id, weapon, kind)
	session.kills_hook.step(session.stage, 1)
	return cop


func _row_starts(prefix: String) -> bool:
	return rows.size() == 1 and String(rows[0]).begins_with(prefix)


func test_a_dump_kill_inside_the_crush_ring_is_flattened() -> void:
	var cop: Fighter = _kill(&"stomp")
	assert_false(cop.alive())
	assert_true(_row_starts("tonnage_crush"), "rows %s" % str(rows))


func test_a_dump_kill_by_the_wave_keeps_the_thrown_death() -> void:
	var cop: Fighter = _kill(&"stomp_wave")
	assert_false(cop.alive())
	assert_true(rows.is_empty(), "the wave has no signature row: %s" % str(rows))


func test_ohm_and_kerf_deploy_kills_play_their_rows() -> void:
	assert_false(_kill(&"deploy_ohm", OhmStage.KILL_KIND).alive())
	assert_true(_row_starts("ohm_shock"), "rows %s" % str(rows))
	rows.clear()
	assert_false(_kill(&"deploy_kerf", KerfStage.KILL_KIND).alive())
	assert_true(_row_starts("kerf_split"), "rows %s" % str(rows))
