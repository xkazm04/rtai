extends GutTest


func test_tilted_beams_attach_to_rear_metal_in_every_hover_cell() -> void:
	var previous: String = ViewMode.shared().id
	var body: KerfSpectral = add_child_autofree(KerfSpectral.new(KerfRig.HULL_M * 1.1))
	for view: String in ["tilt", "tilt70"]:
		ViewMode.select(view)
		body.pose(0.0, -1, false, 0.0, 0)
		var sprite: Sprite2D = body._tilted
		var atlas: Image = sprite.texture.get_image()
		var cell: Vector2i = atlas.get_size() / Vector2i(sprite.hframes, sprite.vframes)
		for oct: int in 8:
			var angle: float = oct * TAU / 8.0
			for mood: int in 3:
				var moving: bool = mood != KerfSpectral.Mood.POISED
				var blink: bool = mood == KerfSpectral.Mood.LUNGE
				body.pose(12.0 if moving else 0.0, 0 if blink else -1, false, angle, oct)
				var anchor: Vector2 = body.beams.global_position - body.global_position
				assert_lt(anchor.dot(Vector2.from_angle(angle)), 0.0)
				for side: int in [-1, 0, 1]:
					var start: Vector2 = Vector2(
						body.beams.tail_x, side * 0.12 * 32 * body.beams.fast
					)
					var uv: Vector2 = sprite.to_local(body.beams.to_global(start))
					if sprite.flip_h:
						uv.x = -uv.x
					var pixel: Vector2i = Vector2i(uv + Vector2(cell) * 0.5)
					pixel += sprite.frame_coords * cell
					assert_gt(
						atlas.get_pixelv(pixel).a, 0.5, "%s oct %d mood %d" % [view, oct, mood]
					)
	ViewMode.select(previous)
