extends GutTest


class FenceFloor:
	extends PrologueFloor
	var draw_part: Callable

	func _ready() -> void:
		set_process(false)

	func _draw() -> void:
		draw_part.call(self)


class MeshPrint:
	extends Texture2D
	var panels: Array[Rect2] = []
	var repeats: Array[bool] = []

	func _draw_rect(item: RID, rect: Rect2, tile: bool, tint: Color, _transpose: bool) -> void:
		panels.append(rect)
		repeats.append(tile)
		RenderingServer.canvas_item_add_rect(item, rect, tint)


var plan: PrologueYard


func before_each() -> void:
	plan = PrologueYard.from_stage(DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA))


func _bounds(draw_part: Callable) -> Rect2:
	var floor_view: FenceFloor = FenceFloor.new()
	floor_view.plan = plan
	floor_view.draw_part = draw_part
	add_child_autofree(floor_view)
	await get_tree().process_frame
	await get_tree().process_frame
	return RenderingServer.debug_canvas_item_get_rect(floor_view.get_canvas_item())


func _assert_box(actual: Rect2, metres: Rect2) -> void:
	var expected: Rect2 = PrologueYardPaint.pixels(metres)
	assert_almost_eq(actual.position, expected.position, Vector2.ONE * 0.001)
	assert_almost_eq(actual.size, expected.size, Vector2.ONE * 0.001)


func test_ten_metre_run_has_three_even_mesh_bays_and_ends_at_the_kerb() -> void:
	var mesh: MeshPrint = MeshPrint.new()
	var rail: Rect2 = Rect2(4, 33.35, 10, 0.65)
	var bounds: Rect2 = await _bounds(PrologueYardFence.panel.bind(rail, mesh))
	_assert_box(bounds, Rect2(4, 33.02, 10, 0.98))
	assert_eq(mesh.panels.size(), 3)
	var bay: float = 10.0 / 3.0
	for i: int in mesh.panels.size():
		_assert_box(mesh.panels[i], Rect2(float(i) * bay, 0, bay, 0.98))
	assert_eq(mesh.repeats, [false, false, false])


func test_short_return_uses_one_bay_and_trims_it_to_the_available_length() -> void:
	var mesh: MeshPrint = MeshPrint.new()
	var rail: Rect2 = Rect2(7, 4, 1.2, 0.65)
	var bounds: Rect2 = await _bounds(PrologueYardFence.panel.bind(rail, mesh))
	_assert_box(bounds, Rect2(7, 3.67, 1.2, 0.98))
	assert_eq(mesh.panels.size(), 1)


func test_square_end_bay_faces_the_street() -> void:
	var mesh: MeshPrint = MeshPrint.new()
	var bounds: Rect2 = await _bounds(PrologueYardFence.panel.bind(Rect2(5, 4, 1, 1), mesh))
	_assert_box(bounds, Rect2(5, 4.02, 1, 0.98))


func test_post_has_a_left_highlight_and_a_double_width_cap() -> void:
	var strokes: Dictionary[Color, Rect2] = {}
	var paint: Callable = func(rect: Rect2, ink: Color) -> void: strokes[ink] = rect
	var box: Rect2 = plan.fences[-1]
	PrologueYardFence._gate_post(paint, box)
	var steel: Rect2 = box.grow(-0.07)
	assert_eq(strokes.size(), 4)
	var highlight: Rect2 = strokes.get(Color("b6aea2"), Rect2())
	var cap: Rect2 = strokes.get(Color("96918a"), Rect2())
	_assert_box(highlight, Rect2(steel.position, Vector2(0.07, steel.size.y)))
	_assert_box(cap, Rect2(steel.position, Vector2(steel.size.x, 0.14)))


func test_west_fence_turns_to_span_the_full_side_of_the_yard() -> void:
	var west: Rect2 = Rect2(-0.65, 0, 0.65, 34)
	var bounds: Rect2 = await _bounds(PrologueYardFence.panel.bind(west))
	_assert_box(bounds, Rect2(-0.98, 0, 0.98, 34))


func test_each_solid_post_fills_its_own_gate_footprint() -> void:
	var mesh: MeshPrint = MeshPrint.new()
	for post: Rect2 in plan.fences.slice(-2):
		var bounds: Rect2 = await _bounds(PrologueYardFence.panel.bind(post, mesh))
		_assert_box(bounds, post)
	assert_true(mesh.panels.is_empty(), "the two gate posts print solid steel")


func test_leaf_is_one_unbroken_print_parked_west_of_the_opening() -> void:
	var leaf: MeshPrint = MeshPrint.new()
	var bounds: Rect2 = await _bounds(PrologueYardFence.open_leaf.bind(plan, leaf))
	_assert_box(bounds, Rect2(27.9, 30.85, 5.1, 3.15))
	assert_eq(leaf.repeats, [false])
