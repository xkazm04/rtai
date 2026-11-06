extends GutTest
## n8 vehicles: VehicleCards with `cull` on skips a car whose ground point is off screen by more
## than a card cell (VehicleCull.screen_m), and draws every car when off (or out of a tree).


func test_out_of_a_tree_there_is_no_cull_rect() -> void:
	var cards: VehicleCards = VehicleCards.new()
	assert_false(VehicleCull.screen_m(cards, 7.0).has_area())
	cards.free()


func test_the_rect_follows_the_canvas_and_grows() -> void:
	var cards: VehicleCards = VehicleCards.new()
	add_child_autofree(cards)
	var r: Rect2 = VehicleCull.screen_m(cards, 7.0)
	var px: Vector2 = cards.get_viewport_rect().size / SimConst.PX_PER_M
	assert_almost_eq(r.size.x, px.x + 14.0, 0.01)
	cards.position = Vector2(10.0 * SimConst.PX_PER_M, 0.0)  # 10 m right: it sees 10 m left
	assert_almost_eq(VehicleCull.screen_m(cards, 7.0).position.x, r.position.x - 10.0, 0.01)


func test_a_culled_car_far_off_screen_is_not_put() -> void:
	var cards: VehicleCards = VehicleCards.new()
	cards.cull = true
	add_child_autofree(cards)
	cards.begin(null)
	cards.put(0, Vector2.ZERO, Vector2.RIGHT, Color.WHITE)
	cards.put(0, Vector2(-6.0, -6.0), Vector2.RIGHT, Color.WHITE)  # off screen, inside a cell
	cards.put(0, Vector2(1000.0, 1000.0), Vector2.RIGHT, Color.WHITE)
	cards.finish()
	assert_eq(cards.count(), 2)


func test_without_cull_every_car_is_put() -> void:
	var cards: VehicleCards = VehicleCards.new()
	add_child_autofree(cards)
	cards.begin(null)
	cards.put(0, Vector2(1000.0, 1000.0), Vector2.RIGHT, Color.WHITE)
	cards.finish()
	assert_eq(cards.count(), 1)
