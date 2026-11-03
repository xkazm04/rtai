class_name D5CostRun
extends D5ShowcaseRun
## d5-close: GPU cost of the D5 tier. 16 full rigs (Rivet, 7 cops, 8 peds: CharacterRigs.MAX_FULL)
## on the showcase ground at 64 px/m, walking; each tier ("d4", "d5p" = + the D5 part overlays,
## "d5" = + the look_d5 world layer, "d5s" = + the hatched rig shadows, D5RigShadow, iteration 8)
## renders FRAMES frames with vsync off and the viewport's measured GPU and CPU render time is
## recorded (+ the rig shadow's per-frame script time). Writes <out>/d5-cost.json. Windowed (GPU).

const FRAMES: int = 240
const WARM: int = 30
const COST_ZOOM: float = 2.0


func _cast() -> void:
	var f: RigFeed = _rigs.feed
	f.count = 0
	for i: int in CharacterRigs.MAX_FULL:
		var kind: BodyPlan.Kind = BodyPlan.Kind.RIVET
		var look: int = RigFeed.LOOK_AUTO
		if i > 0:
			kind = BodyPlan.Kind.COP if i < 8 else BodyPlan.Kind.PED
			look = 5 + i % 2 if i < 8 else i % 4
		var at: Vector2 = Vector2(-7.5 + (i % 4) * 5.0, -4.2 + floorf(i / 4.0) * 2.8)
		@warning_ignore("return_value_discarded")
		f.put(i, i + 1, kind, at * PX, Vector2.ZERO)
		f.looks[i] = look


func _pose(_t: int) -> void:
	var f: RigFeed = _rigs.feed
	_rigs.focus = Vector2.ZERO
	for i: int in f.count:
		f.clip[i] = RigClips.Clip.NONE
		f.vel[i] = Vector2(30.0 + i * 2.0, 0.0).rotated(i * 0.7)
		f.face[i] = f.vel[i].angle()


func shoot() -> int:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var rid: RID = get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(rid, true)
	_frame_at(COST_ZOOM)
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	var report: Dictionary = {
		"adapter": RenderingServer.get_video_adapter_name(),
		"frames": FRAMES,
		"ppm": roundi(COST_ZOOM * PX),
		"tiers": {},
	}
	var tiers: Array[String] = TIERS.duplicate()
	tiers.append("d5s")
	for tier: String in tiers:
		RigDetail.enabled = tier != "d4"
		var world_on: bool = tier == "d5" or tier == "d5s"
		overlay.set_shader_parameter("amount", amount_at(COST_ZOOM) if world_on else 0.0)
		D5RigShadow.on_tier(_world, _rigs, PX, COST_ZOOM * PX, "d5" if tier == "d5s" else "off")
		report["tiers"][tier] = await _measure(rid)
		var img: Image = get_viewport().get_texture().get_image()
		ok = img.save_png(out_dir.path_join("cost-%s.png" % tier)) == OK and ok
	RigDetail.enabled = true
	report["full_rigs"] = _rigs.full_count()
	var fh: FileAccess = FileAccess.open(out_dir.path_join("d5-cost.json"), FileAccess.WRITE)
	if fh == null:
		return 1
	ok = fh.store_string(JSON.stringify(report, "  ", true)) and ok
	fh.close()
	printerr(JSON.stringify(report))
	return 0 if ok else 1


## FRAMES measured frames (after WARM) of the current tier: GPU / CPU render time + the rig
## shadow's script time per frame.
func _measure(rid: RID) -> Dictionary:
	D5RigShadow.sync_usec = 0
	var gpu: PackedFloat32Array = PackedFloat32Array()
	var cpu: PackedFloat32Array = PackedFloat32Array()
	for k: int in FRAMES + WARM:
		_pose(k)
		_rigs.step_ticks(1)
		await RenderingServer.frame_post_draw
		if k >= WARM:
			@warning_ignore("return_value_discarded")
			gpu.append(RenderingServer.viewport_get_measured_render_time_gpu(rid))
			@warning_ignore("return_value_discarded")
			cpu.append(RenderingServer.viewport_get_measured_render_time_cpu(rid))
	return {
		"gpu_ms": _stats(gpu),
		"cpu_ms": _stats(cpu),
		"shadow_sync_ms": D5RigShadow.sync_usec / 1000.0 / (FRAMES + WARM),
	}


static func _stats(v: PackedFloat32Array) -> Dictionary:
	v.sort()
	var n: int = v.size()
	var sum: float = 0.0
	for x: float in v:
		sum += x
	return {"mean": sum / n, "median": v[n / 2], "p95": v[mini(n - 1, n * 95 / 100)]}
