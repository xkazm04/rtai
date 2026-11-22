extends GutTest
## Compare the disabled and unflagged outcomes byte-for-byte with the original bolt stun.

var arena: CombatArena
var squad: ArenaSquad


func before_each() -> void:
	var rng: RandomNumberGenerator = RngRegistry.new(23).stream(&"combat")
	arena = CombatArena.new(CombatTuning.shipped(), Events, rng)
	arena.guard_map = GuardRouteMap.new(Rect2(-20, -20, 40, 40), [], null, 0.45)
	squad = ArenaSquad.new(arena.guard_map)
	arena.squad_ai = squad


func _ordinary_hit(h: Fighter) -> void:
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped())
	stage.arena = arena
	stage.tick = 11
	var ohm: OhmStage = OhmStage.shipped()
	h.pos = Vector2(4, 0)
	h.facing = Vector2.LEFT
	var hp: float = h.hp
	var damage: float = (
		ohm.num(&"human_damage") * FoeArmor.k(h, Vector2.RIGHT, OhmStage.KILL_KIND, squad)
	)
	var ticks: int = PowerDef.ticks(ohm.num(&"stun_s"))
	ohm.drive(stage, true, true, Vector2.RIGHT)
	assert_eq(ohm.struck, 1)
	assert_almost_eq(h.hp, hp - damage, 0.00001)
	assert_eq(arena.areas.effect(h).stun_ticks, ticks)
	assert_false(OhmShortCircuit.held(squad, h))
	var row: Dictionary = {}
	arena.move_tally.append_wave(row)
	assert_false(row.has("moves"))
	var actual: StreamPeerBuffer = StreamPeerBuffer.new()
	arena.write_state(actual)
	# Reconstruct the same post-hit fighter and legacy area effect without the move.
	var original_squad: ArenaSquad = arena.squad_ai
	arena.squad_ai = null
	arena.areas = null
	PlayerShock.stun_on(PlayerShock.areas_of(arena), h, ticks)
	var legacy: StreamPeerBuffer = StreamPeerBuffer.new()
	arena.write_state(legacy)
	assert_eq(actual.data_array, legacy.data_array)
	arena.squad_ai = original_squad


func test_human_uses_the_ordinary_bolt_damage_and_electro_stun() -> void:
	var h: Fighter = squad.spawn_member(arena, Vector2.ZERO, &"contractor")
	assert_false(squad.pit.roster.archetype(h.archetype).machine)
	_ordinary_hit(h)


func test_robot_row_without_machine_flag_uses_the_ordinary_bolt() -> void:
	var h: Fighter = squad.spawn_member(arena, Vector2.ZERO, &"robot_thug")
	assert_true(h.machine, "the existing body material remains metal")
	assert_false(squad.pit.roster.archetype(h.archetype).machine)
	_ordinary_hit(h)


func test_disabled_move_leaves_flagged_machines_on_the_original_bolt_path() -> void:
	var h: Fighter = squad.spawn_member(arena, Vector2.ZERO, &"sentry_turret")
	assert_true(squad.pit.roster.archetype(h.archetype).machine)
	squad.moves.ohm_short_circuit.enabled = false
	arena.step(10)
	_ordinary_hit(h)
	assert_false(OhmShortCircuit.held(squad, h))


func test_only_stunned_members_append_their_two_deadlines_to_replay_state() -> void:
	var h: Fighter = squad.spawn_member(arena, Vector2.ZERO, &"war_machine")
	assert_true(squad.pit.roster.archetype(h.archetype).machine)
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	OhmShortCircuit.write_state(squad, h, out)
	assert_eq(out.get_size(), 0)
	arena.step(10)
	OhmShortCircuit.write_state(squad, h, out)
	assert_eq(out.get_size(), 0)
	assert_true(OhmShortCircuit.strike(arena, h, 11, 72))
	assert_eq(arena.areas.effect(h).stun_ticks, 72)
	OhmShortCircuit.write_state(squad, h, out)
	assert_eq(out.get_size(), 8)
	out.seek(0)
	assert_eq(out.get_32(), 47)
	assert_eq(out.get_32(), 251)
