extends GutTest
## n31 foes lever 5: production squad members fire their own enemies.json gun (FoeOwnGun).

var rng: RandomNumberGenerator
var arena: CombatArena


func before_each() -> void:
	rng = RngRegistry.new(12).stream(&"combat")
	arena = CombatArena.new(CombatTuning.shipped(), Events, rng)
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	arena.rivet.hp = 10000
	arena.rivet.max_hp = 10000


func test_table_turns_own_weapons_on_with_a_damage_per_gun() -> void:
	var r: EnemyRoster = EnemyRoster.shipped(EnemyRoster.TABLE, true)
	assert_true(r.own_weapons)
	for id: StringName in [&"pistol", &"rifle", &"cannon"]:
		assert_true(r.own_damage.has(id), id)
		assert_gt(r.own_damage[id], 0.0, id)
	r.max_shooters = 2
	assert_false(r.own_weapons, "a stage that writes its own cap keeps the shared rifle")


func test_each_production_ranged_kind_fires_its_own_gun() -> void:
	var want: Dictionary[StringName, bool] = {
		&"patrol_cop": true,
		&"swat": true,
		&"contractor": true,
		&"robot_gunner": true,
		&"riot_cop": false,
		&"rocket_trooper": false,
	}
	var roster: EnemyRoster = arena.squad_ai.pit.roster
	for id: StringName in want:
		var h: Fighter = arena.squad_ai.spawn_member(arena, Vector2.RIGHT, id)
		var e: EnemyAgent = arena.squad_ai.mind_for(h).agent
		assert_eq(FoeOwnGun.carries(h, e, roster), want[id], id)
		if want[id]:
			assert_eq(h.weapon, &"assault-rifle", "it keeps the rifle it drops")
	roster.own_weapons = false
	var cop: Fighter = arena.squad_ai.spawn_member(arena, Vector2.RIGHT, &"patrol_cop")
	assert_false(FoeOwnGun.carries(cop, arena.squad_ai.mind_for(cop).agent, roster))


func test_pistol_fires_its_burst_at_its_own_damage_and_cadence() -> void:
	var h: Fighter = arena.squad_ai.spawn_member(arena, Vector2.RIGHT, &"patrol_cop")
	@warning_ignore("return_value_discarded")
	arena.squad_ai.assign(arena)
	var mind: SquadMind = arena.squad_ai.minds[h.id]
	var pit: EnemyPit = arena.squad_ai.pit
	var w: EnemyWeapon = mind.agent.arch.weapon
	h.cooldown = 0
	var fired: Array[int] = []
	for tick: int in 200:
		var shot: Shot = FoeOwnGun.trigger(h, mind, arena, pit, rng)
		if shot != null:
			fired.append(tick)
			assert_eq(shot.weapon, &"pistol")
			assert_eq(shot.damage, pit.roster.own_damage[&"pistol"])
			assert_eq(shot.size, Shot.SMALL)
			assert_false(shot.from_rivet)
	assert_eq(fired.slice(0, 2), [1, 2 + w.burst_gap_ticks] as Array[int], "a 2-round burst")
	# GuardBrain's cadence: the cooldown counts after the last round, whose gap carries over.
	var cycle: int = w.cooldown_ticks + 2 + w.burst_gap_ticks
	assert_eq(fired[2] - fired[1], cycle, "the cooldown runs after the burst")
