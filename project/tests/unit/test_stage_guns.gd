extends GutTest
## n7-ranged: quest 1 fires the table guns (StageGuns): a weapon with a weapons.json row arms the
## arena's GunHand, the contractors' rifle (no row) keeps the quest's own path.


func _arena() -> CombatArena:
	var reg: RngRegistry = RngRegistry.new(7)
	var bus: EventBus = autofree(EventBus.new())
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func _guns() -> StageGuns:
	return StageGuns.make(RngRegistry.new(7).stream(&"quest_guns"))


func test_gloria_fires_as_her_table_row() -> void:
	var arena: CombatArena = _arena()
	arena.rivet.weapon = &"gloria"
	_guns().sync(arena)
	assert_not_null(arena.gun)
	assert_eq(arena.gun.trigger.spec.id, &"gloria")
	assert_true(arena.gun.tap, "a held fire re-fires Gloria, as the evening path did")


func test_the_rifle_keeps_the_quest_path() -> void:
	var arena: CombatArena = _arena()
	var guns: StageGuns = _guns()
	arena.rivet.weapon = &"gloria"
	guns.sync(arena)
	arena.rivet.weapon = &"assault-rifle"
	guns.sync(arena)
	assert_null(arena.gun, "no weapons.json row: combat.json's rifle, magazine into Gloria")


func test_the_same_weapon_keeps_its_gun() -> void:
	var arena: CombatArena = _arena()
	var guns: StageGuns = _guns()
	arena.rivet.weapon = &"gloria"
	guns.sync(arena)
	var first: GunHand = arena.gun
	guns.sync(arena)
	assert_same(arena.gun, first, "the trigger's cooldown survives the tick")


func test_gloria_one_hit_drops_a_quest_human() -> void:
	var arena: CombatArena = _arena()
	arena.rivet.weapon = &"gloria"
	_guns().sync(arena)
	var shots: Array[Shot] = arena.gun.pull(arena.rivet, Vector2(10.0, 0.0))
	assert_eq(shots.size(), 1)
	assert_gte(shots[0].damage, CombatTuning.shipped().human["hp"], "the one-hit doctrine")
