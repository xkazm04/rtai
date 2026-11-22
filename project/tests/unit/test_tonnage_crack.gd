extends GutTest

const S := EnemyAgent.State

var arena: CombatArena
var squad: ArenaSquad
var walker: Fighter
var mind: SquadMind


func before_each() -> void:
	var rng: RandomNumberGenerator = RngRegistry.new(23).stream(&"combat")
	arena = CombatArena.new(CombatTuning.shipped(), Events, rng)
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	squad = ArenaSquad.new(arena.guard_map)
	arena.squad_ai = squad
	walker = squad.spawn_member(arena, Vector2.ZERO, &"war_machine")
	walker.pos = Vector2(2, 0)
	walker.facing = Vector2.LEFT
	walker.cooldown = 0
	mind = squad.mind_for(walker)


func _step() -> void:
	arena.step(arena.tick + 1)


func _until(state: EnemyAgent.State) -> void:
	for i: int in 300:
		if mind.agent.state == state:
			return
		_step()
	fail_test("walker never entered %s" % S.keys()[state])


func _hit(weapon: StringName, killer: int = 0) -> float:
	var hp: float = walker.hp
	arena.hit_dir = -walker.facing
	arena.damage(walker, 1.0, killer, weapon)
	return hp - walker.hp


func _uses() -> int:
	var wave: Dictionary = {}
	arena.move_tally.append_wave(wave)
	var moves: Dictionary = wave.get("moves", {})
	return moves.get("tonnage_armour_crack", 0)


func _state() -> PackedByteArray:
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	TonnageCrack.write_state(arena, walker, out)
	return out.data_array


func test_only_rivets_tonnage_hit_in_resolved_stomp_recovery_can_open() -> void:
	assert_eq(mind.agent.state, S.ENGAGE)
	assert_eq(_hit(&"ram"), 0.5)
	_until(S.WINDUP)
	assert_eq(_hit(&"stomp"), 0.5)
	_until(S.RECOVER)
	assert_eq(_hit(&"gloria"), 0.5)
	assert_eq(_hit(&"stomp", walker.id), 0.5)
	walker.exposed = false
	assert_eq(_hit(&"stomp_wave"), 0.0)
	walker.exposed = true
	assert_eq(_uses(), 0)
	assert_eq(_state(), PackedByteArray())
	assert_eq(_hit(&"stomp_wave"), 1.0)
	assert_eq(_uses(), 1)


func test_shell_recovery_never_opens() -> void:
	walker.pos = Vector2(11, 0)
	_until(S.RECOVER)
	assert_eq(mind.walker.attack.id, &"war_cannon")
	assert_eq(_hit(&"stomp"), 0.5)
	assert_eq(_uses(), 0)
	assert_eq(_state(), PackedByteArray())


func test_open_front_lasts_240_ticks_and_rear_never_changes() -> void:
	_until(S.RECOVER)
	assert_eq(FoeArmor.k(walker, walker.facing, &"shot", squad), 1.5)
	assert_eq(_hit(&"ram"), 1.0)
	var start: int = arena.tick
	assert_eq(_state().decode_s32(0), start)
	_step()
	assert_eq(_hit(&"stomp"), 1.0)
	assert_eq(_uses(), 1)
	for i: int in 238:
		_step()
	assert_eq(arena.tick, start + 239)
	assert_eq(_hit(&"gloria"), 1.0)
	assert_eq(FoeArmor.k(walker, walker.facing, &"shot", squad), 1.5)
	_step()
	assert_eq(_hit(&"gloria"), 0.5)
	assert_eq(_state(), PackedByteArray())


func test_actual_frontal_pistol_round_lands_at_full_damage() -> void:
	_until(S.RECOVER)
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped())
	stage.arena = arena
	stage.tick = arena.tick
	var hauler: HaulerStage = HaulerStage.shipped()
	arena.rivet.facing = Vector2.RIGHT
	for i: int in walker.cooldown:
		stage.tick += 1
		@warning_ignore("return_value_discarded")
		hauler.drive(stage, i == 0, i == 0, Vector2.ZERO)
		_step()
		if hauler.stomp_hits > 0:
			break
	assert_eq(hauler.stomp_hits, 1)
	assert_eq(_uses(), 1)
	arena.rivet.weapon = &"gloria"
	var hp: float = walker.hp
	assert_true(arena.rivet_fire(walker.pos))
	for i: int in 12:
		_step()
		if arena.shots.is_empty():
			break
	assert_eq(hp - walker.hp, arena.tuning.weapon(&"gloria").damage)


func test_short_opening_stays_spent_until_the_next_stomp() -> void:
	var row: MoveTable.ArmourCrack = squad.moves.tonnage_armour_crack
	row.open_ticks = 1
	row.open_front_k = 0.75
	_until(S.RECOVER)
	assert_eq(_hit(&"ram"), 0.75)
	var spent: PackedByteArray = _state()
	assert_eq(spent.size(), 4)
	_step()
	assert_eq(_hit(&"ram"), 0.5)
	assert_eq(_state(), spent)
	assert_eq(_uses(), 1)
	_until(S.WINDUP)
	assert_eq(_state(), PackedByteArray())
	_until(S.RECOVER)
	assert_eq(_hit(&"stomp"), 0.75)
	assert_eq(_uses(), 2)


func test_disabled_move_keeps_the_front_plate_and_default_replay_bytes() -> void:
	squad.moves.tonnage_armour_crack.enabled = false
	_until(S.RECOVER)
	assert_eq(_hit(&"ram"), 0.5)
	assert_eq(_hit(&"stomp"), 0.5)
	assert_eq(_uses(), 0)
	assert_eq(_state(), PackedByteArray())


func test_loader_reads_crack_duration_and_multiplier_from_the_row() -> void:
	var source: DataTable = DataTable.open(CombatTuning.TABLE, CombatTuning.SCHEMA)
	var block: Dictionary = source.object(source.raw, "moves")
	var row: Dictionary = source.object(block, "tonnage_armour_crack")
	row.merge({"enabled": false, "open_s": 0.25, "open_front_k": 0.875}, true)
	var moves: MoveTable = MoveTable.from_table(source)
	assert_eq(moves.errors, [])
	assert_false(moves.tonnage_armour_crack.enabled)
	assert_eq(moves.tonnage_armour_crack.open_ticks, 15)
	assert_eq(moves.tonnage_armour_crack.open_front_k, 0.875)
