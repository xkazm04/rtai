extends GutTest
## n5-look: Rivet's weapon FX print in colour on their own canvas (WeaponFxColour).


func test_no_colour_dir_is_the_ink_fx() -> void:
	var host: Node2D = autofree(Node2D.new())
	assert_null(WeaponFxColour.attach(host, ""))


func test_colour_canvas_takes_the_cells() -> void:
	var host: Node2D = Node2D.new()
	add_child_autofree(host)
	var c: WeaponFxColour = WeaponFxColour.attach(
		host, "res://features/combat/weapons/art/fx/colour"
	)
	assert_not_null(c)
	assert_true(c.rid.is_valid())
	var dot_k: float = c.mat.get_shader_parameter(&"dot_k")
	assert_almost_eq(dot_k, 0.22, 0.0001, "look_d5.params.json fx")
	c.begin(null)
	c.release()
	assert_false(c.rid.is_valid())


func test_shipped_art_draws_the_ink_fx() -> void:
	assert_eq(WeaponFxArt.art().fx_colour_dir, "", "d7-calls look-3: ink (--fx-colour=on = colour)")
	assert_true(DirAccess.dir_exists_absolute(WeaponFxCells.COLOUR_DIR), "the colour cells stay")
	assert_null(WeaponFxArt.colour, "lent only during FxView's draw")
