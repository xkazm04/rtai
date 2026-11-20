extends GutTest
## Exercise the same GhostFormView that hosts the rigs in the story and review scene.

var _saved: ViewMode
var _view: GhostFormView


func before_each() -> void:
	_saved = ViewMode._shared
	ViewMode.select("top")
	_build(GhostLook.SPECTRAL)


func _build(look: StringName) -> void:
	GhostLook.override_for_test(look)
	var stage: CollectCallStage = CollectCallPlay.begin().stage
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	_view = GhostFormView.make(stage, null, null)
	add_child_autofree(_view)
	_view.set_process(false)


func after_each() -> void:
	ViewMode._shared = _saved
	GhostLook.reset_for_test()


func _enter(id: StringName) -> void:
	var forms: GhostForms = _view.pilot.ghosts.forms
	forms.selected = id
	assert_eq(forms.press_transform(), SoulPowers.OK)
	for tick: int in forms.table.form(id).enter_ticks:
		forms.tick()
	_view._process(0.0)


func _move() -> void:
	_view.arena.rivet.pos += Vector2.RIGHT * 0.12
	_view.arena.tick += 1
	_view._process(0.0)


func test_tonnage_moves_above_the_ground_without_a_single_walking_stamp() -> void:
	var bodies: GhostFormBodies = _view._bodies
	var press: TonnageRig = bodies.tonnage
	watch_signals(press)
	_enter(&"tonnage")
	_view.pilot.hauler.form.vel = Vector2.RIGHT * 4.2
	for tick: int in 60:
		_move()
	assert_signal_not_emitted(press, "stamped")
	assert_eq(press.speed_mps, 0.0)
	assert_gt(press.drawn.flight.hover.speed_mps, 0.0)
	assert_true(press.drawn.flight.is_visible_in_tree())
	assert_true(press.is_visible_in_tree())
	assert_eq(press.drawn.flight.shadow.position, _view.arena.rivet.pos * SimConst.PX_PER_M)
	for drawn: GhostDrawn in [bodies.ohm.drawn, bodies.dent.drawn, bodies.kerf.drawn]:
		assert_true(drawn.hover)
		assert_false(drawn.flight.is_visible_in_tree())


func test_dents_stationary_gait_does_not_replant_steps_as_the_mount_moves() -> void:
	_enter(&"dent")
	var body: DentBody = _view._bodies.dent
	var turn_dps: float = _view.pilot.ghosts.forms.table.form(&"dent").turn_dps
	var steps: int = 0
	for tick: int in 120:
		var angle: float = deg_to_rad(turn_dps) * SimClock.TICK_DT * maxi(0, tick - 18)
		_view.arena.rivet.facing = Vector2.from_angle(angle)
		_move()
		for child: Node in body.get_children():
			if child is CutRig:
				var rig: CutRig = child as CutRig
				assert_eq(rig.speed_now, 0.0)
				for side: RigLimbs in rig.sides:
					if side.stepping:
						steps += 1
	assert_eq(steps, 0, "the floating body carries the resting feet with it")
	assert_gt(body.drawn.flight.hover.speed_mps, 0.0)


func test_four_arena_drives_keep_spectral_gaits_still_while_the_legacy_gaits_cycle() -> void:
	ViewMode.select("tilt70")
	for look: StringName in [GhostLook.LEGACY, GhostLook.SPECTRAL]:
		for id: StringName in [&"tonnage", &"dent", &"kerf", &"ohm"]:
			_drive_arena(id, look)


func _drive_arena(id: StringName, look: StringName) -> void:
	GhostLook.override_for_test(look)
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	var session: ArenaSession = ArenaSession.open(bus, data)
	session.world.loop().set_input(GhostReviewInput.new(session, id, false))
	var view: GhostFormView = GhostFormView.make(session.stage, null, null)
	add_child(view)
	view.set_process(false)
	var body: Node2D = view._bodies.get(id)
	var drawn: GhostDrawn = body.get(&"drawn")
	var stamps: Array[Vector2] = []
	@warning_ignore("return_value_discarded")
	view._bodies.tonnage.stamped.connect(stamps.append)
	for i: int in GhostReviewInput.START:
		session.step()
		view._process(0.0)
	assert_eq(session.pilot.ghosts.forms.current(), id)
	var start: Vector2 = session.stage.arena.rivet.pos
	var cells: Dictionary[int, bool] = {}
	var planted: bool = false
	var rig: CutRig = view._bodies.dent._rig if id == &"dent" else null
	for i: int in 58:
		session.step()
		view._process(0.0)
		var sprite: Sprite2D = drawn.sprite()
		if sprite != null:
			cells[sprite.frame_coords.x] = true
		if rig != null:
			for side: RigLimbs in rig.sides:
				planted = planted or side.stepping
	assert_gt(start.distance_to(session.stage.arena.rivet.pos), 1.0, str(id))
	var grounded: bool = look == GhostLook.LEGACY
	assert_eq(cells.size() > 1, grounded, str(id))
	if id == &"dent":
		assert_eq(planted, grounded, "Dent's actual IK moved a planted foot")
	assert_eq(not stamps.is_empty(), grounded and id == &"tonnage", "walking stamps")
	view.free()
	session.world.loop().set_input(session.live)
	session.close()


func test_emergence_collapses_to_the_ground_then_restores_the_full_ribbon() -> void:
	ViewMode.select("tilt70")
	var flight: GhostFlight = add_child_autofree(GhostFlight.make(&"kerf"))
	var body: Node2D = Node2D.new()
	flight.mount(body)
	var at: Vector2 = Vector2(320, 96)
	flight.step(at, PI, 1)
	var lift: Vector2 = flight.body_offset()
	var full: PackedVector2Array = flight.tail.points()
	assert_gt(full[0].distance_to(full[-1]), 20.0)
	flight.set_emerge(0.0)
	assert_eq(body.global_position, at)
	assert_eq(flight.shadow.position, at)
	assert_eq(flight.shadow.pool_open, 0.0)
	var folded: PackedVector2Array = flight.tail.points()
	for point: Vector2 in folded:
		assert_eq(point, folded[0])
	for width: float in flight.tail.half_widths():
		assert_eq(width, 0.0)
	flight.set_emerge(0.5)
	assert_almost_eq(body.global_position, at + lift * 0.5, Vector2.ONE * 0.001)
	assert_eq(flight.shadow._height, flight.hover.lift_m * 0.5)
	flight.set_emerge(1.0)
	assert_eq(flight.tail.points(), full)
	assert_eq(body.global_position, at + lift)
	assert_eq(flight.shadow.pool_open, 1.0)
