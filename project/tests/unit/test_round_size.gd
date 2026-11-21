extends GutTest

var _arena: CombatArena
var _rng: RngRegistry


func before_each() -> void:
	_rng = RngRegistry.new(22)
	var bus: EventBus = autofree(EventBus.new())
	_arena = CombatArena.new(CombatTuning.shipped(), bus, _rng.stream(&"combat"))


func test_rocket_and_thrown_rounds_fire_large_and_pistol_fires_small() -> void:
	var table: WeaponTable = WeaponTable.shipped()
	for id: StringName in [&"rocket_launcher", &"molotov", &"mini_nuke", &"pistol"]:
		var gun: GunHand = GunHand.make(table, id, _rng.stream(&"gunplay"))
		var shots: Array[Shot] = gun.pull(_arena.rivet, Vector2.RIGHT * 10.0)
		assert_eq(shots.size(), 1, str(id))
		if shots.size() == 1:
			assert_eq(shots[0].size, Shot.SMALL if id == &"pistol" else Shot.LARGE, str(id))


func test_enemy_round_lookup_defaults_and_bare_shot_resolution() -> void:
	assert_eq(EnemyRounds.size_of(&"cannon"), Shot.LARGE)
	assert_eq(EnemyRounds.size_of(&"pistol"), Shot.SMALL)
	assert_eq(EnemyRounds.size_of(&"unknown"), Shot.SMALL)
	assert_eq(EnemyRounds.splash_m(&"unknown"), 0.0)
	assert_eq(EnemyRounds.splash_damage(&"unknown"), 0.0)
	for id: StringName in [&"pistol", &"rifle", &"cannon"]:
		var shot: Shot = _incoming(id)
		ArenaProjectiles.step_shots(_arena)
		assert_eq(shot.size, Shot.LARGE if id == &"cannon" else Shot.SMALL, str(id))
		_arena.shots.clear()


func test_plasma_sword_bats_a_large_enemy_cannon_round() -> void:
	var shot: Shot = _incoming(&"cannon")
	ArenaProjectiles.step_shots(_arena)
	assert_eq(shot.size, Shot.LARGE)
	assert_eq(PlayerDeflect.bat(_arena, Vector2.RIGHT, 2.0), 1)
	assert_true(shot.from_rivet)
	assert_gt(shot.vel.x, 0.0)
	assert_eq(shot.size, Shot.LARGE)


func _incoming(weapon: StringName) -> Shot:
	var shot: Shot = Shot.new()
	shot.from_rivet = false
	shot.weapon = weapon
	shot.pos = _arena.rivet.pos + Vector2.RIGHT * 1.5
	shot.vel = Vector2.LEFT * 11.0
	_arena.shots.append(shot)
	return shot
