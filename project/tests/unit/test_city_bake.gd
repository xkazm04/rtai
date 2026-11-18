extends GutTest


class CountingBake:
	extends CityBake
	var calls: int = 0
	var drift: bool = false

	func _bake_chunk(cx: int, cy: int) -> PackedByteArray:
		calls += 1
		if drift and calls > chunks * chunks:
			return "changed".to_utf8_buffer()
		return ("%d,%d" % [cx, cy]).to_utf8_buffer()


var _bake: CountingBake
var _golden: String
var _path: String


func before_each() -> void:
	_bake = CountingBake.new(CityGen.new(1, {}), 2)
	_golden = _bake.golden_text(_bake.bake())
	_bake.calls = 0
	_path = TestTmp.dir("city_bake").path_join("golden.sha256")


func _check(text: String) -> String:
	var file: FileAccess = FileAccess.open(_path, FileAccess.WRITE)
	assert_true(file.store_string(text))
	file.close()
	return _bake.check_fail_fast(_path)


func test_match_runs_both_passes() -> void:
	assert_eq(_check(_golden), "")
	assert_eq(_bake.calls, 8)


func test_first_wrong_sha_stops_at_its_chunk() -> void:
	var wrong: String = _golden.replace("1,0".sha256_text(), "wrong")
	assert_eq(_check(wrong), "GOLDEN-DIFF c_01_00.bin differs from the golden list")
	assert_eq(_bake.calls, 2)


func test_missing_golden_and_wrong_header_skip_both_passes() -> void:
	assert_true(_bake.check_fail_fast(_path + ".missing").begins_with("GOLDEN-DIFF missing"))
	assert_true(
		_check(_golden.replace("generator v", "generator x")).begins_with("GOLDEN-DIFF header")
	)
	assert_eq(_bake.calls, 0)


func test_golden_requires_exact_trailing_newline() -> void:
	assert_true(_check(_golden.trim_suffix("\n")).begins_with("GOLDEN-DIFF"))
	assert_true(_check(_golden + "\n").begins_with("GOLDEN-DIFF"))


func test_matching_first_pass_can_still_fail_determinism() -> void:
	_bake.drift = true
	assert_eq(_check(_golden), "NONDETERMINISTIC c_00_00.bin differs between two bakes")
	assert_eq(_bake.calls, 5)
