extends GutTest
## n31 ghost 22: Kerf's cut ground (KerfDropMarks): nothing before C, the spatter C..C+11, the
## scorch held 2 s and faded 1 s, laid by a landed drop cut only and outliving the ghost. The
## art is ink, soot, charcoal, tan and flat amber (hue checked), never teal or red.

const CUT: int = 112

var stage: CollectCallStage
var squad: ArenaSquad
var pilot: StagePilot
var fx: GhostDeployEffects
var key: int


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage = CollectCallStage.new(StageLayout.shipped(false))
	stage.setup(World.build_context(bus, data, 24))
	stage.arena.rivet.pos = Vector2.ZERO
	stage.arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	squad = ArenaSquad.new(stage.arena.guard_map)
	stage.arena.squad_ai = squad
	pilot = StagePilot.new(PlayerActions.shipped(false))
	stage.pilot = pilot
	pilot.ghosts.forms.selected = &"kerf"
	key = 1 << pilot.actions.bit(&"ghost_deploy")
	fx = autofree(GhostDeployEffects.new())
	fx.stage = stage
	fx._ready()


func _marks() -> KerfDropMarks:
	return KerfDropMarks.new(Vector2(4, 1), Vector2.RIGHT, Vector2(4, 2), CUT)


func _drive(bits: int = 0) -> void:
	stage.tick += 1
	var aim: int = PlayerCommand.pack_aim(Vector2.RIGHT, pilot.actions, 6.0)
	pilot.drive(stage, TickInput.new(aim | bits))
	fx.track()


func _spawn(at: Vector2, hp: float) -> Fighter:
	var foe: Fighter = squad.spawn_member(stage.arena, at, &"contractor")
	foe.pos = at
	foe.facing = Vector2.UP
	foe.max_hp = hp
	foe.hp = hp
	return foe


func test_nothing_before_the_cut_then_the_spatter_for_twelve_ticks() -> void:
	var m: KerfDropMarks = _marks()
	assert_eq(m.ground_alpha(CUT - 1), 0.0, "no scorch before C")
	assert_eq(m.spatter_alpha(CUT - 1), 0.0, "no spatter before C")
	for tick: int in range(CUT, CUT + 12):
		assert_gt(m.spatter_alpha(tick), 0.0, "spatter at C+%d" % (tick - CUT))
	assert_eq(m.spatter_alpha(CUT + 12), 0.0, "spatter gone at C+12")


func test_the_scorch_holds_two_seconds_and_fades_one() -> void:
	var m: KerfDropMarks = _marks()
	assert_eq(m.ground_alpha(CUT), 1.0, "whole on C")
	assert_eq(m.ground_alpha(CUT + 119), 1.0)
	assert_almost_eq(m.ground_alpha(CUT + 150), 0.5, 0.0001)
	assert_eq(m.ground_alpha(CUT + 180), 0.0)
	assert_true(m.live(CUT + 179))
	assert_false(m.live(CUT + 180))


func test_a_landed_cut_lays_the_record_on_the_target_and_it_outlives_the_ghost() -> void:
	var foe: Fighter = _spawn(Vector2(5, 0), 1000.0)
	_drive(key)
	var ghost: GhostDeploy = pilot.ghosts.deploy
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE, "the press deploys him")
	while fx._kerf_drop == null and stage.tick < 200:
		_drive()
	assert_not_null(fx._kerf_drop, "the cut lays the record")
	var cut: int = fx._kerf_drop.cut_tick
	assert_eq(cut, ghost.strike.release_tick, "laid on C")
	assert_almost_eq(fx._kerf_drop.at.distance_to(foe.pos), 0.0, 0.3, "on the target")
	assert_almost_eq(fx._kerf_drop.rear.distance_to(ghost.spot), 0.0, 0.0001, "rear spot")
	while ghost.phase == GhostDeploy.Phase.ACTIVE and stage.tick < cut + 400:
		_drive()
	assert_ne(ghost.phase, GhostDeploy.Phase.ACTIVE, "the ghost is gone")
	assert_true(fx.lingers(), "the scorch stays after him (C+%d)" % (stage.tick - cut))
	stage.tick = cut + 179
	assert_true(fx.lingers())
	stage.tick = cut + 180
	assert_false(fx.lingers(), "gone after C+180")


func test_a_whiffed_cut_leaves_no_record() -> void:
	var foe: Fighter = _spawn(Vector2(5, 0), 1000.0)
	_drive(key)
	var ghost: GhostDeploy = pilot.ghosts.deploy
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE, "the press locks the target")
	foe.hp = 0.0  # the lock breaks: the target dies before C
	while ghost.phase == GhostDeploy.Phase.ACTIVE and stage.tick < 200:
		_drive()
	assert_null(fx._kerf_drop, "a whiff draws no scorch")
	assert_false(fx.lingers())


func test_the_ground_art_is_world_colours_and_amber_never_teal_or_red() -> void:
	var all: Array[Texture2D] = [KerfDropMarks.SCORCH, KerfDropMarks.SPATTER, KerfDropMarks.REAR]
	for tex: Texture2D in all:
		var img: Image = tex.get_image()
		var off: int = 0
		for y: int in range(0, img.get_height(), 4):
			for x: int in range(0, img.get_width(), 4):
				var c: Color = img.get_pixel(x, y)
				# Amber heat sits at hue 20-50 degrees; red/vermilion below 10, teal 150-210.
				var hue: float = c.h * 360.0
				var vivid: bool = c.a > 0.5 and c.s > 0.5 and c.v > 0.4
				var teal: bool = hue > 150.0 and hue < 210.0
				var red: bool = hue < 10.0 or hue > 340.0
				if vivid and (teal or red):
					off += 1
		assert_eq(off, 0, tex.resource_path)
