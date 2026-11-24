extends GutTest


func test_bolt_topples_forward_and_claw_lifts_then_drops_toward_rivet() -> void:
	var rows: SignatureKillTable = SignatureKillTable.load_table()
	var kills: SignatureKills = SignatureKills.new(rows, RngRegistry.new(82).stream(&"brutality"))
	for source: StringName in [&"electro_gun", &"claw_shock"]:
		var row: SignatureKill = rows.shutdown(&"shield_robot", source)
		var wreck: RobotShutdownFx = autofree(ElectricWreckFx.for_row(row))
		assert_true(wreck is ElectricWreckFx)
		kills.tick = 100
		@warning_ignore("return_value_discarded")
		wreck.mount_body(Node2D.new(), row, kills, 32.0, Vector2.RIGHT)
		kills.tick += 10
		wreck._process(0.0)
		if source == &"electro_gun":
			assert_eq(wreck.pivot.position.y, 0.0)
		else:
			assert_lt(wreck.pivot.position.y, -10.0)
		kills.tick += 50
		wreck._process(0.0)
		assert_eq(wreck.pivot.position.y, 0.0)
		assert_true(
			(
				wreck.pivot.position.x > 0.0
				if source == &"electro_gun"
				else wreck.pivot.position.x < 0.0
			)
		)
		assert_true(wreck.exposed_steel)
		assert_eq(row.spray, 0)
		assert_eq(row.blot_m, 0.0)
	var baton: RobotShutdownFx = autofree(ElectricWreckFx.for_row(rows.shutdown(&"shield_robot")))
	# The bolt and claw use the new animation, while the baton keeps its own folded chassis.
	baton.add_child(baton.pivot)
	baton.pivot.add_child(baton.chassis)
	assert_false(baton is ElectricWreckFx)


func test_shield_wreck_copies_the_drawn_frame_at_its_live_scale() -> void:
	var rig: CutRig = autofree(CutRig.new())
	var live: Sprite2D = autofree(Sprite2D.new())
	live.name = "ShieldCard"
	live.texture = FoeShieldView.TORSO
	live.hframes = 2
	live.frame = 1
	live.flip_h = true
	live.scale = Vector2.ONE * 0.4
	rig.set_meta(FoeShieldCardView.CARD, live)
	var card: Sprite2D = autofree(ElectricChassis.card_of(rig, &"shield_robot"))
	assert_same(card.texture, live.texture)
	assert_eq(card.frame, 1)
	assert_eq(card.scale, live.scale)
	assert_true(card.flip_h)
	assert_null(ElectricChassis.card_of(rig, &"robot_thug"))
