extends GutTest
## TEL-03 hitch log: frames over 25 ms are recorded, attributed and written as JSONL.

var _path: String = TestTmp.dir("hitches").path_join("hitches.jsonl")


func before_each() -> void:
	if FileAccess.file_exists(_path):
		assert_eq(DirAccess.remove_absolute(_path), OK)


func test_attribution_rule() -> void:
	var base: Dictionary = {
		"wall_ms": 60.0,
		"canary_gap_ms": 1.0,
		"pipelines": 0,
		"game_ms": 1.0,
		"render_cpu_ms": 1.0,
		"render_gpu_ms": 0.5,
	}
	assert_eq(HitchRecorder.attribute(base), "unexplained")
	assert_eq(HitchRecorder.attribute(_with(base, "canary_gap_ms", 55.0)), "outside")
	assert_eq(HitchRecorder.attribute(_with(base, "pipelines", 2)), "pipeline")
	assert_eq(HitchRecorder.attribute(_with(base, "game_ms", 40.0)), "game")
	assert_eq(HitchRecorder.attribute(_with(base, "render_gpu_ms", 45.0)), "render")
	assert_eq(HitchRecorder.attribute(_with(base, "draw_ms", 40.0)), "present")


func test_only_long_frames_are_recorded_and_written() -> void:
	var rec: HitchRecorder = HitchRecorder.new()
	rec.log_path = _path
	rec.start(get_viewport().get_viewport_rid(), func() -> int: return 42)
	rec.frame(16.0, 1.0)
	rec.frame(30.0, 25.0)
	rec.stop()
	assert_eq(rec.records.size(), 1)
	var first: Dictionary = rec.records[0]
	var cause: String = first["cause"]
	var tick: int = first["tick"]
	assert_eq(cause, "game")
	assert_eq(tick, 42)
	var lines: PackedStringArray = FileAccess.get_file_as_string(_path).strip_edges().split("\n")
	assert_eq(lines.size(), 1)
	assert_string_contains(lines[0], '"cause":"game"')


func test_canary_sees_a_whole_process_gap_only_when_it_is_blocked() -> void:
	var canary: FrameCanary = FrameCanary.new()
	canary.start()
	OS.delay_msec(30)
	var gap: float = canary.take_max_gap_ms()
	canary.stop()
	assert_lt(gap, 25.0, "a busy main thread does not stop the canary thread")


static func _with(d: Dictionary, key: String, value: Variant) -> Dictionary:
	var out: Dictionary = d.duplicate()
	out[key] = value
	return out
