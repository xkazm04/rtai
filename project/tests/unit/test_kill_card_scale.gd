extends GutTest
## n29 (cast NEED): a killed card foe keeps the size his living card draws (KillFallCells
## victim_scale); a street walker keeps his crowd build. The live scale is measured from
## StreetWalkerCards.place itself, so a merge that changes the card's scale source and leaves the
## seam stale fails here.

const SERGEANT: StringName = &"sergeant_mulroney"
## StreetCrowdCards.body_scale(7) from the n29 code (1 + 0.16 * vary(7, 3)), pinned.
const WALKER_7: float = 1.066937056534676

var _mode: ViewMode


func before_each() -> void:
	_mode = ViewMode.shared()
	ViewMode.select("combo")


func after_each() -> void:
	ViewMode._shared = _mode


## A near card foe of `archetype` on a pooled rig, posed one tick (FoeCastView's near path).
func _card_foe(archetype: StringName) -> CutRig:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	var ctx: WorldContext = World.build_context(bus, data, 3)
	var host: ArenaRigs = autofree(ArenaRigs.new())
	add_child_autofree(host.rigs)
	host.rigs.setup(ctx)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, ctx.rng.stream(&"combat"))
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	var h: Fighter = arena.squad_ai.spawn_member(arena, Vector2.ZERO, archetype)
	@warning_ignore("return_value_discarded")
	arena.squad_ai.mind_for(h)
	var view: FoeCastView = FoeCastView.attach(host, arena)
	host._put(0, h, BodyPlan.Kind.COP)
	host.rigs.feed.looks[0] = RigVariant.SWAT
	view.feed(h, 0)
	host.react.apply(host.rigs)
	host.rigs.step_ticks(1)
	view._process(0.0)
	return host.rigs.rig_for(h.id)


func _ped(look: int, id: int) -> CutRig:
	var pool: RigPool = RigPool.new()
	add_child_autoqfree(pool)
	@warning_ignore("return_value_discarded")
	pool.prewarm(BodyPlan.Kind.PED, 1)
	var rig: CutRig = pool.acquire(BodyPlan.Kind.PED, RigVariant.crowd(look), Vector2.ZERO, 0.0)
	rig.actor_id = id
	rig.drive(SimClock.TICK_DT)
	return rig


## The build the living card draws: place's scale with the card pose over its scale without it
## (the pose-less branch is the crowd build), times that crowd build.
func _live_scale(rig: CutRig) -> float:
	var card: Sprite2D = rig.head_card
	StreetWalkerCards.place(rig, card)
	var with_pose: float = card.global_scale.x
	var pose: Variant = card.get_meta(CastCardPose.META)
	card.remove_meta(CastCardPose.META)
	StreetWalkerCards.place(rig, card)
	var bare: float = card.global_scale.x
	card.set_meta(CastCardPose.META, pose)
	StreetWalkerCards.place(rig, card)
	return StreetCrowdCards.body_scale(rig.actor_id) * with_pose / bare


func _base_h() -> float:
	return StreetWalkerCards.HEIGHT_BY_ART.get(ViewMode.shared().art, StreetWalkerCards.HEIGHT_M)


func test_a_card_victim_falls_at_his_live_card_scale() -> void:
	for archetype: StringName in [SERGEANT, &"appliance_warden", &"contractor"]:
		var rig: CutRig = _card_foe(archetype)
		assert_not_null(CastCardPose.of(rig), str(archetype))
		var live: float = _live_scale(rig)
		assert_almost_eq(KillFallCells.victim_scale(rig), live, 1e-5, str(archetype))
		assert_almost_eq(KillFallCells.height_px(rig, 64.0), _base_h() * 64.0 * live, 1e-3)
		var body: Node2D = autofree(Node2D.new())
		var extra: KillTrackRows.Extra = KillTrackRows.of(&"molotov_torch")
		var cells: Sprite2D = KillFallCells.attach(rig, body, Vector2.RIGHT, extra)
		assert_not_null(cells, str(archetype))
		if cells != null:
			var want: float = _base_h() * CharacterRigs.PX_PER_M * live / StreetWalkerFall.STILL_PX
			assert_almost_eq(cells.scale.x, want, 1e-5, str(archetype))


func test_a_sized_card_is_not_drawn_at_the_crowd_build() -> void:
	var rig: CutRig = _card_foe(SERGEANT)
	var sheets: CastCards.Sheets = CastCardPose.of(rig).sheets
	assert_ne(sheets.body_scale, 1.0, "Mulroney's row carries his own body_scale")
	var crowd: float = StreetCrowdCards.body_scale(rig.actor_id)
	assert_true(absf(KillFallCells.victim_scale(rig) - crowd) > 0.01)


func test_a_street_walker_keeps_his_crowd_build() -> void:
	var rig: CutRig = _ped(2, 7)
	assert_true(StreetWalkerCards.hides_parts(rig))
	assert_null(CastCardPose.of(rig))
	assert_almost_eq(KillFallCells.victim_scale(rig), WALKER_7, 1e-9)
	assert_almost_eq(KillFallCells.height_px(rig, 64.0), _base_h() * 64.0 * WALKER_7, 1e-6)


func test_the_same_id_draws_the_same_size() -> void:
	assert_eq(KillFallCells.victim_scale(_ped(2, 12)), KillFallCells.victim_scale(_ped(4, 12)))
	var a: CutRig = _card_foe(SERGEANT)
	var b: CutRig = _card_foe(SERGEANT)
	assert_eq(a.actor_id, b.actor_id)
	assert_eq(KillFallCells.victim_scale(a), KillFallCells.victim_scale(b))
	assert_ne(KillFallCells.victim_scale(_ped(2, 7)), KillFallCells.victim_scale(_ped(2, 12)))
