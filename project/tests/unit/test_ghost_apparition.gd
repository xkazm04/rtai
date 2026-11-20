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
	var resting_cell: Material = rig._spectral._cell.material
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
	var cell: Sprite2D = rig._spectral._cell
	assert_almost_eq(_phase(cell), 0.44, 0.001)
	assert_eq(flight.tail.material, vapour)
	app.say(KerfStage.GHOST)
	assert_eq(cell.material, resting_cell)
	assert_lt(_phase(cell), 0.0)
	app.step(Vector2.ZERO, 0.0, 1, 23)
	assert_false(flight.visible)
	assert_true((app._rigs[KerfStage.GHOST] as KerfRig).drawn.flight.visible)
	app.say(HaulerStage.GHOST)
	app.step(Vector2.ZERO, 0.0, 1, 24)
	assert_almost_eq(_phase(cell), 0.48, 0.001)
	assert_eq(flight.tail.material, vapour)


func _phase(part: CanvasItem) -> float:
	while part.use_parent_material and part.get_parent() is CanvasItem:
		part = part.get_parent() as CanvasItem
	var mat: ShaderMaterial = part.material as ShaderMaterial
	if mat == null:
		return -1.0
	var value: Variant = mat.get_shader_parameter(&"voice_phase")
	return value if value is float else -1.0


func _body_parts(rig: Node2D, flat: bool) -> Array[CanvasItem]:
	var root: CanvasItem
	if rig is TonnageRig:
		var tonnage: TonnageSpectral = (rig as TonnageRig)._spectral
		root = tonnage._parts if flat else tonnage._cell
	elif rig is DentBody:
		var dent: DentBody = rig as DentBody
		root = dent._top if flat else dent._spectral
	else:
		var ohm: OhmRig = rig as OhmRig
		root = ohm._body if flat else ohm.drawn.sprite()
	var parts: Array[CanvasItem] = []
	var nodes: Array[Node] = root.find_children("*", "CanvasItem", true, false)
	nodes.append(root)
	for node: Node in nodes:
		var geometry: bool = node is Line2D or node is Polygon2D or node is MeshInstance2D
		if geometry or node is Sprite2D or node.has_method(&"_draw"):
			var part: CanvasItem = node as CanvasItem
			if part.is_visible_in_tree():
				parts.append(part)
	return parts


func test_every_visible_spectral_body_part_loses_the_wash_at_voice_end(
	view: String = use_parameters(["top", "tilt70"])
) -> void:
	ViewMode.select(view)
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	var app: GhostApparition = _apparition()
	for key: StringName in [HaulerStage.GHOST, OhmStage.GHOST, DentStage.GHOST]:
		app.say(key)
		app.step(Vector2.ZERO, 0.0, 22, 22)
		var parts: Array[CanvasItem] = _body_parts(app._rigs[key], ViewMode.shared().is_flat())
		assert_gt(parts.size(), 0, "%s/%s paints a body" % [key, view])
		for part: CanvasItem in parts:
			assert_almost_eq(_phase(part), 0.44, 0.001, "%s %s speaking" % [key, part.get_path()])
		app.step(Vector2.ZERO, 0.0, 300, 322)
		for part: CanvasItem in parts:
			assert_lt(_phase(part), 0.0, "%s %s silent" % [key, part.get_path()])


func test_a_cut_part_keeps_its_material_and_belt_during_and_after_speech() -> void:
	var part: Sprite2D = add_child_autofree(Sprite2D.new())
	var cut: ShaderMaterial = GhostBridgeFade._material(false)
	cut.set_shader_parameter(&"fade_from", 0.6)
	part.material = cut
	var voice: GhostBridgeFade.Voice = GhostBridgeFade.Voice.new()
	voice.paint(part, GhostApparition.ghost_material(false, 0.2), 0.44)
	assert_eq(part.material, cut)
	assert_almost_eq(_phase(part), 0.44, 0.001)
	voice.clear()
	assert_eq(part.material, cut)
	var belt: float = cut.get_shader_parameter(&"fade_from")
	assert_almost_eq(belt, 0.6, 0.001)
	assert_lt(_phase(part), 0.0)
