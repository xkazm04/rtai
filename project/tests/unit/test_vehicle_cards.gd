extends GutTest
## n8 vehicles: VehicleCards picks the rotation-set view nearest a car's heading (5 drawn + 3
## mirrored) and turns the card by the rest, so the drawn nose always points along the heading.


func test_the_five_drawn_views_and_their_mirrors() -> void:
	assert_eq(VehicleCards.view_of(90.0), Vector3(0, 0, 90))  # nose down: nose to the camera
	assert_eq(VehicleCards.view_of(45.0), Vector3(1, 0, 45))
	assert_eq(VehicleCards.view_of(0.0), Vector3(2, 0, 0))  # side, nose right
	assert_eq(VehicleCards.view_of(-45.0), Vector3(3, 0, -45))
	assert_eq(VehicleCards.view_of(-90.0), Vector3(4, 0, -90))  # tail to the camera
	assert_eq(VehicleCards.view_of(135.0), Vector3(1, 1, 135))
	assert_eq(VehicleCards.view_of(180.0), Vector3(2, 1, -180))  # wrapf: 180 is -180
	assert_eq(VehicleCards.view_of(-135.0), Vector3(3, 1, -135))


func test_the_rest_never_passes_half_a_view() -> void:
	for d: int in range(-180, 181, 3):
		var pick: Vector3 = VehicleCards.view_of(float(d))
		var rest: float = wrapf(float(d) - pick.z, -180.0, 180.0)
		assert_true(absf(rest) <= VehicleCards.VIEW_DEG * 0.5 + 0.001, "heading %d" % d)


func test_the_card_is_unsquashed_by_the_ground_scale() -> void:
	var xf: Transform2D = VehicleCards.card_xf(Vector2(1.0, 2.0), 0.0)
	var gk: float = ViewMode.shared().ground_k()
	var s: float = VehicleCards.CELL_M * SimConst.PX_PER_M
	assert_almost_eq(xf.x.x, s, 0.001)
	assert_almost_eq(xf.y.y, s / gk, 0.001)
	assert_eq(xf.origin, Vector2(1.0, 2.0) * SimConst.PX_PER_M)


func test_rigid_turn_rolls_the_card_and_upright_keeps_it_vertical() -> void:
	var keep: float = VehicleCards.upright_k
	VehicleCards.upright_k = 0.0
	var rigid: Transform2D = VehicleCards.card_xf(Vector2.ZERO, 20.0)
	VehicleCards.upright_k = 1.0
	var up: Transform2D = VehicleCards.card_xf(Vector2.ZERO, 20.0)
	VehicleCards.upright_k = keep
	assert_lt(rigid.y.x, -1.0, "rigid: the card's vertical leans with the turn")
	assert_almost_eq(up.y.x, 0.0, 0.001)
	assert_almost_eq(up.x, rigid.x, Vector2(0.001, 0.001))
