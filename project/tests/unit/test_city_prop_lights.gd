extends GutTest
## Street lamps at night (features/city/view/city_prop_lights.gd): a lamp_post command in a resident
## chunk holds one light at its head on a listed grade, none by day; its baked shadow command and
## other props carry none; lamps beyond the radius stay dark.


func _residency() -> CityResidency:
	var sim: CitySimRef = CitySimRef.new()
	var res: CityResidency = CityResidency.new(null, sim, SimConst.CITY_CHUNKS)
	var chunk: CityChunk = CityChunk.new(0, 0)
	chunk.tiles = CityChunk.zeros(SimConst.CHUNK_TILES * SimConst.CHUNK_TILES)
	chunk.cells = CityChunk.zeros(SimConst.CHUNK_CELLS * SimConst.CHUNK_CELLS)
	var lamp: int = _tex_id("lamp_post")
	var hydrant: int = _tex_id("fire_hydrant")
	for cmd: Array in [
		[lamp, 10.0, 10.0, 0.0, 0.0],
		[lamp, 10.2, 10.2, 0.0, 1.0],
		[hydrant, 12.0, 10.0, 0.0, 0.0],
		[lamp, 120.0, 120.0, 0.0, 0.0]
	]:
		var t: int = cmd[0]
		@warning_ignore("return_value_discarded")
		chunk.tex.push_back(t)
		for k: int in 4:
			var v: float = cmd[1 + k]
			@warning_ignore("return_value_discarded")
			chunk.xf.push_back(v)
	res.adopt(Vector2i(0, 0), chunk)
	return res


func _tex_id(tex_name: String) -> int:
	var table: Dictionary = CityGen.read_json(CitySystem.TEXTURES)
	var rows: Array = table["textures"]
	for row: Dictionary in rows:
		if row["name"] == tex_name:
			var id: float = row["id"]
			return int(id)
	return -1


func test_night_lights_the_lamp_head_only() -> void:
	var layer: LightLayer = autofree(LightLayer.new())
	var lamps: CityPropLights = CityPropLights.new(layer, CityGen.read_json(CitySystem.TEXTURES))
	var res: CityResidency = _residency()
	lamps.update(res, Vector2(10, 10), 5)
	assert_eq(lamps.held, 0, "day: none")
	layer.set_grade(&"night")
	lamps.update(res, Vector2(10, 10), 6)
	assert_eq(lamps.held, 1, "one lamp: not its shadow command, not the hydrant, not the far lamp")
	layer.step(6, Vector2.ZERO)
	assert_eq(layer.active, 1)
	layer.set_grade(&"day")
	lamps.update(res, Vector2(10, 10), 7)
	assert_eq(lamps.held, 0, "day releases it")
	layer.step(7, Vector2.ZERO)
	assert_eq(layer.active, 0)
