extends "owner_take.gd"
## Capture the owner's real arena swing at four simulation ages. The riot gets the
## follow-up press while the shield is open. Store unscaled viewport crops.

const AGES: Array[int] = [0, 10, 30, 60]
const CROP: Rect2i = Rect2i(770, 315, 510, 320)
const CLOSE_CROP: Rect2i = Rect2i(770, 315, 710, 340)

var written: int = 0


func _followup(i: int) -> int:
	return 32 if i == 1 else -1


func _capture() -> void:
	var tick: int = session.tick()
	if last_frame == tick:
		return
	last_frame = tick
	for row: Dictionary in observations:
		if not row.has("kill_tick"):
			continue
		var killed: int = row["kill_tick"]
		var age: int = tick - killed
		if age not in AGES:
			continue
		var im: Image = get_viewport().get_texture().get_image()
		var path: String = "%s/%s-plus%02d.png" % [destination, row.victim, age]
		var crop: Rect2i = CLOSE_CROP if ArenaArgs.parse().text("--ppm") == "64" else CROP
		if im.get_size() != Vector2i(1920, 1080) or im.get_region(crop).save_png(path) != OK:
			Log.error("claw_rake_stills", "could not save " + path)
			get_tree().quit(1)
			return
		written += 1


func _finish() -> void:
	if written != HUMAN.size() * AGES.size():
		Log.error("claw_rake_stills", "captured %d of 20 frames: %s" % [written, observations])
		get_tree().quit(1)
		return
	super()
