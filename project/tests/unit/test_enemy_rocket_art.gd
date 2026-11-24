extends GutTest


class RocketPass:
	extends ShotDraw
	var heads: Array[Vector2] = []

	func cased_round(head: Vector2, _dir: Vector2, _went: float, _tick: int) -> void:
		heads.append(head)


func test_trooper_round_draws_the_cut_on_the_round_colour_canvas() -> void:
	var host: Node2D = autofree(Node2D.new())
	var shot: FoeRocketFlight.Round = _trooper_round()
	FightAreasArt._rocket(host, shot, shot.vel.normalized(), 4.0, 100)
	assert_true(host.has_meta(ShotDraw.LAYER))
	assert_eq(EnemyRocketArt.BODY.resource_path.get_file(), "enemy_rocket_body.png")
	var body_size: Vector2 = EnemyRocketArt.BODY.get_size()
	assert_eq(body_size, Vector2(90, 45))
	assert_almost_eq(EnemyRocketArt.nozzle, Vector2(0, 22.68), Vector2(0.01, 0.01))
	assert_almost_eq(EnemyRocketArt.scale_px * body_size.x / Ink.PX_PER_M, 1.4, 0.01)


func test_glow_mask_is_centered_on_the_casing() -> void:
	var pad: Vector2 = EnemyRocketArt.GLOW.get_size() - EnemyRocketArt.BODY.get_size()
	assert_eq(pad, Vector2(12, 12))
	assert_eq(EnemyRocketArt.glow_offset, -pad / 2.0)


func test_standalone_ordnance_view_draws_one_cased_rocket() -> void:
	var host: Node2D = autofree(Node2D.new())
	var overlay: FoeOrdnanceView = FoeOrdnanceView.new()
	host.add_child(overlay)
	var pass_record: RocketPass = _record(overlay)
	var shot: FoeRocketFlight.Round = _trooper_round()
	FightAreasArt._rocket(overlay, shot, shot.vel.normalized(), 4.0, 100)
	assert_eq(pass_record.heads, [shot.pos + ShotLift.up_m()])


func test_parent_fx_view_owns_the_sprite_when_both_views_see_the_round() -> void:
	var view: FxView = autofree(FxView.new())
	view.stage = CollectCallStage.new(null)
	view.stage.tick = 100
	var overlay: FoeOrdnanceView = FoeOrdnanceView.new()
	view.add_child(overlay)
	var tracer_pass: RocketPass = _record(view)
	var overlay_pass: RocketPass = _record(overlay)
	var shot: FoeRocketFlight.Round = _trooper_round()
	FightAreasArt._rocket(overlay, shot, shot.vel.normalized(), 4.0, 100)
	ShotDraw.bare(view, shot, Vector2.RIGHT)
	assert_eq(overlay_pass.heads.size(), 0)
	assert_eq(tracer_pass.heads, [shot.pos + ShotLift.up_m()])


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
		var length_m: float = texture.get_width() * EnemyRocketArt.scale_px / Ink.PX_PER_M
		assert_between(length_m, 0.9, 1.0)


func _record(host: CanvasItem) -> RocketPass:
	var pass_record: RocketPass = RocketPass.new()
	host.set_meta(ShotDraw.LAYER, pass_record)
	return pass_record


func _trooper_round() -> FoeRocketFlight.Round:
	var shot: FoeRocketFlight.Round = FoeRocketFlight.Round.new()
	shot.weapon = &"rocket"
	shot.from_rivet = false
	shot.size = Shot.LARGE
	shot.pos = Vector2.LEFT * 4.0
	shot.vel = Vector2.LEFT * 13.0
	return shot
