extends GutTest
## n31 ghost 17: Dent's drop drawn in beats: faces the lane, waits at the origin through the
## wind-up, rams to the spot over R..R+8; Tonnage and Ohm keep row 0.

var stage: CollectCallStage
var pilot: StagePilot
var ghost: GhostDeploy
var key: int


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage = CollectCallStage.new(StageLayout.shipped(false))
	stage.setup(World.build_context(bus, data, 24))
	stage.arena.rivet.pos = Vector2.ZERO
	pilot = StagePilot.new(PlayerActions.shipped(false))
	stage.pilot = pilot
	ghost = pilot.ghosts.deploy
	pilot.ghosts.forms.selected = DentStage.GHOST
	key = 1 << pilot.actions.bit(&"ghost_deploy")


func _lane() -> GhostDeploy:
	var lane: GhostDeploy = ghost
	lane.origin = Vector2(0.0, 0.5)
	lane.spot = Vector2(8.0, 0.5)
	return lane


func test_wind_up_stands_at_the_origin_pulled_back_along_the_lane() -> void:
	var lane: GhostDeploy = _lane()
	assert_eq(DentDropBeats.at(lane, 0, -15), lane.origin, "arrives on the origin")
	var back: Vector2 = lane.origin - Vector2.RIGHT * DentDropBeats.RECOIL_M
	assert_almost_eq(DentDropBeats.at(lane, 10, -5).distance_to(back), 0.0, 0.0001)
	assert_almost_eq(DentDropBeats.at(lane, 14, -1).distance_to(back), 0.0, 0.0001)


func test_ram_starts_at_the_pull_back_and_reaches_the_spot_on_r_plus_8() -> void:
	var lane: GhostDeploy = _lane()
	var back: Vector2 = lane.origin - Vector2.RIGHT * DentDropBeats.RECOIL_M
	assert_almost_eq(DentDropBeats.at(lane, 15, 0).distance_to(back), 0.0, 0.0001)
	var last: float = -INF
	for struck: int in DentDropBeats.RAM_TICKS + 1:
		var x: float = DentDropBeats.at(lane, 15 + struck, struck).x
		assert_gt(x, last, "monotone toward the spot")
		last = x
	assert_gt(DentDropBeats.at(lane, 16, 1).x - back.x, 1.5, "fast start: a ram")
	assert_eq(DentDropBeats.at(lane, 23, DentDropBeats.RAM_TICKS), lane.spot)
	assert_eq(DentDropBeats.at(lane, 40, 25), lane.spot, "stays to the fade")


func test_pose_boundaries() -> void:
	assert_eq(DentDropBeats.pose(3, -12), DentSpectralDrawn.Pose.HOVER)
	assert_eq(DentDropBeats.pose(4, -11), DentSpectralDrawn.Pose.COCK)
	assert_eq(DentDropBeats.pose(14, -1), DentSpectralDrawn.Pose.COCK)
	assert_eq(DentDropBeats.pose(15, 0), DentSpectralDrawn.Pose.DIVE)
	assert_eq(DentDropBeats.pose(22, 7), DentSpectralDrawn.Pose.DIVE)
	assert_eq(DentDropBeats.pose(23, 8), DentSpectralDrawn.Pose.JAB)


func test_dropped_dent_is_drawn_at_the_origin_then_at_the_spot_from_r_plus_8() -> void:
	var layer: CanvasLayer = add_child_autofree(CanvasLayer.new())
	GhostDeployView.attach(layer, stage, false)
	var view: GhostDeployView = layer.get_child(0) as GhostDeployView
	var charge: int = ghost.strike.attacks.deploy[DentStage.GHOST].charge_ticks
	var drawn: Array[Vector2] = []
	for i: int in charge + DentDropBeats.RAM_TICKS + 4:
		_drive(key if i == 0 else 0)
		view._process(0.0)
		drawn.append(view._body.position / SimConst.PX_PER_M)
	var reach: float = DentDropBeats.RECOIL_M + 0.001
	for age: int in charge:
		assert_lt(
			drawn[age].distance_to(ghost.origin), reach, "wind-up at the origin, age %d" % age
		)
	assert_gt(drawn[charge + 3].distance_to(ghost.origin), 2.0, "mid-lane on R+3")
	for age: int in range(charge + DentDropBeats.RAM_TICKS, drawn.size()):
		assert_almost_eq(drawn[age].distance_to(ghost.spot), 0.0, 0.001, "spot, age %d" % age)
	var body: DentBody = view._body._body as DentBody
	assert_eq(body.deploy_pose, DentSpectralDrawn.Pose.JAB)


func test_dent_faces_the_lane_while_tonnage_and_ohm_keep_row_0() -> void:
	var layer: CanvasLayer = add_child_autofree(CanvasLayer.new())
	GhostDeployView.attach(layer, stage, false)
	var body: GhostDeployBody = (layer.get_child(0) as GhostDeployView)._body
	for form: StringName in [DentStage.GHOST, HaulerStage.GHOST, OhmStage.GHOST]:
		ghost.form = form
		assert_true(body._drops(ghost), "%s ships as a drop" % form)
		assert_eq(body._faces_camera(ghost), form != DentStage.GHOST, String(form))


func _drive(bits: int) -> void:
	stage.tick += 1
	var aim: int = PlayerCommand.pack_aim(Vector2.RIGHT, pilot.actions, 18.0)
	pilot.drive(stage, TickInput.new(aim | bits))


func test_hold_mode_keeps_the_flight_pose_then_jab_once_struck() -> void:
	assert_eq(DentDropBeats.cell(false, 3, -1), -1)
	assert_eq(DentDropBeats.cell(false, 3, 0), DentSpectralDrawn.Pose.JAB)
	assert_eq(DentDropBeats.cell(true, 3, -12), DentSpectralDrawn.Pose.HOVER)
