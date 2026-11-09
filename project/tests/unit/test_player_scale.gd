extends GutTest
## n11 hero (the owner's "increase size of all player's characters to 150%").


func test_the_table_ships_the_owner_size() -> void:
	assert_almost_eq(PlayerScale.k(), 1.5, 0.0001)


func test_fit_scales_a_body() -> void:
	var body: Node2D = add_child_autofree(Node2D.new())
	PlayerScale.fit([body])
	assert_almost_eq(body.scale.x, PlayerScale.k(), 0.0001)
