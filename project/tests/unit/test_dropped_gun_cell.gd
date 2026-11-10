extends GutTest
## n13 item 2: a stunned cop's dropped pistol is the pistol's drawn cell (weapon_art.json
## parts.dropped), loaded at _ready, lying muzzle-sideways with its tilt halved.


func test_the_cell_loads_at_ready() -> void:
	var v: ShockArcsView = ShockArcsView.new()
	assert_null(v.cell, "nothing loaded before the view enters the tree")
	add_child_autofree(v)
	assert_not_null(v.cell, "the drawn cell, loaded behind the load")
	var want: Texture2D = WeaponArt.new().part_texture(&"pistol", "dropped")
	assert_eq(v.cell.resource_path, want.resource_path)
	assert_string_ends_with(v.cell.resource_path, "pistol/dropped.png")


func test_the_floor_samples_the_cell_through_its_mips() -> void:
	var v: ShockArcsView = ShockArcsView.new()
	add_child_autofree(v)
	var floor_node: Node2D = v.get_child(0) as Node2D
	assert_eq(floor_node.texture_filter, CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS)


func test_a_rightward_drop_keeps_its_side_with_half_the_tilt() -> void:
	assert_eq(ShockArcsView.lie_of(0.0), Vector2(0.0, 1.0))
	var lie: Vector2 = ShockArcsView.lie_of(0.8)
	assert_almost_eq(lie.x, 0.8 * ShockArcsView.CELL_TILT_K, 1e-5)
	assert_eq(lie.y, 1.0)
	assert_almost_eq(ShockArcsView.lie_of(-1.2).x, -1.2 * ShockArcsView.CELL_TILT_K, 1e-5)
	assert_eq(ShockArcsView.lie_of(PI * 0.5).y, 1.0, "straight down stays unmirrored")


func test_a_leftward_drop_is_mirrored_never_upside_down() -> void:
	var lie: Vector2 = ShockArcsView.lie_of(PI)
	assert_eq(lie.y, -1.0)
	assert_almost_eq(lie.x, 0.0, 1e-5)
	lie = ShockArcsView.lie_of(PI - 0.6)  # up-left: mirrored, tilted the other way
	assert_eq(lie.y, -1.0)
	assert_almost_eq(lie.x, -0.6 * ShockArcsView.CELL_TILT_K, 1e-5)
	lie = ShockArcsView.lie_of(-PI + 0.4 + TAU)  # wrapped input
	assert_eq(lie.y, -1.0)
	assert_almost_eq(lie.x, 0.4 * ShockArcsView.CELL_TILT_K, 1e-5)


func test_every_lie_is_within_the_tilt_cap() -> void:
	for i: int in 64:
		var lie: Vector2 = ShockArcsView.lie_of(TAU * i / 64.0 - PI)
		assert_lte(absf(lie.x), PI * 0.5 * ShockArcsView.CELL_TILT_K + 1e-5)
