extends GutTest

const PITCHES: Array[String] = ["p55", "p70"]
const UNPAINTED: StringName = &"test_unpainted_weapon"
var rig: CutRig


func before_each() -> void:
	rig = add_child_autofree(CutRig.new())


func after_each() -> void:
	RivetWalk.frames = 8
	RivetWalk.run = true
	RivetWalk.armed = true
	RivetWalk.enabled = true


func test_every_arsenal_weapon_walks_and_runs_at_both_pitches() -> void:
	for id: StringName in ArsenalTable.shipped().weapon_grip:
		_check_locomotion(id)
	_check_locomotion(&"")


func _check_locomotion(id: StringName) -> void:
	for art: String in PITCHES:
		var dir: String = RivetStrips.DIR + art + "/"
		rig.speed_now = 2.4 * CharacterRigs.PX_PER_M
		var own: String = String(WeaponArtKey.of(id)) + ".png"
		var walk: String = RivetWalk.ARMED + own
		if RivetFramesGrids.held_only(id, art) or not ResourceLoader.exists(dir + walk):
			walk = RivetWalk.STRIP
		assert_eq(RivetWalk.motion_path(rig, art, id), dir + walk, "%s %s walks" % [art, id])
		rig.speed_now = 3.2 * CharacterRigs.PX_PER_M
		var run: String = RivetWalk.ARMED_RUN + own
		if RivetFramesGrids.held_only(id, art) or not ResourceLoader.exists(dir + run):
			run = RivetWalk.RUN  ## a walk sheet alone sprints on the bare run
		assert_eq(RivetWalk.motion_path(rig, art, id), dir + run, "%s %s runs" % [art, id])


func test_wheel_slot_zero_stows_the_story_weapon_and_selects_bare_grids() -> void:
	var rng: RngRegistry = RngRegistry.new(24)
	var bus: EventBus = autofree(EventBus.new())
	var arena := CombatArena.new(CombatTuning.shipped(), bus, rng.stream(&"combat"))
	var wheel: RivetWheel = RivetWheel.new(RivetWheel.carry_for(arena))
	arena.rivet.weapon = &"pistol"
	wheel.step(PlayerCommand.new(), PlayerActions.shipped(), arena)
	var hold: WeaponHold = WeaponHold.new()
	hold.follow_weapon(arena.rivet.weapon)
	RivetFrames.publish(rig, hold.held, arena.gun)
	assert_eq(wheel.selected(), wheel.order()[0])
	assert_eq(wheel.selected(), RivetWheel.HANDS)
	assert_eq(hold.held, &"")
	_check_locomotion(RivetFrames.weapon_of(rig))


func test_every_named_grid_exists_in_both_art_directories() -> void:
	var table: DataTable = DataTable.open(PlayerMotion.TABLE, PlayerMotion.SCHEMA)
	var row: Dictionary = table.object(table.raw, "walk_grid")
	var families: Dictionary = table.object(row, "by_grip")
	var overrides: Dictionary = table.object(row, "by_weapon")
	var arsenal: ArsenalTable = ArsenalTable.shipped()
	for grip: StringName in arsenal.weapon_grip.values():
		assert_true(families.has(grip), "every arsenal grip selects a family: " + String(grip))
	for weapon: String in overrides:
		assert_true(arsenal.weapon_grip.has(weapon), weapon)
	assert_eq(table.text(row, "borrowed_grid"), String(RivetFramesGrids.BARE))
	for pitch: String in PITCHES:
		var dir: String = RivetStrips.DIR + pitch + "/"
		for file: String in [RivetWalk.STRIP, RivetWalk.STRIP4, RivetWalk.RUN]:
			assert_true(ResourceLoader.exists(dir + file), dir + file)
		for family: String in families.values() + overrides.values():
			if family.begins_with(String(RivetFramesGrids.BARE)):
				continue
			for prefix: String in [RivetWalk.ARMED, RivetWalk.ARMED_RUN]:
				var path: String = dir + prefix + family + ".png"
				assert_true(ResourceLoader.exists(path), path)


func test_borrowed_grid_respects_the_armed_flag_and_shot_latch() -> void:
	rig.speed_now = 3.2 * CharacterRigs.PX_PER_M
	RivetWalk.armed = false
	assert_eq(RivetWalk.motion_path(rig, "p70", UNPAINTED), "")
	assert_true(RivetWalk.motion_path(rig, "p70", &"").ends_with("/" + RivetWalk.RUN))
	RivetWalk.armed = true
	rig.set_meta(RivetFrames.FIRE, true)
	assert_eq(RivetWalk.motion_path(rig, "p70", UNPAINTED), "")
	rig.set_meta(RivetFrames.FIRE, false)
	RivetWalk.run = false
	assert_true(RivetWalk.motion_path(rig, "p70", UNPAINTED).ends_with("/" + RivetWalk.STRIP))
	RivetWalk.frames = 4
	assert_true(RivetWalk.motion_path(rig, "p70", UNPAINTED).ends_with("/" + RivetWalk.STRIP4))
	RivetWalk.enabled = false
	assert_eq(RivetWalk.motion_path(rig, "p70", UNPAINTED), "")


func test_run_starts_above_the_threshold_and_only_in_a_drawn_pitch() -> void:
	rig.speed_now = 2.5 * CharacterRigs.PX_PER_M
	assert_true(RivetWalk.motion_path(rig, "p55", UNPAINTED).ends_with(RivetWalk.STRIP))
	rig.speed_now += 0.01
	assert_true(RivetWalk.motion_path(rig, "p55", UNPAINTED).ends_with(RivetWalk.RUN))
	assert_eq(RivetWalk.motion_path(rig, "", &"gloria"), "")


