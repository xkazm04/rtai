extends GutTest

var _view: ViewMode


func before_each() -> void:
	_view = ViewMode.shared()
	ViewMode.select("tilt70")


func after_each() -> void:
	ViewMode._shared = _view


func _ped(look: int, id: int) -> CutRig:
	var pool: RigPool = RigPool.new()
	add_child_autoqfree(pool)
	@warning_ignore("return_value_discarded")
	pool.prewarm(BodyPlan.Kind.PED, 1)
	var rig: CutRig = pool.acquire(BodyPlan.Kind.PED, RigVariant.crowd(look), Vector2.ZERO, 0.0)
	rig.actor_id = id
	rig.drive(SimClock.TICK_DT)
	return rig


func _check_throw(rig: CutRig, kind: String) -> void:
	var body: Node2D = autofree(Node2D.new())
	var extra: KillTrackRows.Extra = KillTrackRows.of(&"claw_throw")
	var cells: Sprite2D = KillFallCells.attach(rig, body, Vector2.RIGHT, extra)
	assert_not_null(cells, kind)
	if cells != null:
		assert_eq(
			cells.texture.resource_path, StreetWalkerCards.DIR + "p70/%s_claw_throw.png" % kind
		)


func test_city_ped_cards_attach_their_own_throw() -> void:
	var looks: Dictionary[String, Vector2i] = {
		"ped_hood": Vector2i(2, 2),
		"ped_cap": Vector2i(3, 2),
		"ped_hat": Vector2i(0, 2),
		"ped_punk": Vector2i(1, 1),
		"ped_jogger": Vector2i(4, 1),
		"ped_shopper": Vector2i(4, 2),
		"ped_worker": Vector2i(7, 1),
		"ped_elder": Vector2i(7, 2),
	}
	for kind: String in looks:
		_check_throw(_ped(looks[kind].x, looks[kind].y), kind)


func test_a_card_without_a_signature_grid_keeps_its_fall() -> void:
	var rig: CutRig = _ped(2, 1)
	var body: Node2D = autofree(Node2D.new())
	var extra: KillTrackRows.Extra = KillTrackRows.of(&"molotov_torch")
	var cells: Sprite2D = KillFallCells.attach(rig, body, Vector2.RIGHT, extra)
	assert_not_null(cells)
	if cells != null:
		var fall: String = StreetWalkerFall.path_of("p70", "ped/head_hood")
		assert_eq(cells.texture.resource_path, StreetWalkerCards.DIR + fall)
		assert_false(cells.has_meta(KillDeathCells.META))


func test_the_robot_has_a_fall_card_only_after_power_down() -> void:
	var rig: CutRig = CutRig.new()
	add_child_autoqfree(rig)
	rig.setup(ThugPlan.build(), RigVariant.rivet())
	rig.drive(SimClock.TICK_DT)
	assert_false(StreetWalkerCards.hides_parts(rig))
	var body: Node2D = autofree(Node2D.new())
	var extra: KillTrackRows.Extra = KillTrackRows.of(&"claw_throw")
	assert_eq(KillDeathCells.path_of(extra, "p70", "thug"), "")
	assert_null(KillFallCells.attach(rig, body, Vector2.RIGHT, extra))
	rig.clips.die(false)
	rig.drive(SimClock.TICK_DT)
	var fall: String = StreetWalkerFall.path_of("p70", "thug")
	assert_false(fall.is_empty())
	assert_eq(rig.head_card.texture.resource_path, StreetWalkerCards.DIR + fall)
