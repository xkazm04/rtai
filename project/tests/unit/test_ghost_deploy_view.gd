extends GutTest


func test_rig_and_attack_hosts_share_one_quiet_view_without_changing_the_replay() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped(false))
	stage.setup(World.build_context(bus, data, 24))
	var actions: PlayerActions = PlayerActions.shipped(false)
	stage.pilot = StagePilot.new(actions)
	stage.pilot.ghosts.forms.selected = OhmStage.GHOST
	var layer: CanvasLayer = add_child_autofree(CanvasLayer.new())
	GhostDeployView.attach(layer, stage, false)
	GhostDeployView.attach(layer, stage, true)
	assert_eq(layer.get_child_count(), 1)
	var view: GhostDeployView = layer.get_child(0) as GhostDeployView
	assert_true(view.reduced_motion)
	var aim: int = PlayerCommand.pack_aim(Vector2.RIGHT, actions, 3.0)
	stage.tick += 1
	stage.pilot.drive(stage, TickInput.new(aim | (1 << actions.bit(&"ghost_deploy"))))
	view._process(0.0)
	assert_null(view._body.source, "aiming needs only the ground marker")
	stage.tick += 1
	stage.pilot.drive(stage, TickInput.new(aim))
	var ghost: GhostDeploy = stage.pilot.ghosts.deploy
	var before: StreamPeerBuffer = StreamPeerBuffer.new()
	ghost.write_state(before)
	view._process(0.0)
	var after: StreamPeerBuffer = StreamPeerBuffer.new()
	ghost.write_state(after)
	assert_true(view._body.is_visible_in_tree())
	var edge: Vector2 = view._body.position / SimConst.PX_PER_M - ghost.spot
	assert_almost_eq(edge.length(), ghost.strike.attacks.deploy[OhmStage.GHOST].radius_m, 0.001)
	assert_lt(edge.dot(ghost.facing), 0.0, "Ohm stands on the side nearest the caster")
	assert_eq(before.data_array, after.data_array)
	assert_eq(stage.pilot.ghosts.forms.current(), GhostForms.BASE)
