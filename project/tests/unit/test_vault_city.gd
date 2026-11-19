extends GutTest


func test_a_solid_without_a_shadow_owns_its_city_cells() -> void:
	# The dock crab pots at (2017.4, 61.54) have only a foreground draw command.
	var city: VaultCity = VaultCity.new(StageCells.shipped())
	var cell: Vector2i = Vector2i(2017, 61)
	var prop: VaultCity.Prop = city.owner(cell)
	assert_not_null(prop)
	if prop != null:
		assert_eq(prop.kind, "dock_crab_pots")
