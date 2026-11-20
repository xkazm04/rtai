extends GutTest

var _view: ViewMode


func before_each() -> void:
	_view = ViewMode._shared


func after_each() -> void:
	GhostLook.reset_for_test()
	ViewMode._shared = _view


func _apparition() -> GhostApparition:
	var app: GhostApparition = add_child_autofree(GhostApparition.new())
	app.bind(null, null)
	return app


func _visible_bodies(app: GhostApparition) -> Array[Node2D]:
	var bodies: Array[Node2D] = []
	for node: Node in app.find_children("*", "Node2D", true, false):
		if node is DentBody or node is KerfRig or node is OhmRig or node is TonnageRig:
			var body: Node2D = node as Node2D
			if body.is_visible_in_tree():
				bodies.append(body)
	return bodies


func test_the_envelope_fades_in_holds_and_fades_out() -> void:
	var hold: int = 60
	assert_eq(GhostApparition.envelope(-1, hold), 0.0, "silent")
	assert_almost_eq(GhostApparition.envelope(GhostApparition.FADE_IN / 2, hold), 0.5, 0.06, "in")
	assert_eq(GhostApparition.envelope(GhostApparition.FADE_IN + hold - 1, hold), 1.0, "held")
	var done: int = GhostApparition.FADE_IN + hold + GhostApparition.FADE_OUT
	assert_eq(GhostApparition.envelope(done, hold), 0.0, "gone")


func test_a_voice_shows_one_body_and_ends(
	look: StringName = use_parameters([GhostLook.LEGACY, GhostLook.SPECTRAL])
) -> void:
	GhostLook.override_for_test(look)
	var app: GhostApparition = _apparition()
	var duration: int = GhostApparition.FADE_IN + 30 + GhostApparition.FADE_OUT
	var tick: int = 0
	for id: StringName in [HaulerStage.GHOST, DentStage.GHOST, KerfStage.GHOST, OhmStage.GHOST]:
		app.say(id, 30)
		tick += 1
		app.step(Vector2.ZERO, 0.0, 1, tick)
		assert_eq(_visible_bodies(app), [app._rigs[id]], "%s/%s speaking" % [look, id])
		tick += duration - 1
		app.step(Vector2.ZERO, 0.0, duration - 1, tick)
		assert_false(app.speaking(), "%s/%s voice ended" % [look, id])
		assert_false(app.visible, "%s/%s apparition gone" % [look, id])


func test_an_unknown_ghost_says_nothing() -> void:
	var app: GhostApparition = _apparition()
	app.say(&"nobody")
	assert_false(app.speaking())


func test_the_parts_draw_through_the_ghost_material() -> void:
	var app: GhostApparition = _apparition()
	app.say(KerfStage.GHOST)
	var washed: int = 0
	for n: Node in app.find_children("*", "Sprite2D", true, false):
		if (n as Sprite2D).material is ShaderMaterial:
			var m: ShaderMaterial = (n as Sprite2D).material
			washed += 1 if m.shader == GhostApparition.SHADER else 0
	assert_gt(washed, 4, "Kerf's parts are washed teal")


func test_a_whisper_in_base_shows_the_selected_ghost_and_none_in_a_form() -> void:
	var t: GhostFormTable = GhostFormTable.load_default()
	var forms: GhostForms = GhostForms.new(t, SoulPowers.new(PowerTable.load_default()))
	var bus: EventBus = EventBus.new()
	add_child_autofree(bus)
	var app: GhostApparition = GhostApparition.new()
	add_child_autofree(app)
	app.bind(forms, bus)
	bus.whispers_spiked.emit()
	assert_true(app.speaking(), "a whisper in base: a ghost speaks")
	assert_eq(app.id, forms.selected, "the selected ghost")
	var forms2: GhostForms = GhostForms.new(t, SoulPowers.new(PowerTable.load_default()))
	var app2: GhostApparition = GhostApparition.new()
	add_child_autofree(app2)
	app2.bind(forms2, bus)
	assert_eq(forms2.press_transform(), SoulPowers.OK, "into the selected form")
	bus.whispers_spiked.emit()
	assert_false(app2.speaking(), "in a form the ghost is Rivet: no apparition")


func test_spectral_voice_keeps_its_cut_and_only_the_speaker_has_a_shadow_and_tail() -> void:
	ViewMode.select("tilt70")
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	var app: GhostApparition = _apparition()
	var rig: TonnageRig = app._rigs[HaulerStage.GHOST]
	var flight: GhostFlight = rig.drawn.flight
	var vapour: Material = flight.tail.material
	app.say(HaulerStage.GHOST)
	app.step(Vector2(350.0, 420.0), 0.0, 22, 22)
	assert_true(flight.is_visible_in_tree())
	assert_almost_eq(
		rig.global_position,
		flight.shadow.global_position + flight.body_offset() * GhostApparition.BIG_K,
		Vector2.ONE * 0.001
	)
	assert_eq(flight.scale, Vector2.ONE * GhostApparition.BIG_K)
	var tether_end: Vector2 = app._tether.to_global(app._tether.points[-1])
	assert_almost_eq(tether_end, flight.tail.points()[0], Vector2.ONE * 0.001)
	var spr: Sprite2D = rig.drawn.sprite()
	if spr == null:
		pass_test("own_body: no shared sprite to wash")
		return
	var cut: ShaderMaterial = spr.material
	assert_eq(cut.shader, GhostBridgeFade.SHADER)
	var phase: float = cut.get_shader_parameter(&"voice_phase")
	assert_almost_eq(phase, 0.44, 0.001)
	assert_eq(flight.tail.material, vapour)
	app.say(KerfStage.GHOST)
	app.step(Vector2.ZERO, 0.0, 1, 23)
	assert_false(flight.visible)
	assert_true((app._rigs[KerfStage.GHOST] as KerfRig).drawn.flight.visible)
	app.say(HaulerStage.GHOST)
	app.step(Vector2.ZERO, 0.0, 1, 24)
	assert_eq(rig.drawn.sprite().material, cut)
	assert_eq(flight.tail.material, vapour)
