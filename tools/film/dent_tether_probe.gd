extends RefCounted
## Loaded only in the film helper's scratch project. The clock stops before measuring geometry.

var _best: float = 0.4
var _trace_path: String
var _out: FileAccess
var _used: Dictionary[String, Rect2] = {}
var _images: Dictionary[int, Image] = {}


func sample(view: DentView, usec: int) -> void:
	if _out == null:
		_trace_path = ArenaArgs.parse().text("--film-trace")
		_out = FileAccess.open(_trace_path + ".draw", FileAccess.WRITE)
	var row: Dictionary = {
		"frame": Engine.get_process_frames(), "tick": view.stage.tick, "draw_us": usec
	}
	var tether: DentTether = view._tether
	if tether != null and tether.strap.showing():
		var lines: Array[PackedVector2Array] = []
		if tether.strings == null:
			lines.append(tether.strap.belt_path(1.0 - tether.strap.fray()))
		else:
			for i: int in 4:
				lines.append(tether.strings.path(i))
		var width: float = (
			tether.strap.width_px() if tether.strings == null else DentStrings.INK_M * view.ppm
		)
		var distance: float = view.stage.arena.rivet.pos.distance_to(tether.strap.ground_m)
		row["distance_m"] = distance
		_closest_still(view, distance)
		row["turn"] = tether.strings.turn if tether.strings else 0.0
		row["look"] = "strings" if tether.strings else "strap"
		var xf: Transform2D = view.get_global_transform_with_canvas()
		row["lines"] = _screen_paths(lines, xf)
		row["width_px"] = width * xf.x.length()
		row["boxes"] = _guards(view, tether._body._view.rigs)
	@warning_ignore("return_value_discarded")
	_out.store_line(JSON.stringify(row))


func _closest_still(view: DentView, distance: float) -> void:
	var mark: int = 20 if _trace_path.get_file().begins_with("range_") else 5
	if absf(mark - distance) >= _best:
		return
	_best = absf(mark - distance)
	var window: Window = view.get_tree().root
	var shot: Callable = func() -> void:
		var image: Image = window.get_texture().get_image()
		if image.save_png(_trace_path + ".png") != OK:
			Log.error("dent_film", "Could not save range still")
	@warning_ignore("return_value_discarded")
	RenderingServer.frame_post_draw.connect(shot, CONNECT_ONE_SHOT)


func _screen_paths(lines: Array[PackedVector2Array], xf: Transform2D) -> Array:
	var result: Array = []
	for path: PackedVector2Array in lines:
		var coords: Array = []
		for point: Vector2 in path:
			var screen: Vector2 = xf * point
			coords.append([screen.x, screen.y])
		result.append(coords)
	return result


func _guards(view: DentView, rigs: CharacterRigs) -> Array:
	var result: Array = []
	for fighter: Fighter in view.stage.arena.hostiles:
		if fighter.kind != Fighter.Kind.GUARD:
			continue
		var rig: CutRig = rigs.rig_for(fighter.id)
		var box: Rect2
		if rig != null and rig.is_visible_in_tree():
			for sprite: Sprite2D in rig.find_children("*", "Sprite2D", true, false):
				var part: Rect2 = _screen_box(sprite)
				if part.has_area():
					box = box.merge(part) if box.has_area() else part
		else:
			var corpse: Sprite2D = rigs.rest.top_sprite(fighter.id)
			if corpse:
				box = _screen_box(corpse)
		box = box.intersection(view.get_viewport_rect())
		if box.has_area():
			result.append(
				[fighter.id, box.position.x, box.position.y, box.end.x, box.end.y, fighter.alive()]
			)
	return result


func _screen_box(sprite: Sprite2D) -> Rect2:
	if not sprite.is_visible_in_tree() or sprite.texture == null or sprite.self_modulate.a < 0.01:
		return Rect2()
	if "shadow" in String(sprite.name).to_lower() or "shadow" in sprite.texture.resource_path:
		return Rect2()
	var extent: Vector2 = sprite.get_rect().size
	var key: String = (
		"%d/%d/%s/%s" % [sprite.texture.get_instance_id(), sprite.frame, extent, sprite.region_rect]
	)
	if not _used.has(key):
		var id: int = sprite.texture.get_instance_id()
		if not _images.has(id):
			var image: Image = sprite.texture.get_image()
			if image.is_compressed() and image.decompress() != OK:
				return Rect2()
			_images[id] = image
		var origin: Vector2 = Vector2(sprite.frame_coords) * extent
		if sprite.region_enabled:
			origin += sprite.region_rect.position
		var cell: Image = _images[id].get_region(Rect2i(Vector2i(origin), Vector2i(extent)))
		_used[key] = Rect2(cell.get_used_rect())
	var box: Rect2 = _used[key]
	if sprite.flip_h:
		box.position.x = extent.x - box.end.x
	if sprite.flip_v:
		box.position.y = extent.y - box.end.y
	box.position += sprite.get_rect().position
	return sprite.get_global_transform_with_canvas() * box
