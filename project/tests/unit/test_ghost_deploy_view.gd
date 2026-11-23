extends GutTest

var stage: CollectCallStage
var actions: PlayerActions


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage = CollectCallStage.new(StageLayout.shipped(false))
	stage.setup(World.build_context(bus, data, 24))
	actions = PlayerActions.shipped(false)
	stage.pilot = StagePilot.new(actions)
	stage.pilot.ghosts.forms.selected = OhmStage.GHOST


func test_rig_and_attack_hosts_share_one_quiet_view_without_changing_the_replay() -> void:
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


func test_body_appears_holds_its_follow_through_and_fades_on_the_last_tick() -> void:
	var layer: CanvasLayer = add_child_autofree(CanvasLayer.new())
	GhostDeployView.attach(layer, stage, false)
	var view: GhostDeployView = layer.get_child(0) as GhostDeployView
	var ghost: GhostDeploy = stage.pilot.ghosts.deploy
	var aim: int = PlayerCommand.pack_aim(Vector2.RIGHT, actions, 3.0)
	stage.tick += 1
	stage.pilot.drive(stage, TickInput.new(aim | (1 << actions.bit(&"ghost_deploy"))))
	var life: int = ghost.strike.attacks.deploy[OhmStage.GHOST].life_ticks
	var alpha: Array[float] = []
	for age: int in life:
		stage.tick += 1
		stage.pilot.drive(stage, TickInput.new(aim))
		view._process(0.0)
		alpha.append(view._body.self_modulate.a)
		if age == 3:
			var fade: ShaderMaterial = view._body.material as ShaderMaterial
			var erosion: float = fade.get_shader_parameter(&"fade_from")
			assert_almost_eq(erosion, 0.625, 0.001)
	var drawn: GhostDrawn = view._body._body.get(&"drawn")
	assert_eq(drawn.act_col(), GhostDrawn.FOLLOW_COL)
	assert_lt(alpha[0], alpha[3])
	assert_lt(alpha[3], alpha[8])
	assert_almost_eq(alpha[6], 0.95, 0.001)
	assert_eq(alpha[6], alpha[8])
	assert_gt(alpha[8], alpha[-1])
