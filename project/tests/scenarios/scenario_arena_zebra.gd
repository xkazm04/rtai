extends Scenario
## Compare the city's generated decal draw list with the actual stage collision boxes.


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = ArenaSession.open(Events, Data, ArenaSession.MASTER_SEED, null, true)
	var walls: ArenaWalls = s.stage.walls
	var bounds: Rect2 = Rect2(s.plan.base, Vector2.ZERO)
	for box: Rect2 in walls.boxes:
		bounds = bounds.merge(box)
	# Plant the fault at the same city hub using the unshifted, flat-floor station rows.
	var shared: ArenaStations = ArenaStations.shipped()
	var planted: ArenaWalls = ArenaWalls.from_stations(shared, s.plan.base)
	for box: Rect2 in planted.boxes:
		bounds = bounds.merge(box)
	var zebras: Array[Rect2] = _crossings(bounds)
	var issues: Array[String] = _inspect(s.stations, walls, zebras)
	var fault: Array[String] = _inspect(shared, planted, zebras)
	var doors: String = _check_openings(shared.by_id("pit"), s.stations.by_id("pit"))
	s.close()
	if not issues.is_empty():
		return "\n".join(issues)
	if zebras.is_empty() or walls.boxes.is_empty() or fault.is_empty():
		return "no zebra, no walls, or removing the city shifts escaped the overlap check"
	var counts: Array = [walls.boxes.size(), zebras.size(), fault.size()]
	printerr("zebra_walls: 0 overlaps (%d boxes, %d decals); unshifted: %d" % counts)
	return doors


static func _inspect(
	stations: ArenaStations, walls: ArenaWalls, zebras: Array[Rect2]
) -> Array[String]:
	var issues: Array[String] = stations.errors.duplicate()
	var index: int = 0
	for station: ArenaStation in stations.stations:
		for i: int in station.props.size():
			if station.props[i].kind not in ArenaWalls.SOLID:
				continue
			if index >= walls.boxes.size():
				issues.append("missing collision box for %s/%d" % [station.id, i])
				return issues
			for zebra: Rect2 in zebras:
				var overlap: Rect2 = walls.boxes[index].intersection(zebra)
				if overlap.has_area():
					var fields: Array = [station.id, i, zebra.get_center(), overlap.get_area()]
					issues.append("%s/%d zebra %s overlap %.3f m2" % fields)
			index += 1
	if index != walls.boxes.size():
		issues.append("unidentified station collision boxes")
	return issues


## The three north wall segments and the two door markers translate as a single row.
static func _check_openings(shared: ArenaStation, city: ArenaStation) -> String:
	var shift: Vector2 = city.props[0].at - shared.props[0].at
	for i: int in 5:
		var original: ArenaStation.Prop = shared.props[i]
		if city.props[i].at != original.at + shift or city.props[i].size != original.size:
			return "pit/%d changed the north wall openings" % i
	return ""


static func _crossings(bounds: Rect2) -> Array[Rect2]:
	var gen: CityGen = CityGen.from_tables(CitySystem.DISTRICT, CitySystem.TEXTURES)
	var size_m: Vector2 = gen.sizes[TilePainter.T_ZEBRA]
	# Include decals centred in a neighbouring chunk that reach into these boxes.
	var reach: Rect2 = bounds.grow(size_m.length() * 0.5)
	var lo: Vector2i = Vector2i((reach.position / SimConst.CHUNK_M).floor())
	var hi: Vector2i = Vector2i((reach.end / SimConst.CHUNK_M).floor())
	var zebras: Array[Rect2] = []
	for y: int in range(maxi(lo.y, 0), mini(hi.y + 1, SimConst.CITY_CHUNKS)):
		for x: int in range(maxi(lo.x, 0), mini(hi.x + 1, SimConst.CITY_CHUNKS)):
			var chunk: CityChunk = gen.gen_chunk(x, y)
			for i: int in chunk.command_count():
				if chunk.tex[i] == TilePainter.T_ZEBRA:
					var j: int = i * CityChunk.XF_STRIDE
					var at: Vector2 = Vector2(chunk.xf[j], chunk.xf[j + 1])
					var xf: Transform2D = Transform2D(chunk.xf[j + 2], at)
					var zebra: Rect2 = xf * Rect2(-0.5 * size_m, size_m)
					if bounds.intersects(zebra):
						zebras.append(zebra)
	return zebras
