extends GutTest
## Dock 9 waves (owner doctrine): 49 enemies across 6 waves, wave 6 the quartermaster alone;
## a wave starts only once the last is down; guards die to one nail and their rounds are weak.

const STAGE: String = "res://data/tables/collect_call_stage.json"
const STORAGE: String = "Dock 9 bonded storage"
const CAGE: String = "Dock 9 vault cage"

var _director: WaveDirector


func before_each() -> void:
	var t: DataTable = DataTable.open(STAGE, "gtai.collect-call-stage/1")
	_director = WaveDirector.new(t, t.array(t.raw, "waves"), t.object(t.raw, "dock"))
	assert_true(t.ok(), str(t.errors()))


func test_forty_nine_enemies_in_six_waves_the_last_is_mertz_alone() -> void:
	var pkg: QuestPackage = QuestFixture.stage_load().package
	assert_eq(_director.waves.size(), 6)
	assert_eq(_director.total(), 49)
	assert_eq(_director.total(), 49, "difficulty.enemyCount")
	assert_eq(pkg.beats[3].id, "b4-dock")
	assert_eq(_director.total(STORAGE), 48, "b4: five waves, 48 contractors")
	var last: WaveDirector.Wave = _director.waves[5]
	assert_eq([last.count, last.boss, last.encounter], [1, "quartermaster-mertz", CAGE])


func test_waves_come_in_order_and_each_waits_for_the_last_to_fall() -> void:
	_director.start(STORAGE)
	var per_wave: Dictionary[String, int] = {}
	var order: Array[int] = []
	var alive: int = 0
	for _tick: int in 60 * 300:
		if _director.began >= 0:
			order.append(_director.began)
		var s: WaveDirector.Spawn = _director.step(alive)
		if s != null:
			per_wave[s.wave] = per_wave.get(s.wave, 0) + 1
			assert_eq(s.boss, "", "no boss in the storage waves")
			alive += 1
		elif (
			_director.spawned == _director.waves[_director.current].count
			if _director.running()
			else false
		):
			alive = 0
		if _director.cleared(STORAGE):
			break
	assert_true(_director.cleared(STORAGE))
	assert_eq(order, [0, 1, 2, 3, 4] as Array[int])
	assert_eq(per_wave, {"w1": 6, "w2": 8, "w3": 10, "w4": 11, "w5": 13})
	assert_false(_director.cleared(CAGE), "wave 6 is its own encounter")


func test_a_wave_never_ends_while_a_guard_stands() -> void:
	_director.start(STORAGE)
	var spawns: int = 0
	for _tick: int in 60 * 60:
		spawns += 1 if _director.step(1) != null else 0
	assert_eq(spawns, 6)
	assert_eq(_director.current, 0, "one guard left: wave 1 holds, no timer pushes it on")
	assert_false(_director.cleared(STORAGE))


func test_guards_die_to_one_nail_and_their_rounds_are_weak() -> void:
	var tuning: CombatTuning = CombatTuning.shipped()
	var bus: EventBus = autofree(EventBus.new())
	var arena: CombatArena = CombatArena.new(tuning, bus, RngRegistry.new(3).stream(&"combat"))
	var guard: Fighter = arena.spawn_guard(Vector2(10.0, 0.0))
	watch_signals(bus)
	arena.rivet.weapon = &"gloria"
	assert_true(arena.rivet_fire(guard.pos))
	for i: int in 30:
		arena.step(i + 1)
	assert_false(guard.alive())
	assert_signal_emitted_with_parameters(bus, "actor_killed", [0, guard.id, &"shot"])
	assert_eq(arena.rifle_drops.size(), 1, "he drops his rifle")
	var rifle: CombatTuning.Weapon = tuning.weapon(&"assault-rifle")
	assert_lt(rifle.damage_vs_rivet * rifle.magazine, arena.rivet.max_hp * 0.25, "weak rounds")
	assert_true(arena.grab_rifle(20.0))
	assert_eq([arena.rivet.weapon, arena.rifle_ammo], [&"assault-rifle", rifle.magazine])
