extends GutTest

var _app: GhostApparition = null
var _view: ViewMode


func before_each() -> void:
	_view = ViewMode._shared
	_app = GhostApparition.new()
	add_child_autofree(_app)
	_app.bind(null, null)


func after_each() -> void:
	GhostLook.reset_for_test()
	ViewMode._shared = _view


func test_the_envelope_fades_in_holds_and_fades_out() -> void:
	var hold: int = 60
	assert_eq(GhostApparition.envelope(-1, hold), 0.0, "silent")
	assert_almost_eq(GhostApparition.envelope(GhostApparition.FADE_IN / 2, hold), 0.5, 0.06, "in")
	assert_eq(GhostApparition.envelope(GhostApparition.FADE_IN + hold - 1, hold), 1.0, "held")
	var done: int = GhostApparition.FADE_IN + hold + GhostApparition.FADE_OUT
	assert_eq(GhostApparition.envelope(done, hold), 0.0, "gone")


func test_a_voice_shows_one_body_and_ends() -> void:
	_app.say(OhmStage.GHOST, 30)
	_app.step(Vector2.ZERO, 0.0, 1, 1)
	assert_true(_app.visible, "speaking")
	var shown: int = 0
	for child: Node in _app.get_children():
		if (
			(child is OhmRig or child is KerfRig or child is TonnageRig)
			and (child as Node2D).visible
		):
			shown += 1
	assert_eq(shown, 1, "only the speaking ghost's body")
	for i: int in GhostApparition.FADE_IN + 30 + GhostApparition.FADE_OUT:
		_app.step(Vector2.ZERO, 0.0, 1, 2 + i)
	assert_false(_app.speaking(), "the voice ends")
	assert_false(_app.visible, "and the apparition is gone")


func test_an_unknown_ghost_says_nothing() -> void:
	_app.say(&"nobody")
	assert_false(_app.speaking())


func test_the_parts_draw_through_the_ghost_material() -> void:
	_app.say(KerfStage.GHOST)
	var washed: int = 0
	for n: Node in _app.find_children("*", "Sprite2D", true, false):
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
	var app: GhostApparition = add_child_autofree(GhostApparition.new())
	app.bind(null, null)
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
