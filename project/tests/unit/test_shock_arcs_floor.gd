extends GutTest
## n12 D1: a stunned cop's dropped pistol lies on the ground band, under every body; the arcs
## that crawl over the body stay above the rigs.


func test_the_dropped_gun_draws_under_the_bodies() -> void:
	var v: ShockArcsView = ShockArcsView.new()
	v.z_index = RenderLayers.z(&"actors") + 50
	add_child_autofree(v)
	assert_eq(v.get_child_count(), 1, "a floor child for the lying pistols")
	var floor_node: Node2D = v.get_child(0) as Node2D
	assert_false(floor_node.z_as_relative)
	assert_lt(floor_node.z_index, RenderLayers.z(&"actors"), "under the bodies")
	assert_lt(floor_node.z_index, v.z_index, "under the arcs")
