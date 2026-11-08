extends GutTest
## n9-perf: what ships reads a SubViewport back through CrowdReadback (texture_get_data_async)
## only, never a synchronous `get_texture().get_image()` (a GPU flush-and-wait on the main
## thread; F-19 was first caught parked inside one). The scan fails on the old code
## (crowd_baker.gd held the call); image_of is the async path's byte -> Image step.

const SHIPPED: Array[String] = ["res://boot", "res://core", "res://features"]
const SYNC_READ: String = "get_texture().get_image()"
## the one sanctioned call: CrowdReadback's `--crowd-readback=sync` A/B arm
const ALLOWED: Array[String] = ["res://features/characters/crowd_readback.gd"]


func test_no_shipped_script_reads_a_viewport_back_synchronously() -> void:
	var hits: Array[String] = []
	for root: String in SHIPPED:
		_scan(root, hits)
	assert_eq(hits, [] as Array[String], "synchronous viewport readbacks (main-thread GPU stall)")


func test_rgba8_bytes_become_the_same_pixels() -> void:
	var src: Image = Image.create_empty(3, 2, false, Image.FORMAT_RGBA8)
	src.fill(Color(0.2, 0.4, 0.6, 0.8))
	src.set_pixel(1, 1, Color(1.0, 0.0, 0.0, 1.0))
	var size: Vector2i = Vector2i(3, 2)
	for fmt: RenderingDevice.DataFormat in [
		RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM, RenderingDevice.DATA_FORMAT_R8G8B8A8_SRGB
	]:
		var img: Image = CrowdReadback.image_of(src.get_data(), size, fmt)
		assert_not_null(img)
		if img != null:
			assert_eq(img.get_data(), src.get_data())
			assert_eq(img.get_format(), Image.FORMAT_RGBA8)


func test_short_or_unknown_data_is_null_not_garbage() -> void:
	var size: Vector2i = Vector2i(4, 4)
	var short: PackedByteArray = PackedByteArray()
	var grew: int = short.resize(10)
	var rgba: RenderingDevice.DataFormat = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	assert_null(CrowdReadback.image_of(short, size, rgba))
	var full: PackedByteArray = PackedByteArray()
	grew = full.resize(64)
	assert_null(CrowdReadback.image_of(full, size, RenderingDevice.DATA_FORMAT_R8_UNORM))
	assert_null(CrowdReadback.image_of(PackedByteArray(), Vector2i.ZERO, rgba))
	assert_eq(grew, OK)


func test_async_is_the_default_and_sync_is_one_flag_away() -> void:
	assert_true(CrowdReadback.async_on(), "no --crowd-readback flag: async")
	assert_true(LaunchArgs.KNOWN_FLAGS.has("--crowd-readback"))


func _scan(dir: String, hits: Array[String]) -> void:
	for sub: String in DirAccess.get_directories_at(dir):
		_scan(dir.path_join(sub), hits)
	for file: String in DirAccess.get_files_at(dir):
		if not file.ends_with(".gd"):
			continue
		var path: String = dir.path_join(file)
		var text: String = FileAccess.get_file_as_string(path)
		if text.contains(SYNC_READ) and not ALLOWED.has(path):
			hits.append(path)
