extends Node
## node tools/dev/run.mjs crowd_contact_cost --windowed --out=<json> --result=<json>

const KNOWN_FLAGS: PackedStringArray = ["--out"]
const NEEDS_WINDOW: bool = true
const FIXED_FPS: int = 60
const SETTLE: int = 12  # Discard switch/setup and in-flight viewport timestamps.
const FRAMES: int = 60

var _fixture: ContactCostCity
var _instances := PackedInt32Array([0, 0, 0])
var _native := ContactCostMetric.new()
var _ref := ContactCostMetric.new()
var _cpu := ContactCostMetric.new()
var _gpu := ContactCostMetric.new()
var _orders: Array[PackedInt32Array] = []
var _vp: RID
var _start_count: int


func _ready() -> void:
	var path: String = ArenaArgs.parse().text("--out")
	if path.is_empty():
		printerr("crowd_contact_cost: requires --out=<json path>")
		get_tree().quit(2)
		return
	Engine.max_fps = 0
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_window().size = Vector2i(1920, 1080)
	ViewMode.select("tilt70")
	ViewMode.shared().crowd_contact_hip_scale = 1.0  # Capture the ring arm at bake time.
	_start_count = _other_godots()
	if _start_count < 0:
		printerr("crowd_contact_cost: process census failed or missing --fixed-fps 60")
		get_tree().quit(2)
		return
	_vp = get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(_vp, true)
	_fixture = ContactCostCity.new()
	add_child(_fixture)
	if not await _fixture.prepare():
		printerr("crowd_contact_cost: native contact bake, heat, chunks or snapshot parity failed")
		get_tree().quit(1)
		return
	for reference: bool in [false, true]:
		if not await _measure(reference):
			get_tree().quit(1)
			return
	get_tree().quit(0 if _save(path) else 1)


func _measure(reference: bool) -> bool:
	var writer: CitySimBackend = _fixture.reference.sim if reference else _fixture.city.sim
	# Reference setup can leave the GPU idle. Exercise both draws and this writer before round 1.
	for arm: int in 3:
		_fixture.switch(writer, arm != 1)
		if not await _block(writer, arm, reference, false):
			return false
	for r: int in ContactCostMetric.ROUNDS:
		var order := PackedInt32Array()
		for i: int in 3:
			var arm: int = (r + i) % 3 if r % 6 < 3 else posmod(r - i, 3)
			@warning_ignore("return_value_discarded")
			order.append(arm)
			_fixture.switch(writer, arm != 1)
			if not await _block(writer, arm, reference, true):
				return false
		if not reference:
			_orders.append(order)
	return _instances[0] == _instances[2] and _instances[1] > _instances[0]


func _block(writer: CitySimBackend, arm: int, reference: bool, record: bool) -> bool:
	var writes := PackedFloat64Array()
	var cpu := PackedFloat64Array()
	var gpu := PackedFloat64Array()
	var bounds: Rect2 = _fixture.bounds
	for frame: int in SETTLE + FRAMES:
		await get_tree().process_frame
		var start: int = Time.get_ticks_usec()
		writer.write_render(bounds.position.x, bounds.position.y, bounds.end.x, bounds.end.y)
		var ms: float = (Time.get_ticks_usec() - start) * 0.001
		if not record or frame < SETTLE:
			continue
		var count: int = writer.get_render_counts()[SimConst.RL_PED_SHADOWS]
		if _instances[arm] == 0:
			_instances[arm] = count
		if count < 32 or count != _instances[arm]:
			printerr("crowd_contact_cost: sparse or inconsistent shadow count ", count)
			return false
		@warning_ignore("return_value_discarded")
		writes.append(ms)
		if not reference:
			@warning_ignore("return_value_discarded")
			cpu.append(RenderingServer.viewport_get_measured_render_time_cpu(_vp))
			@warning_ignore("return_value_discarded")
			gpu.append(RenderingServer.viewport_get_measured_render_time_gpu(_vp))
	if not record:
		return true
	if reference:
		_ref.add_block(arm, writes)
	else:
		if cpu.count(0.0) > 0 or gpu.count(0.0) > 0:
			printerr("crowd_contact_cost: missing viewport timestamp")
			return false
		_native.add_block(arm, writes)
		_cpu.add_block(arm, cpu)
		_gpu.add_block(arm, gpu)
	return true


func _save(path: String) -> bool:
	var end_count: int = _other_godots()
	if mini(_start_count, end_count) < 0:
		printerr("crowd_contact_cost: failed process census")
		return false
	var result: Dictionary = {
		"other_godots_start": _start_count,
		"other_godots_end": end_count,
		"contended": maxi(_start_count, end_count) > 0,
		"arms": ContactCostMetric.ARMS,
		"order_per_round": _orders,
		"frames_per_block": FRAMES,
		"warmup_blocks_per_backend": 3,
		"discard_per_block": SETTLE,
		"shadow_instances": _instances,
		"method":
		"Paired 10% trimmed block means; Student t CI95; floor = p95(abs(ON - ON repeat)).",
		"native_writer": _native.result(_instances),
		"reference_writer": _ref.result(_instances),
		"viewport_cpu": _cpu.result(_instances),
		"viewport_gpu": _gpu.result(_instances),
	}
	result.merge(_settings())
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	return file != null and file.store_string(JSON.stringify(result, "  ", true, true))


func _settings() -> Dictionary:
	return {
		"schema": "gtai.bench/1",
		"scenario": "crowd_contact_cost",
		"seed": _fixture.SEED,
		"tick": _fixture.TICKS,
		"world_digest": _fixture.snapshot_hash,
		"heat": _fixture.city.sim.heat_level(),
		"camera_m": [_fixture.city.focus.x, _fixture.city.focus.y],
		"ppm": _fixture.view.zoom * SimConst.PX_PER_M,
		"pitch": ViewMode.shared().pitch_deg,
		"viewport_px":
		[get_viewport().get_visible_rect().size.x, get_viewport().get_visible_rect().size.y],
		"driver": RenderingServer.get_current_rendering_driver_name(),
		"gpu": RenderingServer.get_video_adapter_name(),
		"cpu": OS.get_processor_name(),
		"debug_build": OS.is_debug_build(),
		"backend": _fixture.city.sim.backend_name(),
		"vsync_mode": DisplayServer.window_get_vsync_mode(),
		"fixed_fps": FIXED_FPS,
	}


## Same Windows process names as the bench ledger. Exclude this engine and its console parent.
static func _other_godots() -> int:
	var query: String = (
		"$ErrorActionPreference='Stop'; $own=Get-CimInstance Win32_Process "
		+ "-Filter 'ProcessId=%d'; " % OS.get_process_id()
		+ "$cmd=$own.CommandLine -replace [char]34,' '; "
		+ "if (($cmd -split '\\s--\\s')[0] -notmatch '\\s--fixed-fps\\s+60(\\s|$)') {exit 2}; "
		+ "$p=Get-Process -Name Godot*,RTAI-bench -ErrorAction SilentlyContinue; "
		+ "@($p | Where-Object { $_.Id -ne $own.ProcessId "
		+ "-and $_.Id -ne $own.ParentProcessId }).Count"
	)
	var lines: Array = []
	var code: int = OS.execute("powershell", ["-NoProfile", "-Command", query], lines)
	var value: String = "".join(lines).strip_edges()
	return value.to_int() if code == 0 and value.is_valid_int() else -1
