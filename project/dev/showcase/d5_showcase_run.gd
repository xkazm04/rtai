class_name D5ShowcaseRun
extends RigShowcaseRun
## d5-close evidence: the F-09b cast (Rivet, two cops, peds on D4 pavement and asphalt) at 32, 48,
## 64 and 96 px/m, each zoom shot twice from the SAME pose: D4 parts (RigDetail.enabled = false)
## and the D5 detail tier, plus 54 / 56 px/m around the tier switch.
## Writes <out>/<tier>-<ppm>ppm.png
## and a Rivet crop <tier>-<ppm>ppm-rivet.png. Windowed only (needs a GPU).

const D5_ZOOMS: Array[float] = [1.0, 1.5, 1.6875, 1.75, 2.0, 3.0]
const RIVET_BOX_M: Vector2 = Vector2(3.6, 3.6)

## Optional look_d5 overlay layer (above the world print, below the actors); null = none.
var overlay: ShaderMaterial = null


func shoot() -> int:
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	for z: float in D5_ZOOMS:
		_frame(z)
		if overlay != null:
			overlay.set_shader_parameter("zoom", z)
		for t: int in SETTLE_TICKS:
			_pose(t)
			_rigs.step_ticks(1)
			await get_tree().process_frame
		for d5: bool in [false, true]:
			RigDetail.enabled = d5
			_rigs.step_ticks(0)
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			ok = _save_d5("%s-%dppm" % ["d5" if d5 else "d4", roundi(z * PX)], z) and ok
	RigDetail.enabled = true
	return 0 if ok else 1


func _save_d5(name: String, z: float) -> bool:
	var img: Image = get_viewport().get_texture().get_image()
	if img == null or img.is_empty():
		return false
	var ok: bool = img.save_png(out_dir.path_join(name + ".png")) == OK
	var view: Vector2 = Vector2(img.get_size())
	var at: Vector2 = view * 0.5 + _rigs.feed.pos[0] * z
	var size: Vector2 = RIVET_BOX_M * PX * z
	var r: Rect2i = Rect2i(Vector2i(at - size * 0.5), Vector2i(size)).intersection(
		Rect2i(Vector2i.ZERO, img.get_size())
	)
	var crop: Image = img.get_region(r)
	var k: int = maxi(1, roundi(360.0 / maxf(1.0, float(r.size.y))))
	crop.resize(r.size.x * k, r.size.y * k, Image.INTERPOLATE_NEAREST)
	return crop.save_png(out_dir.path_join(name + "-rivet.png")) == OK and ok
