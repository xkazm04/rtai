extends GutTest


func test_a_solid_without_a_shadow_owns_its_city_cells() -> void:
	# The dock crab pots at (2017.4, 61.54) have only a foreground draw command.
	var city: VaultCity = VaultCity.new(StageCells.shipped())
	var cell: Vector2i = Vector2i(2017, 61)
	var prop: VaultCity.Prop = city.owner(cell)
	assert_not_null(prop)
	if prop != null:
		assert_eq(prop.kind, "dock_crab_pots")


func test_both_ends_of_the_sedan_belong_to_its_own_rotated_sprite() -> void:
	# This east-west sedan follows a north-south draw command on the docks.
	var city: VaultCity = VaultCity.new(StageCells.shipped())
	var center: VaultCity.Prop = city.owner(Vector2i(1971, 144))
	assert_not_null(center)
	if center != null:
		assert_eq(center.kind, "sedan")
		assert_same(city.owner(Vector2i(1969, 144)), center)
		assert_same(city.owner(Vector2i(1973, 144)), center)
