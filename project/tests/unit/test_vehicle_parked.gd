extends GutTest
## n8 vehicles: the city's kerb-parked cars register per chunk and map to the card rows; the bus
## (no card yet) keeps its flat prop.


func after_each() -> void:
	VehicleParked.clear()


func test_rows_map_the_parked_props_and_the_bus_stays_flat() -> void:
	assert_eq(VehicleParked.row(44), 0)
	assert_eq(VehicleParked.row(53), 8)
	assert_eq(VehicleParked.row(50), 0, "the wreck is a sedan card, tinted")
	assert_eq(VehicleParked.row(51), -1, "the bus keeps its flat prop")
	assert_eq(VehicleParked.row(12), -1)


func test_put_near_draws_only_registered_cars_in_range() -> void:
	var cards: VehicleCards = VehicleCards.new()
	add_child_autofree(cards)
	VehicleParked.park(
		Vector2i(0, 0), PackedVector4Array([Vector4(1, 1, 0, 44), Vector4(90, 0, 0, 48)])
	)
	VehicleParked.park(Vector2i(1, 0), PackedVector4Array([Vector4(5, 5, 0, 51)]))
	cards.begin(null)
	VehicleParked.put_near(cards, Vector2.ZERO, 60.0)
	cards.finish()
	assert_eq(cards.count(), 1, "the far van and the bus are not drawn")
	VehicleParked.unpark(Vector2i(0, 0))
	cards.begin(null)
	VehicleParked.put_near(cards, Vector2.ZERO, 60.0)
	cards.finish()
	assert_eq(cards.count(), 0)
