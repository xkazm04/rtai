class_name NoirShowcaseShots
extends RefCounted
## The showcase fight's hero-frame saving and world -> screen uv (lane noir, dev only).


## Saves the frame being drawn as show-<look>-<ppm>ppm-f<f>-<tag>.png in the --out folder.
static func save(vp: Viewport, a: NoirShowcaseArgs, f: int, tag: String) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = vp.get_texture().get_image()
	var ppm: int = roundi(a.zoom * SimConst.PX_PER_M)
	var look: String = "d4" if a.d4 else "noir"
	var file: String = "show-%s-%dppm-f%03d-%s.png" % [look, ppm, f, tag]
	if img.save_png(a.out.path_join(file)) != OK:
		printerr("showcase_fight: frame %d not saved" % f)


## A world pixel as a screen uv under a camera at `cam` with `zoom`.
static func to_uv(vp: Viewport, cam: Vector2, zoom: float, px: Vector2) -> Vector2:
	var view: Vector2 = vp.get_visible_rect().size
	return ((px - cam) * zoom + view * 0.5) / view
