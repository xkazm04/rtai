extends Scenario
## AST-12 in the scenario suite: bake every chunk of the district twice, byte-compare, and
## compare with the committed golden hash list (data/generated/city_chunks.sha256).


func run(_tree: SceneTree) -> String:
	var gen: CityGen = CityGen.from_tables(CitySystem.DISTRICT, CitySystem.TEXTURES)
	if gen == null:
		return "district or texture table does not load"
	return CityBake.new(gen, SimConst.CITY_CHUNKS).check()
