extends GutTest
## n31 ghost 18b: Dent's drop ground (DentDropMarks): the skid telegraph reaches the spot by R-6
## and not before P+4, the scuffed lane holds 2 s and fades 1 s, the record outlives the ghost.

const PRESS: int = 100
const RAM: int = 115
const HALF: float = 1.3
const FROM: Vector2 = Vector2(1.0, 2.0)
const TO: Vector2 = Vector2(7.0, 2.0)


func _marks() -> DentDropMarks:
	return DentDropMarks.new(FROM, TO, PRESS, RAM, HALF)


func test_the_skid_front_runs_from_the_origin_to_the_spot_between_p4_and_r6() -> void:
	var m: DentDropMarks = _marks()
	for tick: int in range(PRESS, PRESS + 4):
		assert_eq(m.skid_m(tick), 0.0, "tick P+%d: no skid on arrival" % (tick - PRESS))
	var last: float = 0.0
	for tick: int in range(PRESS + 4, RAM - 6):
		var front: float = m.skid_m(tick)
		assert_gt(front, last, "tick P+%d: the front moves on" % (tick - PRESS))
		assert_lt(front, m.length_m(), "tick P+%d: short of the spot until R-6" % (tick - PRESS))
		last = front
	assert_almost_eq(m.skid_m(RAM - 6), 6.0, 0.0001, "whole by R-6, the dive's start")
	assert_almost_eq(m.skid_m(RAM - 1), 6.0, 0.0001)


func test_the_scuff_shows_from_the_ram_holds_two_seconds_and_fades_one() -> void:
	var m: DentDropMarks = _marks()
	assert_eq(m.ground_alpha(RAM - 1), 0.0, "no scuff during the wind-up")
	assert_eq(m.ground_alpha(RAM), 1.0, "the scuff replaces the skid on R")
	assert_eq(m.ground_alpha(RAM + 119), 1.0)
	assert_almost_eq(m.ground_alpha(RAM + 150), 0.5, 0.0001)
	assert_eq(m.ground_alpha(RAM + 180), 0.0)
	assert_true(m.live(RAM + 179))
	assert_false(m.live(RAM + 180))


func test_the_record_outlives_the_ghost_and_goes_after_r180() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped(false))
	stage.setup(World.build_context(bus, data, 24))
	stage.arena.rivet.pos = Vector2.ZERO
	stage.arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	stage.arena.squad_ai = ArenaSquad.new(stage.arena.guard_map)
	var pilot: StagePilot = StagePilot.new(PlayerActions.shipped(false))
	stage.pilot = pilot
	pilot.ghosts.forms.selected = &"dent"
	var fx: GhostDeployEffects = autofree(GhostDeployEffects.new())
	autofree(fx._ground)
	fx.stage = stage
	var key: int = 1 << pilot.actions.bit(&"ghost_deploy")
	var aim: int = PlayerCommand.pack_aim(Vector2.RIGHT, pilot.actions, 6.0)
	stage.tick += 1
	pilot.drive(stage, TickInput.new(aim | key))
	var ghost: GhostDeploy = pilot.ghosts.deploy
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE, "the press deploys him")
	fx.track()
	assert_not_null(fx._dent_drop, "a drop press lays the record")
	var ram: int = fx._dent_drop.ram_tick
	while ghost.phase == GhostDeploy.Phase.ACTIVE and stage.tick < ram + 400:
		stage.tick += 1
		pilot.drive(stage, TickInput.new(aim))
		fx.track()
	assert_ne(ghost.phase, GhostDeploy.Phase.ACTIVE, "the ghost is gone")
	assert_true(fx.lingers(), "the scuff stays after him (tick R+%d)" % (stage.tick - ram))
	stage.tick = ram + 179
	assert_true(fx.lingers())
	stage.tick = ram + 180
	assert_false(fx.lingers(), "gone after R+180")


func test_the_ground_art_is_tan_soot_and_ink_never_teal_or_red() -> void:
	var all: Array[Texture2D] = [
		DentDropMarks.SKID,
		DentDropMarks.SCUFF,
		DentDropMarks.WAKE,
		DentDropMarks.CAP,
		DentDropMarks.STOP,
		DentDropMarks.PUFF
	]
	for tex: Texture2D in all:
		var img: Image = tex.get_image()
		var off: int = 0
		for y: int in range(0, img.get_height(), 8):
			for x: int in range(0, img.get_width(), 8):
				var c: Color = img.get_pixel(x, y)
				var teal: bool = c.g > c.r + 0.15 and c.b > c.r + 0.15
				var red: bool = c.r > 0.5 and c.r > c.g + 0.35 and c.r > c.b + 0.35
				if c.a > 0.5 and (teal or red):
					off += 1
		assert_eq(off, 0, tex.resource_path)
