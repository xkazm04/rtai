extends GutTest

const FIRST: StringName = &"effect_overkill_carry"
const SECOND: StringName = &"effect_overkill_carry_2"


func test_rank_requires_its_earlier_pick_and_each_rank_retires() -> void:
	var draw: GauntletDraw = GauntletDraw.new(RngRegistry.new(23))
	var first: Dictionary = draw.rows[FIRST]
	var second: Dictionary = draw.rows[SECOND]
	var first_weight: float = first["weight"]
	var second_weight: float = second["weight"]
	var required: StringName = second["requires"]
	assert_eq(first_weight, 2.0)
	assert_eq(second_weight, 2.0)
	assert_eq(required, FIRST)
	draw.rows.clear()
	draw.rows[FIRST] = first
	draw.rows[SECOND] = second
	var history: Array[Dictionary] = []
	assert_eq(draw.offer(2, history, []), [])
	assert_eq(draw.offer(3, history, []), [FIRST])
	assert_eq(draw.offer(6, history, []), [FIRST])
	history.append({"taken": FIRST})
	assert_eq(draw.offer(5, history, []), [])
	assert_eq(draw.offer(6, history, []), [SECOND])
	history.append({"taken": SECOND})
	assert_eq(draw.offer(7, history, []), [])


func test_requires_applies_to_any_row_and_unknown_effects_are_skipped() -> void:
	var draw: GauntletDraw = GauntletDraw.new(RngRegistry.new(23))
	var taken: Array[StringName] = []
	var gated: Dictionary = {"kind": "stat", "ref": "speed", "requires": String(FIRST)}
	assert_false(MoveBonus.offerable(gated, taken, draw.moves))
	taken.append(FIRST)
	assert_true(MoveBonus.offerable(gated, taken, draw.moves))
	assert_false(MoveBonus.offerable({"kind": "effect", "ref": "unknown"}, taken, draw.moves))


func test_disabled_effects_consume_no_offer_tickets() -> void:
	var a: RngRegistry = RngRegistry.new(23)
	var b: RngRegistry = RngRegistry.new(23)
	var disabled: GauntletDraw = GauntletDraw.new(a)
	var old: GauntletDraw = GauntletDraw.new(b)
	disabled.moves.overkill_carry.enabled = false
	assert_true(old.rows.erase(FIRST))
	assert_true(old.rows.erase(SECOND))
	var history: Array[Dictionary] = []
	for wave: int in range(1, old.rows.size() + 2):
		var before: Array[StringName] = old.offer(wave, history, [])
		assert_eq(disabled.offer(wave, history, []), before)
		assert_eq(a.stream(&"gauntlet_offers").state, b.stream(&"gauntlet_offers").state)
		if not before.is_empty():
			history.append({"taken": before[0]})
	var taken: Array[StringName] = [FIRST]
	assert_false(MoveBonus.offerable(disabled.rows[SECOND], taken, disabled.moves))


func test_apply_upgrades_only_the_held_effect_in_this_street_session() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	var session: GauntletSession = GauntletSession.open_street(bus, data, GauntletRun.new())
	var draw: GauntletDraw = GauntletDraw.new(session.world.context().rng)
	var squad: ArenaSquad = session.stage.arena.squad_ai
	assert_null(squad.carry)
	assert_false(session.bonuses.apply(draw.rows[SECOND]))
	squad.moves.overkill_carry.enabled = false
	assert_false(session.bonuses.apply(draw.rows[FIRST]))
	assert_null(squad.carry)
	squad.moves.overkill_carry.enabled = true
	assert_false(session.bonuses.apply({"kind": "effect", "ref": "unknown"}))
	assert_true(session.bonuses.apply(draw.rows[FIRST]))
	assert_eq(squad.carry.rank, 1)
	assert_false(session.bonuses.apply(draw.rows[FIRST]))
	assert_true(session.bonuses.apply(draw.rows[SECOND]))
	assert_eq(squad.carry.rank, 2)
	assert_false(session.bonuses.apply(draw.rows[SECOND]))
	var arena: CombatArena = session.stage.arena
	var a: Fighter = squad.spawn_member(arena, arena.rivet.pos, &"contractor")
	var b: Fighter = squad.spawn_member(arena, a.pos, &"robot_thug")
	a.pos = session.street.rest.body_position(a)
	b.pos = a.pos + Vector2.RIGHT
	var hp: float = b.hp
	arena.damage(a, a.hp + 1.0, arena.rivet.id, &"claw")
	assert_eq(b.hp, hp - 1.0)
	var wave: Dictionary = {}
	arena.move_tally.append_wave(wave)
	assert_eq(wave, {"moves": {"overkill_carry": 1}})
	session.close()
