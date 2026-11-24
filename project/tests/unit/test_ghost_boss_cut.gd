extends GutTest
## A deployed Kerf cut that hurts a boss earns the bond's per_boss_cut; a killing cut is a kill.

var session: GauntletSession
var stage: ArenaStage
var ghost: GhostDeploy
var run: GauntletRun
var bond: GhostBond


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	run = GauntletRun.new()
	run.seed = 4
	session = GauntletSession.open_street(bus, data, run)
	stage = session.stage
	ghost = session.pilot.ghosts.deploy
	bond = session.pilot.ghosts.forms.bond


func after_each() -> void:
	session.close()


func _foe(id: StringName) -> Fighter:
	return stage.arena.squad_ai.spawn_member(stage.arena, stage.arena.rivet.pos, id)


func _cut(target: Fighter) -> void:
	target.pos = stage.arena.rivet.pos + Vector2.RIGHT
	target.facing = Vector2.LEFT
	ghost.form = &"kerf"
	ghost.facing = Vector2.RIGHT
	ghost.spot = target.pos
	ghost.strike.land(stage, ghost)
	bond.record(
		&"kerf",
		ghost.strike.release_kills,
		ghost.strike.release_stuns,
		ghost.strike.release_boss_cuts
	)


func _boss() -> Fighter:
	var boss: Fighter = _foe(&"contractor")
	boss.hp = 40.0
	boss.max_hp = 40.0
	stage.arena.boss = boss
	return boss


func test_table_reads_thirty_and_three() -> void:
	assert_eq(bond.master_at, 30.0)
	assert_eq(session.pilot.ghosts.forms.table.per_boss_cut, 3.0)


func test_boss_cut_that_hurts_awards_one_cut() -> void:
	var boss: Fighter = _boss()
	_cut(boss)
	assert_true(boss.alive())
	assert_eq(ghost.strike.release_boss_cuts, 1)
	assert_eq(ghost.strike.release_kills, 0)
	assert_eq(bond.value(&"kerf"), 3.0)


func test_cut_that_kills_the_boss_is_a_kill_not_two() -> void:
	var boss: Fighter = _boss()
	boss.hp = 0.5
	_cut(boss)
	assert_false(boss.alive())
	assert_eq(ghost.strike.release_boss_cuts, 0)
	assert_eq(ghost.strike.release_kills, 1)
	assert_eq(bond.value(&"kerf"), 4.0)


func test_non_boss_cut_awards_nothing_for_the_cut_and_a_kill_stays_four() -> void:
	var foe: Fighter = _foe(&"patrol_cop")
	foe.hp = 1.0
	foe.max_hp = 1.0
	_cut(foe)
	assert_eq(ghost.strike.release_boss_cuts, 0)
	assert_eq(bond.value(&"kerf"), 4.0)
	var tough: Fighter = _foe(&"patrol_cop")
	tough.hp = 500.0
	tough.max_hp = 500.0
	_cut(tough)
	assert_true(tough.alive())
	assert_eq(ghost.strike.release_boss_cuts, 0)
	assert_eq(bond.value(&"kerf"), 4.0)


func test_cut_with_zero_damage_awards_nothing() -> void:
	ghost.strike.attacks.deploy[&"kerf"].boss_damage_cap = 0.0
	var boss: Fighter = _boss()
	_cut(boss)
	assert_eq(boss.hp, 40.0)
	assert_eq(ghost.strike.release_boss_cuts, 0)
	assert_eq(bond.value(&"kerf"), 0.0)


func test_boss_cuts_stop_at_master_at() -> void:
	var boss: Fighter = _boss()
	for i: int in range(15):
		boss.hp = 40.0
		_cut(boss)
	assert_eq(bond.value(&"kerf"), 30.0)
	assert_true(bond.ready(&"kerf"))
