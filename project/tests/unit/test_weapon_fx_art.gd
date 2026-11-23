extends GutTest


class CellMeasure:
	extends WeaponFxColour
	var pixels: Vector2

	func cell(tex: Texture2D, xf: Transform2D, _anchor: Vector2, _alpha: float) -> void:
		var bounds: Vector2 = tex.get_image().get_used_rect().size
		pixels = bounds * Vector2(xf.x.length(), xf.y.length()) * 32.0 / Ink.PX_PER_M


func test_gloria_draws_a_short_thin_nail_at_gameplay_zoom() -> void:
	var host: Node2D = autofree(Node2D.new())
	var probe: CellMeasure = CellMeasure.new()
	var previous: WeaponFxColour = WeaponFxArt.colour
	WeaponFxArt.colour = probe
	var shot: Shot = Shot.new()
	shot.spec = WeaponSpec.new()
	shot.spec.id = &"gloria"
	shot.spec.kind = WeaponSpec.Kind.BULLET
	shot.pos = Vector2.RIGHT * 4.0
	shot.vel = Vector2.RIGHT
	assert_true(WeaponFxArt.shot(host, shot, 12))
	WeaponFxArt.colour = previous
	assert_between(probe.pixels.x, 15.0, 17.0, "length at 32 px/m")
	assert_between(probe.pixels.y, 3.5, 4.5, "width at 32 px/m")
