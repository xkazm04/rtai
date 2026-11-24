extends GutTest

var _mode: ViewMode
var _host: ArenaRigs
var _arena: CombatArena
var _view: FoeCastView
var _trooper: Fighter
var _sheets: CastCards.Sheets


func before_each() -> void:
	_mode = ViewMode.shared()
	ViewMode.select("combo")
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	var ctx: WorldContext = World.build_context(bus, data, 3)
	_host = autofree(ArenaRigs.new())
	add_child_autofree(_host.rigs)
	_host.rigs.setup(ctx)
	_arena = CombatArena.new(CombatTuning.shipped(), bus, ctx.rng.stream(&"combat"))
	_arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	_arena.squad_ai = ArenaSquad.new(_arena.guard_map)
	_trooper = _arena.squad_ai.spawn_member(_arena, Vector2.ZERO, &"rocket_trooper")
	@warning_ignore("return_value_discarded")
	_arena.squad_ai.mind_for(_trooper)
	_view = FoeCastView.attach(_host, _arena)
	_sheets = CastCards.current(_trooper.archetype)


func after_each() -> void:
	ViewMode._shared = _mode


func _step() -> void:
	_host._put(0, _trooper, BodyPlan.Kind.COP)
	_host.rigs.feed.looks[0] = RigVariant.SWAT
	_view.feed(_trooper, 0)
	_host.react.apply(_host.rigs)
	_host.rigs.step_ticks(1)
	_view._process(0.0)


func _card() -> Sprite2D:
	var rig: CutRig = _host.rigs.rig_for(_trooper.id)
	return rig.head_card if rig != null else _view._far[_trooper.id]


func test_near_and_far_show_same_facing_attack_and_standing_row() -> void:
	_trooper.facing = Vector2.LEFT
	for distance: float in [0.0, 30.0, 0.0]:
		_host.rigs.focus = Vector2.RIGHT * distance * SimConst.PX_PER_M
		for i: int in CharacterRigs.SELECT_EVERY:
			_step()
		var card: Sprite2D = _card()
		assert_eq(_host.rigs.rig_for(_trooper.id) != null, distance == 0.0)
		assert_eq(card.texture.resource_path, _sheets.walk)
		assert_eq(card.frame_coords, Vector2i(2, StreetWalkerCards.STAND_FRAME))
		assert_true(card.flip_h)
		_trooper.tell_left = _arena.guard_tell.lock_ticks + 1
		_step()
		assert_eq(card.texture.resource_path, _sheets.attack)
		assert_eq(card.frame_coords.y, 0)
		_trooper.tell_left = 1
		_step()
		assert_eq(card.texture.resource_path, _sheets.attack)
		assert_eq(card.frame_coords.y, 1)
		_trooper.tell_left = 0
		_arena.tick += 20
		_arena.squad_ai.minds[_trooper.id].agent.shot_tick = _arena.tick
		_step()
		assert_eq(card.frame_coords.y, 2)
		_arena.tick += 1
		_step()
		assert_eq(card.frame_coords.y, 3)
		_arena.tick += CastCardPose.RECOVERY_TICKS
		_step()
		assert_eq(card.texture.resource_path, _sheets.walk)
		assert_false(FoeCastView.draws_launcher(_trooper))


func test_hit_and_corpse_keep_the_loadout_through_demotion() -> void:
	_step()
	_trooper.hp = 10.0
	_arena.hit_dir = Vector2.RIGHT
	_arena.damage(_trooper, 1.0, 0, &"pistol")
	_arena.struck.emit(_trooper, Vector2.RIGHT, false, &"pistol")
	_step()
	assert_eq(_card().texture.resource_path, _sheets.hit)
	assert_true(_card().flip_h)
	_arena.damage(_trooper, 20.0, 0, &"pistol")
	_arena.struck.emit(_trooper, Vector2.RIGHT, true, &"pistol")
	for i: int in 90:
		_arena.tick += 1
		_step()
	var card: Sprite2D = _card()
	assert_eq(card.texture.resource_path, _sheets.fall)
	assert_eq(card.frame_coords, Vector2i(2, 2))
	assert_gt(card.self_modulate.a, 0.9, "own last row stays visible")
	_host.rigs.focus = Vector2.RIGHT * 30.0 * SimConst.PX_PER_M
	_host.rigs.corpse_hold_ticks = 0
	for i: int in CharacterRigs.SELECT_EVERY:
		_step()
	assert_null(_host.rigs.rig_for(_trooper.id))
	assert_eq(_card().texture.resource_path, _sheets.fall)
	assert_eq(_card().frame_coords, Vector2i(2, 2))


func test_far_stride_and_wound_follow_distance_and_damage_ticks() -> void:
	_host.rigs.focus = Vector2.RIGHT * 30.0 * SimConst.PX_PER_M
	_step()
	var card: Sprite2D = _card()
	assert_eq(card.frame_coords.y, StreetWalkerCards.STAND_FRAME)
	var start: Vector2 = _trooper.pos
	var rows: int = StreetCopWalk.rows_of(_sheets.walk)
	var step: float = StreetQuestCards.STRIDE_M * 0.25
	if rows == 8:
		step = CastLancerAnchors.WALK_STEP_M * 1.02
	for i: int in range(1, 5):
		_trooper.pos = start + Vector2.RIGHT * (i * step + 0.01)
		_step()
		# An anchored eight starts on its touchdown drawing at the first step.
		assert_eq(card.frame_coords.y, (i - 1) % rows if rows == 8 else i % rows)
	_trooper.hp = 10.0
	_arena.hit_dir = Vector2.RIGHT
	_arena.damage(_trooper, 1.0, 0, &"pistol")
	_step()
	assert_eq(card.texture.resource_path, _sheets.hit)
	assert_true(card.flip_h)
	_arena.tick += SimClock.TICK_RATE
	_step()
	assert_eq(card.texture.resource_path, _sheets.walk)


func test_pose_ownership_and_unsupported_pitch_use_the_placeholder() -> void:
	_step()
	var rig: CutRig = _host.rigs.rig_for(_trooper.id)
	var pose: CastCardPose = CastCardPose.of(rig)
	assert_not_null(pose)
	rig.head_card.remove_meta(CastCardPose.META)
	assert_true(pose.bind(rig))
	assert_false(pose.bind(rig))
	rig.actor_id += 1
	assert_null(CastCardPose.of(rig))

	rig.actor_id = _trooper.id
	ViewMode.select("top")
	assert_true(FoeCastView.draws_launcher(_trooper))
	_step()
	assert_null(CastCardPose.of(rig))


func test_placeholder_kneel_follows_pool_selection_and_card_switch() -> void:
	_trooper.tell_left = 5
	ViewMode.select("top")
	_step()
	var rig: CutRig = _host.rigs.rig_for(_trooper.id)
	assert_true(rig.has_meta(&"rocket_kneel"))
	_view.feed(_trooper, 0)
	ViewMode.select("combo")
	_step()
	assert_false(rig.has_meta(&"rocket_kneel"))
	assert_not_null(CastCardPose.of(rig))
