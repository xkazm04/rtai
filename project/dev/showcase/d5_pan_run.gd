class_name D5PanRun
extends D5HeroRun
## d5-close: the car-camera pan shimmer test. The hero junction (d5 tier world) at 48 px/m while the
## camera pans right at PAN_MPS (a non-integer px step per tick); every tick is shot twice, without
## and with the look_d5 world layer, as a crop locked to one world region (kerb, pavement, street,
## cast shadow): <d4|d5>-walk-<tick>.png. A world-locked print adds no frame-to-frame change; any
## extra change in the d5 series is swim/shimmer (masters tools/shimmer.py compares the two).

const PAN_TICKS: int = 40
const PAN_MPS: float = 7.3
const PAN_ZOOM: float = 1.5
const ANCHOR_M: Vector2 = Vector2(8.0, -5.0)
const PAN_BOX: Vector2i = Vector2i(480, 320)

## the world-locked crop's centre (metres); --anchor in d5_pan.gd (9.7,-8.5 = the mural roof)
var anchor_m: Vector2 = ANCHOR_M


func shoot() -> int:
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	_tier("d5")
	RigDetail.enabled = false
	_frame_at(PAN_ZOOM)
	for t: int in SETTLE_TICKS:
		_pose(t)
		_rigs.step_ticks(1)
		await get_tree().process_frame
	for t: int in PAN_TICKS:
		hero_cam = (HERO_CAM_M + Vector2(PAN_MPS * SimClock.TICK_DT * t, 0.0)) * PX
		_frame_at(PAN_ZOOM)
		for d5: bool in [false, true]:
			overlay.set_shader_parameter("amount", amount_at(PAN_ZOOM) if d5 else 0.0)
			_rigs.step_ticks(0)
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			ok = _save_pan("%s-walk-%02d" % ["d5" if d5 else "d4", t]) and ok
	RigDetail.enabled = true
	return 0 if ok else 1


func _save_pan(name: String) -> bool:
	var img: Image = get_viewport().get_texture().get_image()
	if img == null or img.is_empty():
		return false
	var view: Vector2 = Vector2(img.get_size())
	var origin: Vector2 = (view * 0.5 - cam * PAN_ZOOM).round()
	var at: Vector2i = Vector2i(origin + anchor_m * PX * PAN_ZOOM)
	var r: Rect2i = Rect2i(at - PAN_BOX / 2, PAN_BOX)
	return img.get_region(r).save_png(out_dir.path_join(name + ".png")) == OK
