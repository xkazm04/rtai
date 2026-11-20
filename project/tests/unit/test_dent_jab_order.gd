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