func test_borrowed_legs_yield_to_special_poses() -> void:
	rig.speed_now = 0.0
	assert_eq(RivetWalk.motion_path(rig, "p70", &"gloria"), "")
	rig.speed_now = 2.4 * CharacterRigs.PX_PER_M
	rig.dead = true
	assert_eq(RivetWalk.motion_path(rig, "p70", &"gloria"), "")
	rig.dead = false
	rig.clips.hit_t = 0.1
	assert_eq(RivetWalk.motion_path(rig, "p70", &"gloria"), "")
	rig.clips.hit_t = 0.0
	rig.clips.strike_t = 0.0
	assert_eq(RivetWalk.motion_path(rig, "p70", &"gloria"), "")
	rig.clips.strike_t = -1.0
	rig.clips.roll()
	assert_eq(RivetWalk.motion_path(rig, "p70", &"gloria"), "")


func test_every_bare_grid_has_a_palm_in_each_painted_cell() -> void:
	for pitch: String in PITCHES:
		for file: String in [RivetWalk.STRIP4, RivetWalk.STRIP, RivetWalk.RUN]:
			var path: String = RivetStrips.DIR + pitch + "/" + file
			var image: Image = (load(path) as Texture2D).get_image()
			if image.is_compressed():
				assert_eq(image.decompress(), OK)
			var cols: int = RivetWalk.cols_of(path)
			var cell: Vector2i = image.get_size() / Vector2i(cols, RivetWalk.ROWS)
			for y: int in RivetWalk.ROWS:
				for x: int in cols:
					var frame: Vector2i = Vector2i(x, y)
					var uv: Vector2 = RivetFramesGrip.palm(path, frame, cols)
					var p: Vector2i = frame * cell + Vector2i(Vector2(cell) * uv)
					assert_gt(image.get_pixelv(p).a, 0.4, "%s grip %s on drawn art" % [path, frame])


func test_held_part_follows_the_painted_claw_and_restores_its_normal_carry() -> void:
	var card: Sprite2D = Sprite2D.new()
	rig.add_child(card)
	rig.head_card = card
	var path: String = RivetStrips.DIR + "p70/" + RivetWalk.STRIP
	card.texture = load(path) as Texture2D
	card.set_meta(RivetFrames.ON, path)
	card.hframes = 8
	card.vframes = 8
	card.frame_coords = Vector2i(4, 2)
	card.offset = Vector2(-79, -189)
	card.scale = Vector2(1.5, 1.8)
	var held: Sprite2D = add_child_autofree(Sprite2D.new())
	var rim: Sprite2D = Sprite2D.new()
	rim.name = "Rim0"
	held.add_child(rim)
	var normal: Callable = func(_r: CutRig) -> void: held.position = Vector2.ONE
	RivetFramesGrip.place(rig, held, normal)
	var grip: Vector2 = RivetFramesGrip.palm(path, card.frame_coords, 8)
	var expected: Vector2 = card.to_global(card.offset + card.texture.get_size() / 8.0 * grip)
	assert_almost_eq(held.global_position, expected, Vector2.ONE * 0.001)
	assert_false(rim.visible)
	assert_true(held.use_parent_material)
	card.vframes = 1
	RivetFramesGrip.place(rig, held, normal)
	assert_eq(held.position, Vector2.ONE)
	assert_true(rim.visible)
	assert_false(held.use_parent_material)


func test_rocket_launcher_uses_the_measured_p70_stance_at_each_contact() -> void:
	_check_p70_stance(
		"rocket_launcher", 84.0, Vector2(23.0, 36.5), [0.91, 1.0, 1.0, 0.94, 0.93, 1.0, 1.0, 1.0]
	)


func test_chainsaw_uses_the_measured_p70_stance_at_each_contact() -> void:
	_check_p70_stance(
		"chainsaw", 64.3, Vector2(18.5, 28.0), [0.89, 0.82, 1.0, 0.89, 0.84, 0.88, 1.0, 1.0]
	)


func _check_p70_stance(id: String, cycle: float, contact: Vector2, factors: Array[float]) -> void:
	var card: Sprite2D = autofree(Sprite2D.new())
	var dir: String = RivetStrips.DIR + "p70/"
	var walk: String = dir + RivetWalk.ARMED + id + ".png"
	card.texture = load(walk) as Texture2D
	card.set_meta(RivetFrames.ON, walk)
	card.hframes = 4
	card.vframes = RivetWalk.ROWS
	assert_almost_eq(RivetWalk.cycle_cell(card, "p70", false), snappedf(cycle, 0.1), 0.01)
	card.frame_coords = Vector2i(0, StrideMatch.PROFILE_ROW)
	assert_eq(RivetStride.profile_cycle(card, 1.0, 0.0), contact.x * 4.0)
	card.frame_coords = Vector2i(2, StrideMatch.PROFILE_ROW)
	assert_eq(RivetStride.profile_cycle(card, 1.0, 0.0), contact.y * 4.0)
	rig.head = Node2D.new()
	rig.add_child(rig.head)
	card.set_meta(RivetFrames.ON, dir + RivetWalk.ARMED_RUN + id + ".png")
	for octant: int in 8:
		rig.face_to = octant * PI / 4.0
		rig.head.rotation = rig.face_to
		assert_almost_eq(RivetWalk.row_k(card, "p70", rig), factors[octant], 0.001)
