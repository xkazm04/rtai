extends GutTest

var session: GauntletSession
var stage: ArenaStage
var ghost: GhostDeploy
var run: GauntletRun = GauntletRun.new()


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	run = GauntletRun.new()
	run.seed = 4
	session = GauntletSession.open_street(bus, data, run)
	stage = session.stage
	ghost = session.pilot.ghosts.deploy
	ghost.strike.attacks.deploy[&"kerf"].boss_damage_cap = 0.1


func after_each() -> void:
	session.close()


func _wave(number: int) -> GauntletLiveWave:
	run.wave = number - 1
	var waves: GauntletWaves = GauntletWaves.attach(session, run, GauntletPilot.new(), 0)
	stage.arena.rivet.pos.x = session.street.current().end_x() + 0.01
	session.step()
	return waves._live[0]


func _cut(target: Fighter) -> float:
	target.pos = stage.arena.rivet.pos + Vector2.RIGHT
	target.facing = Vector2.LEFT
	ghost.form = &"kerf"
	ghost.facing = Vector2.RIGHT
	ghost.spot = target.pos
	var before: float = target.hp
	ghost.strike.land(stage, ghost)
	target.pos += Vector2.UP * 30
	return before - target.hp


func _foe(id: StringName) -> Fighter:
	return stage.arena.squad_ai.spawn_member(stage.arena, stage.arena.rivet.pos, id)


func test_boss_slot_keeps_cap_through_overlap_and_damage_bonuses() -> void:
	var wave: GauntletLiveWave = _wave(5)
	var boss: Fighter = wave.members[0]
	assert_eq(boss.archetype, GauntletComposer.BOSS)
	run.wave += 1
	boss.damage_k = 3.0
	boss.hp = boss.max_hp * 0.5
	assert_almost_eq(_cut(boss), 0.1 * boss.max_hp, 0.00001)
	var escort: Fighter = wave.members[1]
	escort.machine = false
	escort.hp = 7.0
	escort.max_hp = 7.0
	assert_eq(_cut(escort), 7.0)


func test_ordinary_wave_leader_and_nonboss_war_machine_take_the_normal_cut() -> void:
	var wave: GauntletLiveWave = _wave(4)
	var leader: Fighter = wave.members[0]
	leader.hp = 3.0
	leader.max_hp = 3.0
	assert_eq(_cut(leader), 3.0)
	var ordinary: Fighter = _foe(GauntletComposer.BOSS)
	assert_eq(_cut(ordinary), 6.0)


func test_arena_boss_and_boss_body_take_capped_damage() -> void:
	var boss: Fighter = _foe(&"contractor")
	boss.hp = 20.0
	boss.max_hp = 20.0
	stage.arena.boss = boss
	assert_eq(_cut(boss), 2.0)
	stage.arena.boss = null
	boss.body_class = &"boss"
	assert_eq(_cut(boss), 2.0)
	boss.body_class = &""
	boss.kind = Fighter.Kind.BOSS
	assert_eq(_cut(boss), 2.0)


func test_full_share_preserves_old_cut_and_small_damage_stays_small() -> void:
	var boss: Fighter = _wave(10).members[0]
	ghost.strike.attacks.deploy[&"kerf"].boss_damage_cap = 1.0
	assert_eq(_cut(boss), 6.0)
	ghost.strike.attacks.blocks[&"kerf"]["robot_damage"] = 0.5
	ghost.strike.attacks.deploy[&"kerf"].boss_damage_cap = 0.1
	assert_eq(_cut(boss), 0.75)


func test_archetype_boss_flag_applies_even_with_unset_fighter_body() -> void:
	var foe: Fighter = _foe(&"contractor")
	var row: EnemyRoster.Archetype = MeleeLethal.archetype(foe.archetype)
	var original: StringName = row.body
	row.body = &"boss"
	ghost.strike.attacks.deploy[&"kerf"].boss_damage_cap = 0.0
	var damage: float = _cut(foe)
	row.body = original
	assert_eq(damage, 0.0)
	assert_gt(_cut(foe), 0.0)


func test_other_damage_and_a_final_kerf_cut_kill_the_boss_once() -> void:
	var boss: Fighter = _wave(5).members[0]
	assert_almost_eq(_cut(boss), 2.6, 0.00001)
	stage.arena.hit_dir = Vector2.ZERO
	stage.arena.damage(boss, boss.hp - 1.0, stage.arena.rivet.id, &"pistol")
	assert_eq(_cut(boss), 1.0)
	assert_false(boss.alive())
	assert_eq(stage.arena.kill_weapon, &"deploy_kerf")
	assert_eq(stage.arena.kills, 1)
