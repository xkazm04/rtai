extends GutTest

const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")
const NEW_FOES: Array[StringName] = [&"appliance_warden", &"sergeant_mulroney"]


func test_new_foes_are_explicit_and_absent_from_every_legacy_wave() -> void:
	var roster: EnemyRoster = EnemyRoster.shipped()
	var pit: PitWaves = PitWaves.shipped()
	assert_true(roster.ok(), str(roster.errors()))
	for id: StringName in NEW_FOES:
		assert_false(roster.archetypes.has(id), id)
		assert_true(roster.archetype(id).explicit_spawn, id)
		assert_eq(roster.archetype(id).body, &"human", id)
	for curve: StringName in pit.curve_ids():
		for wave: Array in pit.waves(curve):
			for spawn: Dictionary in wave:
				assert_false(NEW_FOES.has(spawn["arch"]), str([curve, spawn]))


func test_stage_wave_counts_equipment_and_dale_approach() -> void:
	var data: DataTable = DataTable.open(
		"res://data/tables/prologue_stage.json", "gtai.prologue_stage/1"
	)
	var waves: Array = data.array(data.raw, "waves")
	var totals: Array[int] = []
	var roster: EnemyRoster = EnemyRoster.shipped()
	for wave: Dictionary in waves:
		var count: int = 0
		for group: Dictionary in data.array(wave, "groups"):
			count += data.integer(group, "count")
			assert_not_null(roster.archetype(StringName(data.text(group, "archetype"))))
		totals.append(count)
	assert_eq(totals[0], 10)
	assert_between(totals[1], 1, 10)
	var approach: Array = waves[0]["approach_lines"]
	assert_eq(approach, ["b1_l04_winnick_dale", "draft_winnick_closer"])
	assert_eq(data.text(data.raw, "pistol_pickup_id"), "pistol")


func test_boot_scene_uses_wheel_input_and_the_prologue_loadout() -> void:
	var game: PrologueGame = ENTRY.instantiate() as PrologueGame
	add_child_autofree(game)
	assert_true(game.stage.pilot.actions.wheel)
	assert_not_null(game.stage.pilot.guard)
	assert_null(game.stage.pilot.ghosts)
	assert_eq(game.stage.arena.rivet.weapon, &"")
	var roster: EnemyRoster = game.stage.arena.squad_ai.pit.roster
	assert_eq(roster.archetype(&"sergeant_mulroney").weapon.id, &"shotgun")
	var pole: EnemyWeapon = roster.archetype(&"appliance_warden").weapon
	assert_eq(pole.id, &"catch_pole")
	assert_eq(pole.reach_m, 2.2)
	assert_gt(pole.knockback_m, 0.0)
	var start: Vector2 = game.stage.arena.rivet.pos
	for tick: int in SimClock.TICK_RATE:
		game.stage.step(tick, TickInput.new(0, TickInput.AXIS_MAX, 0))
	assert_gt(game.stage.arena.rivet.pos.x, start.x)
	PlayerActions.shipped().install()
