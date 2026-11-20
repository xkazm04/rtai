extends GutTest


func test_jab_lifts_only_the_named_items_and_preserves_the_next_natural_sort() -> void:
	var order: DentJabOrder = autofree(DentJabOrder.new())
	var band: Node2D = Node2D.new()
	add_child_autofree(band)
	band.z_index = RenderLayers.z(&"actors")
	var punch: Node2D = Node2D.new()
	var victim: Node2D = Node2D.new()
	var bystander: Node2D = Node2D.new()
	for node: Node2D in [punch, victim, bystander]:
		band.add_child(node)
	punch.z_index = 60
	order._raise(punch)
	order._raise(victim)
	assert_gt(RigDepthSort.eff_z(victim) + GhostRim.KEY_Z, RenderLayers.z(&"vehicles"))
	assert_eq(RigDepthSort.eff_z(punch) - RigDepthSort.eff_z(victim), 60)
	assert_eq(bystander.z_index, 0)
	victim.z_index = 32
	order._restore()
	assert_eq(punch.z_index, 60)
	assert_eq(victim.z_index, 32)
	assert_eq(bystander.z_index, 0)


func test_contact_needs_damage_from_this_swing_and_fades_on_jab_ticks() -> void:
	var stage: CollectCallStage = CollectCallPlay.begin().stage
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	var view: GhostFormView = autofree(GhostFormView.make(stage, null, null))
	var body: Node2D = Node2D.new()
	add_child_autofree(body)
	var order: DentJabOrder = DentJabOrder.new()
	body.add_child(order)
	order.bind(body, view, DentJabMark.new(HaulerLook.TEAL, DentStrap.AQUA, DentRoof.INK))
	var jab: DentJab = stage.pilot.ghosts.jab
	jab.steps = 20
	jab.swung_step = 20
	jab.swings = 1
	var fist: Vector2 = Vector2(30, 45)
	stage.arena.wounded.emit(stage.arena.rivet, &"dent_car")
	order.strike(jab, fist, 0.0)
	assert_false(order.mark._hit)
	stage.arena.wounded.emit(stage.arena.rivet, DentJab.WEAPON)
	order.strike(jab, fist, 0.5)
	assert_true(order.mark._hit)
	assert_eq(order.mark.global_position, fist)
	assert_almost_eq(order.mark.global_rotation, 0.5, 0.001)
	assert_eq(order.mark._fade, 1.0)
	jab.steps += 3
	order.strike(jab, fist, 0.5)
	assert_eq(order.mark._fade, 0.5)
	jab.steps += 3
	order.strike(jab, fist, 0.5)
	assert_false(order.mark.visible)
