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
