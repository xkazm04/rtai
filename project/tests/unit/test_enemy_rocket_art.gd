extends GutTest


func test_trooper_round_draws_the_cut_on_the_round_colour_canvas() -> void:
	var host: Node2D = autofree(Node2D.new())
	var shot: FoeRocketFlight.Round = _trooper_round()
	FightAreasArt._rocket(host, shot, shot.vel.normalized(), 4.0, 100)
	assert_true(host.has_meta(ShotDraw.LAYER))
	assert_eq(EnemyRocketArt.BODY.resource_path.get_file(), "enemy_rocket_body.png")
	assert_eq(EnemyRocketArt.BODY.get_size(), Vector2(62, 31))
	assert_almost_eq(EnemyRocketArt.nozzle, Vector2(0, 15.62), Vector2(0.01, 0.01))
	assert_almost_eq(EnemyRocketArt.scale_px * 62 / Ink.PX_PER_M, 0.97, 0.01)


func test_parent_fx_view_owns_the_sprite_when_both_views_see_the_round() -> void:
	var view: FxView = autofree(FxView.new())
	view.stage = CollectCallStage.new(null)
	view.stage.tick = 100
	var overlay: FoeOrdnanceView = FoeOrdnanceView.new()
	view.add_child(overlay)
	var shot: FoeRocketFlight.Round = _trooper_round()
	FightAreasArt._rocket(overlay, shot, shot.vel.normalized(), 4.0, 100)
	assert_false(overlay.has_meta(ShotDraw.LAYER))
	ShotDraw.bare(view, shot, Vector2.RIGHT)
	assert_true(view.has_meta(ShotDraw.LAYER))


func test_only_an_outgoing_trooper_rocket_uses_the_sprite() -> void:
	var shot: FoeRocketFlight.Round = _trooper_round()
	assert_true(ShotDraw.cased_rocket(shot))
	shot.weapon = &"war_cannon"
	assert_false(ShotDraw.cased_rocket(shot))
	shot.weapon = &"rocket"
	shot.from_rivet = true
	assert_false(ShotDraw.cased_rocket(shot))
	shot.weapon = &"rocket_launcher"
	assert_false(ShotDraw.cased_rocket(shot))


func test_exhaust_depends_only_on_tick_even_across_gaps_and_rewinds() -> void:
	for tick: int in [100, 0, 5, 3, 101, 1, 100]:
		var texture: Texture2D = EnemyRocketArt.exhaust(tick)
		assert_eq(texture.resource_path.get_file(), "enemy_rocket_exhaust_%d.png" % (tick % 3))
		assert_gt(texture.get_width(), 0)


func _trooper_round() -> FoeRocketFlight.Round:
	var shot: FoeRocketFlight.Round = FoeRocketFlight.Round.new()
	shot.weapon = &"rocket"
	shot.from_rivet = false
	shot.size = Shot.LARGE
	shot.pos = Vector2.LEFT * 4.0
	shot.vel = Vector2.LEFT * 13.0
	return shot
