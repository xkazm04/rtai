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
## glyph), cut at 84 px and masked to a disc (the corners clear, the centre drawn).
func test_every_ghost_has_a_disc_face() -> void:
	var table: GhostFormTable = GhostFormTable.load_default()
	assert_true(GhostChipFace.FACES)
	for id: StringName in table.order:
		var tex: Texture2D = GhostChipFace.face(id)
		assert_not_null(tex, "%s has a chip face" % id)
		if tex == null:
			continue
		assert_eq(tex.get_size(), Vector2(84.0, 84.0), "%s cut at 84 px" % id)
		var img: Image = tex.get_image()
		assert_lt(img.get_pixel(1, 1).a, 0.05, "%s: the corner is outside the disc" % id)
		assert_gt(img.get_pixel(42, 42).a, 0.5, "%s: the face fills the centre" % id)


## A ghost with no cut draws nothing and says so (the card draws its D5 glyph instead).
func test_unknown_ghost_falls_back_to_the_glyph() -> void:
	var hud: GhostFormHud = autofree(GhostFormHud.new())
	assert_null(GhostChipFace.face(&"no_such_ghost"))
	assert_false(GhostChipFace.draw(hud, &"no_such_ghost", Vector2.ZERO, 26.0))
