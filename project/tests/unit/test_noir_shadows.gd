extends GutTest

const LAMP: int = 24
const HYDRANT: int = 25
const BAR: int = 14


func _params() -> Dictionary:
	return NoirLook.read_params(NoirLook.PARAMS)


func _table() -> Dictionary:
	return CityGen.read_json(CitySystem.TEXTURES)


func test_lengths_by_name_override_the_class() -> void:
	var cfg: Dictionary = _params()["shadows"]
	var len_px: PackedFloat32Array = NoirShadows.lengths(_table(), cfg)
	assert_eq(len_px[LAMP], 0.0, "a lamp arm casts no sweep (its art prints white in its own pool)")
	assert_gt(len_px[HYDRANT], 0.0)
	assert_gt(len_px[BAR], len_px[HYDRANT], "a roof block casts longer than a kerb prop")
	assert_eq(len_px[0], 0.0, "ground tiles never cast")


func test_only_shadow_commands_with_a_length_are_swept() -> void:
	var c: CityChunk = CityChunk.new(0, 0)
	for cmd: Array in [
		[HYDRANT, 5.18, 5.18, 0.0, 1.0], [HYDRANT, 5.0, 5.0, 0.0, 0.0], [LAMP, 9.18, 9.18, 0.0, 1.0]
	]:
		var t: int = cmd[0]
		@warning_ignore("return_value_discarded")
		c.tex.append(t)
		for k: int in 4:
			var v: float = cmd[1 + k]
			@warning_ignore("return_value_discarded")
			c.xf.append(v)
	var table: Dictionary = _table()
	var root: RID = RenderingServer.canvas_item_create()
	var sh: NoirShadows = NoirShadows.new(root, CityTextures.new(table), table, _params())
	var item: RID = sh._record(c)
	var cfg: Dictionary = _params()["shadows"]
	var len_px: float = NoirShadows.lengths(table, cfg)[HYDRANT]
	assert_eq(sh.stamps, ceili(len_px / NoirShadows.STEP_PX) + 1, "one sweep: the hydrant's shadow")
	RenderingServer.free_rid(item)
	sh.dispose()
	RenderingServer.free_rid(root)
