extends GutTest


func test_fan_covers_every_edge_once() -> void:
	var idx: PackedInt32Array = KillPoly.fan_indices(4)
	assert_eq(idx.size(), 12)
	assert_eq(Array(idx.slice(9, 12)), [0, 4, 1])


func test_fan_of_a_degenerate_outline_is_empty() -> void:
	assert_eq(KillPoly.fan_indices(2).size(), 0)


func test_fill_draws_a_sub_pixel_flake_without_error() -> void:
	var probe: Node2D = Node2D.new()
	add_child_autofree(probe)
	var flake: PackedVector2Array = [
		Vector2(0, 0), Vector2(0.4, 0.1), Vector2(0.5, 0.5), Vector2(0.1, 0.45)
	]
	KillPoly.fill(probe, flake, Color.WHITE)
	assert_true(is_instance_valid(probe))
