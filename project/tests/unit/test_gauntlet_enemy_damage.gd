extends GutTest

var arena: GauntletCombat


func before_each() -> void:
	var events: EventBus = autofree(EventBus.new())
	arena = GauntletCombat.new(CombatTuning.shipped(), events, RngRegistry.new(7).stream(&"combat"))


func _hp_lost(victim: Fighter, attacker: Fighter, multiplier: float) -> float:
	var rules: DataTable = DataTable.new()
	rules.raw["enemy_damage_k"] = multiplier
	arena.enemy_damage_k = GauntletStreet.enemy_damage_multiplier(rules)
	var before: float = victim.hp
	arena.damage(victim, 4.0, attacker.id, &"rocket", &"blown")
	var lost: float = before - victim.hp
	victim.hp = before
	return lost


func test_only_foe_damage_to_rivet_scales() -> void:
	var rivet: Fighter = arena.rivet
	var foe: Fighter = Fighter.make(Fighter.Kind.GUARD, 1, Vector2.RIGHT, 100.0)
	var incoming: float = _hp_lost(rivet, foe, 1.0)
	var own_blast: float = _hp_lost(rivet, rivet, 1.0)
	var outgoing: float = _hp_lost(foe, rivet, 1.0)
	assert_eq(incoming, 4.0)
	assert_eq(own_blast, 4.0)
	assert_eq(outgoing, 4.0)
	assert_eq(_hp_lost(rivet, foe, 2.0), 2.0 * incoming)
	assert_eq(_hp_lost(rivet, rivet, 2.0), own_blast)
	assert_eq(_hp_lost(foe, rivet, 2.0), outgoing)


func test_missing_enemy_damage_defaults_to_one() -> void:
	var rules: DataTable = DataTable.new()
	assert_eq(arena.enemy_damage_k, 1.0)
	assert_eq(GauntletStreet.enemy_damage_multiplier(rules), 1.0)
	assert_true(rules.ok())


func test_freeze_counts_only_continuous_combat_without_hp_loss() -> void:
	arena.run = GauntletRun.new()
	arena.tick = 5000
	assert_false(arena.report_bot_freeze())
	arena.wave_live = true
	var foe: Fighter = Fighter.make(Fighter.Kind.GUARD, 1, Vector2.RIGHT, 100.0)
	arena.tick += 3500
	arena.damage(foe, 1.0, arena.rivet.id, &"baton")
	arena.tick += 3500
	assert_false(arena.report_bot_freeze(), "outgoing damage restarted the clock")
	arena.damage(arena.rivet, 1.0, foe.id, &"baton")
	arena.tick += 3599
	assert_false(arena.report_bot_freeze(), "incoming damage restarted the clock")
	arena.wave_live = true
	foe.exposed = false
	arena.damage(foe, 1.0, arena.rivet.id, &"baton")
	arena.tick += 1
	assert_true(arena.report_bot_freeze(), "stacking and blocked hits cannot hide a freeze")
	arena.wave_live = false
	assert_false(arena.report_bot_freeze())
	arena.tick += 5000
	arena.wave_live = true
	assert_false(arena.report_bot_freeze(), "a new block starts a fresh clock")
