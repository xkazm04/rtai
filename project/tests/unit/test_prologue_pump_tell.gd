extends GutTest

const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")


class MarkerPrint:
	extends PrologueCommandView
	var boss: Fighter = Fighter.new()
	var glyph: String

	func _process(_dt: float) -> void:
		pass

	func _draw() -> void:
		glyph = ""
		_marker(boss)

	func _order_marker() -> void:
		glyph = "order"
		super._order_marker()

	func _pump_marker() -> void:
		glyph = "pump"
		super._pump_marker()

	func _name_plate(_edge: Vector2) -> void:
		pass


func test_drawn_pump_and_order_span_the_play_target_and_keep_the_close_up_size() -> void:
	var game: PrologueGame = ENTRY.instantiate()
	add_child_autofree(game)
	game.world.set_process(false)
	var mark: MarkerPrint = MarkerPrint.new()
	mark._battle = game.encounter.battle
	mark._stage = game.stage
	mark.add_child(mark._dress)
	add_child_autofree(mark)
	mark._dress.pump = 0.0
	for ppm: int in [32, 64]:
		mark.scale = Vector2.ONE * ppm / SimConst.PX_PER_M
		mark._battle.due_tick = -1
		var width: float = await _ink_width(mark)
		assert_eq(mark.glyph, "pump")
		if ppm == 32:
			# RenderingServer includes the antialias fringe around the filled disc.
			assert_between(width, 1.6 * 32, 1.75 * 32)
		else:
			assert_between(width, 68.0 - 0.1, 68.0 * 1.2)
		mark._battle.orders.assign([{"tick": -30}])
		mark._battle.due_tick = 0
		assert_almost_eq(await _ink_width(mark), width, 0.1)
		assert_eq(mark.glyph, "order")
	mark._battle.due_tick = -1
	mark._dress.pump = -1.0
	assert_eq(await _ink_width(mark), 0.0)


func _ink_width(mark: MarkerPrint) -> float:
	mark.queue_redraw()
	await get_tree().process_frame
	await get_tree().process_frame
	var ink: Rect2 = RenderingServer.debug_canvas_item_get_rect(mark.get_canvas_item())
	return (mark.get_global_transform_with_canvas() * ink).size.x


func test_forearm_and_muzzle_lift_then_return_to_the_forward_grip() -> void:
	var pose: PrologueCommanderDress.RackPose = PrologueCommanderDress.RackPose.new()
	for face: Vector2 in [Vector2.RIGHT, Vector2.LEFT]:
		pose.place(face, 0.0)
		var ready: Vector2 = pose.grip
		var forearm: Vector2 = pose.grip - pose.elbow
		pose.place(face, 0.5)
		assert_gte(absf(forearm.angle_to(pose.grip - pose.elbow)), 0.4)
		assert_almost_eq(absf(face.angle_to(pose.axis)), deg_to_rad(28.0), 0.001)
		assert_lt(pose.axis.y, 0.0)
		assert_almost_eq(pose.stock.distance_to(pose.grip), 10.0, 0.001)
		pose.place(face, 1.0)
		assert_almost_eq(pose.grip, ready, Vector2.ONE * 0.001)
		assert_almost_eq(pose.stock.distance_to(pose.grip), 25.0, 0.001)


func test_vector_dress_tracks_the_live_bar_and_receives_the_shotgun_progress() -> void:
	LaunchArgs.parse(["--bot", "--seed=7"])
	var game: PrologueGame = ENTRY.instantiate()
	add_child_autofree(game)
	game.world.set_process(false)
	game._open_view(game.stage.plan as PrologueYard)
	var command: PrologueCommandView = _command_of(game)
	assert_not_null(command)
	if command == null:
		return
	command._process(0.0)
	assert_false(command._bar.visible)
	assert_false(command._dress.visible)
	var cycle: PrologueShotgun = game.encounter.battle.fire.shotgun
	while cycle.shot_ticks.is_empty() and game.stage.tick < 12000:
		game.world.loop().step()
	assert_eq(cycle.shot_ticks, [8379])  # n31 merge: yard solids + swept melee (was 6205)
	for elapsed: int in 25:
		if elapsed > 0:
			game.world.loop().step()
		command._process(0.0)
		assert_true(command._bar.visible)
		assert_true(command._dress.visible)
		assert_eq(command._dress.pump, cycle.pump_progress(game.stage.tick))
		assert_eq(command._heard_shot, 8379)
		assert_eq(command._heard_pump, 8379 if elapsed == 24 else -1)
	var boss: Fighter = game.encounter.battle.formation.boss
	assert_same(command._meter.body, boss)
	assert_same(command._bar.fight, command._meter)
	assert_eq(command._dress.position, boss.pos * SimConst.PX_PER_M)
	boss.hp = 0.0
	command._process(0.0)
	assert_false(command._bar.visible)
	assert_false(command._dress.visible)


func test_mulroney_card_hides_the_dress_and_takes_the_pump_but_the_marker_stays() -> void:
	LaunchArgs.parse(["--bot", "--seed=7"])
	var game: PrologueGame = ENTRY.instantiate()
	add_child_autofree(game)
	game.world.set_process(false)
	game._open_view(game.stage.plan as PrologueYard)
	var command: PrologueCommandView = _command_of(game)
	assert_not_null(command)
	if command == null:
		return
	var mode: ViewMode = ViewMode.shared()
	var was: String = mode.art
	mode.cards = true
	mode.art = "p55"
	var cycle: PrologueShotgun = game.encounter.battle.fire.shotgun
	while cycle.shot_ticks.is_empty() and game.stage.tick < 12000:
		game.world.loop().step()
	var boss: Fighter = game.encounter.battle.formation.boss
	command._process(0.0)
	assert_true(command._bar.visible)
	assert_false(command._dress.visible, "the card replaces the vector figure")
	var progress: float = cycle.pump_progress(game.stage.tick)
	assert_eq(command._dress.pump, progress)
	var got: int = boss.get_meta(FoeCastView.PUMP)
	assert_eq(got, 1 if progress == 0.0 else (2 if progress < 0.5 else 3))
	var mark: MarkerPrint = MarkerPrint.new()
	mark._battle = game.encounter.battle
	mark._stage = game.stage
	mark.add_child(mark._dress)
	mark._dress.pump = progress
	mark._battle.due_tick = -1
	add_child_autofree(mark)
	mark.boss = boss
	mark.queue_redraw()
	await get_tree().process_frame
	assert_eq(mark.glyph, "pump", "the pump marker draws with the dress hidden")
	mode.cards = false
	mode.art = was


func _command_of(game: PrologueGame) -> PrologueCommandView:
	for child: Node in game.get_children():
		if child is PrologueView:
			var view: PrologueView = child as PrologueView
			for actor: Node in view.print_stage.actor_layer().get_children():
				if actor is PrologueCommandView:
					return actor as PrologueCommandView
	return null


func after_each() -> void:
	LaunchArgs.parse()
	PlayerActions.shipped().install()
