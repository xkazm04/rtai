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
			_build(look)
			_enter(id)
			var body: Node2D = _view._bodies.get(id)
			var drawn: GhostDrawn = body.get(&"drawn")
			if id == &"tonnage":
				watch_signals(body)
			_view.pilot.hauler.form.vel = Vector2.RIGHT * 4.2
			var columns: Dictionary[int, bool] = {}
			for tick: int in 90:
				_move()
				columns[drawn._col] = true
			if look == GhostLook.SPECTRAL:
				assert_eq(columns.size(), 1, str(id))
				assert_eq(drawn._phase, 0.0, str(id))
				if id == &"tonnage":
					assert_signal_not_emitted(body, "stamped")
			else:
				assert_gt(columns.size(), 1, str(id))
				if id == &"tonnage":
					assert_signal_emitted(body, "stamped")
