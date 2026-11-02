extends RigShowcaseRun
## LOD motion strip: Rivet and 15 walking pedestrians on the pavement, ranked by distance (the
## centre ones full rate, then half, the outer ones quarter rate), captured on STRIP consecutive
## ticks at 32 and 48 px/m. Writes <out>/motion-<ppm>.png: one row per tick, the pavement
## band (x -8.5 .. 8.5 m, y -4.3 .. -1.3 m), 2x nearest. Windowed only (needs a GPU).
## Launch: rig_showcase.gd -- --motion.

const STRIP: int = 24
const PEDS: int = 15
const BAND_LO: Vector2 = Vector2(-8.5, -4.3)
const BAND_SIZE: Vector2 = Vector2(17.0, 3.0)


func shoot() -> int:
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	for z: float in ZOOMS:
		_frame(z)
		_cast()
		for t: int in SETTLE_TICKS:
			_tick(t)
			await get_tree().process_frame
		var rows: Array[Image] = []
		for t: int in STRIP:
			_tick(SETTLE_TICKS + t)
			await RenderingServer.frame_post_draw
			rows.append(_band(z))
		ok = (
			_stack(rows).save_png(out_dir.path_join("motion-%dppm.png" % roundi(z * PX))) == OK
			and ok
		)
	return 0 if ok else 1


func _tick(t: int) -> void:
	_pose(t)
	_rigs.step_ticks(1)


func _cast() -> void:
	var f: RigFeed = _rigs.feed
	f.count = 0
	@warning_ignore("return_value_discarded")
	f.put(0, 1, BodyPlan.Kind.RIVET, Vector2(0.0, -0.6) * PX, Vector2.ZERO)
	f.looks[0] = RigFeed.LOOK_AUTO
	for k: int in PEDS:
		var side: float = -1.0 if k % 2 == 0 else 1.0
		var at: Vector2 = Vector2(side * (0.9 + 1.0 * (k / 2)), -2.8) * PX
		@warning_ignore("return_value_discarded")
		f.put(k + 1, k + 2, BodyPlan.Kind.PED, at, Vector2.ZERO)
		f.looks[k + 1] = k % 4


## Peds walk along the pavement at 1.2 .. 1.9 m/s and turn back every 1.5 s; every other one
## swings its heading by 0.5 rad every 0.75 s (a turn for the facing spring).
func _pose(t: int) -> void:
	var f: RigFeed = _rigs.feed
	_rigs.focus = f.pos[0]
	for i: int in range(1, f.count):
		f.clip[i] = RigClips.Clip.NONE
		var swing: float = 0.0 if i % 2 == 0 or (t / 45) % 2 == 0 else 0.5
		var back: float = 0.0 if (t / 90) % 2 == 0 else PI
		f.vel[i] = Vector2.from_angle(back + swing) * (38.0 + i * 1.5)
		f.face[i] = f.vel[i].angle()
		f.pos[i] += f.vel[i] * SimClock.TICK_DT


func _band(z: float) -> Image:
	var img: Image = get_viewport().get_texture().get_image()
	var view: Vector2 = Vector2(img.get_size())
	var r: Rect2i = (
		Rect2i(Vector2i(view * 0.5 + BAND_LO * PX * z), Vector2i(BAND_SIZE * PX * z))
		. intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	)
	return img.get_region(r)


func _stack(rows: Array[Image]) -> Image:
	var w: int = rows[0].get_width()
	var h: int = rows[0].get_height()
	var out: Image = Image.create(w, h * rows.size(), false, rows[0].get_format())
	for k: int in rows.size():
		out.blit_rect(rows[k], Rect2i(0, 0, w, h), Vector2i(0, k * h))
	out.resize(w * 2, h * rows.size() * 2, Image.INTERPOLATE_NEAREST)
	return out
