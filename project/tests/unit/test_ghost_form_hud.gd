extends GutTest
## features/souls GhostFormHud.sync(): the widget's plain values follow the state machine
## (the selected ghost and its cost notch in base, the current form, the cooldown sweep after).


func test_sync_follows_select_enter_and_cooldown() -> void:
	var g: GhostForms = GhostForms.new(
		GhostFormTable.load_default(), SoulPowers.new(PowerTable.load_default())
	)
	var hud: GhostFormHud = autofree(GhostFormHud.new())
	hud.sync(g)
	assert_eq(hud.current, GhostForms.BASE)
	assert_eq(hud.selected, &"tonnage")
	assert_almost_eq(hud.cost_k, g.powers.table.row(&"hauler").madness_cost / 100.0, 0.001)
	assert_eq(g.press_transform(), SoulPowers.OK)
	hud.sync(g)
	assert_eq(hud.current, &"tonnage", "the chip lights as the transformation starts")
	for i: int in 120:
		g.powers.tick()
		g.tick()
	assert_eq(g.press_transform(), SoulPowers.OK)
	for i: int in 60:
		g.powers.tick()
		g.tick()
	hud.sync(g)
	assert_eq(hud.current, GhostForms.BASE)
	assert_gt(hud.cooling[&"tonnage"], 0.0, "Tonnage is cooling")
	assert_gt(hud.madness_k, 0.0)


## n8-hud GhostChipFace: every ghost in the cycle has its drawn face (no chip falls back to the
## glyph), cut at 84 px, no background behind it (the top corners clear, the centre drawn).
func test_every_ghost_has_a_cut_avatar() -> void:
	var table: GhostFormTable = GhostFormTable.load_default()
	assert_true(GhostChipFace.FACES)
	for id: StringName in table.order:
		var tex: Texture2D = GhostChipFace.face(id)
		assert_not_null(tex, "%s has a chip face" % id)
		if tex == null:
			continue
		assert_eq(tex.get_size(), Vector2(84.0, 84.0), "%s cut at 84 px" % id)
		var img: Image = tex.get_image()
		assert_lt(img.get_pixel(1, 1).a, 0.05, "%s: no background behind the figure" % id)
		assert_gt(img.get_pixel(42, 42).a, 0.5, "%s: the face fills the centre" % id)


## A ghost with no cut draws nothing and says so (the strip draws its D5 glyph instead).
func test_unknown_ghost_falls_back_to_the_glyph() -> void:
	var hud: GhostFormHud = autofree(GhostFormHud.new())
	assert_null(GhostChipFace.face(&"no_such_ghost"))
	assert_false(GhostChipFace.draw(hud, &"no_such_ghost", Vector2.ZERO, 26.0))


func test_first_level_marks_the_loaded_ghost_and_uses_its_own_cooldown() -> void:
	var pilot: GhostPilot = GhostPilot.shipped()
	var hud: GhostFormHud = autofree(GhostFormHud.new())
	pilot.forms.selected = &"kerf"
	pilot.forms.apply_locks([])
	var total: int = pilot.deploy.strike.attacks.deploy[&"kerf"].cooldown_ticks
	pilot.deploy.cooldowns[&"kerf"] = roundi(total * 0.5)
	hud.sync(pilot.forms, &"", pilot)
	assert_eq(hud.selected, &"kerf")
	assert_eq(hud.next_chip, &"ohm")
	assert_almost_eq(hud.cooling[&"kerf"], 0.5, 0.0001)
	assert_eq(hud.cooling[&"ohm"], 0.0)
	pilot.transform_unlocked = true
	hud.sync(pilot.forms, &"", pilot)
	assert_eq(hud.cooling[&"kerf"], 0.0)


func test_deploy_hint_follows_the_rebound_key() -> void:
	var pilot: GhostPilot = GhostPilot.shipped()
	var hud: GhostFormHud = autofree(GhostFormHud.new())
	var existed: bool = InputMap.has_action(&"ghost_deploy")
	if not existed:
		InputMap.add_action(&"ghost_deploy")
	var saved: Array[InputEvent] = InputMap.action_get_events(&"ghost_deploy")
	PlayerSettings.new().rebind(&"ghost_deploy", "V")
	hud.sync(pilot.forms, &"", pilot)
	var hint: String = (
		PadGlyphArt.action_hint(&"ghost_deploy", "V") if PadGlyphArt.active() else "V"
	)
	assert_eq(hud.key_hint, hint)
	InputMap.action_erase_events(&"ghost_deploy")
	for event: InputEvent in saved:
		InputMap.action_add_event(&"ghost_deploy", event)
	if not existed:
		InputMap.erase_action(&"ghost_deploy")


func test_chip_uses_spectral_art_if_supplied_and_falls_back_to_the_original() -> void:
	var id: StringName = &"chip_fixture"
	var original: ImageTexture = ImageTexture.new()
	var spectral: ImageTexture = ImageTexture.new()
	original.take_over_path(GhostChipFace.DIR + str(id) + ".png")
	spectral.take_over_path(GhostChipFace.DIR + str(id) + "_spectral.png")
	GhostLook.override_for_test(GhostLook.LEGACY)
	assert_same(GhostChipFace.face(id), original)
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	assert_same(GhostChipFace.face(id), spectral)
	var fallback: ImageTexture = ImageTexture.new()
	fallback.take_over_path(GhostChipFace.DIR + "chip_fallback.png")
	assert_same(GhostChipFace.face(&"chip_fallback"), fallback)
	GhostChipFace._cache.clear()
	GhostLook.reset_for_test()
