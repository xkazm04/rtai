extends RefCounted
## The body of dev/arena/stations_check.gd (loaded at run time, so it may name autoload users):
## every station in `dir`, its hook built or not, and its knobs resolved against this tree.


static func check(dir: String) -> Dictionary:
	var st: ArenaStations = ArenaStations.shipped(dir)
	var tuning: ArenaTuning = ArenaTuning.new(PlayerActions.shipped(), CombatTuning.shipped())
	var rows: Array[Dictionary] = []
	var problems: Array[String] = []
	## Tables a knob names that are not in this tree (another lane's branch before the merge).
	var absent: Array[String] = []
	problems.append_array(st.errors)
	for s: ArenaStation in st.stations:
		var hook: String = "none"
		if not s.script_path.is_empty():
			hook = "ok" if ArenaHook.make(s) != null else "broken"
			if hook == "broken":
				problems.append("%s: hook %s does not build" % [s.id, s.script_path])
		var unresolved: Array[String] = []
		for k: ArenaStation.Knob in s.knobs:
			var table: String = k.key.get_slice(".", 0)
			if not FileAccess.file_exists(ArenaTuning.TABLES % table):
				if not absent.has(table):
					absent.append(table)
			elif is_nan(tuning.shipped(k.key)):
				unresolved.append(k.key)
		for key: String in unresolved:
			problems.append("%s: knob %s does not resolve" % [s.id, key])
		rows.append(_row(s, hook, unresolved))
	return {
		"dir": dir,
		"count": st.stations.size(),
		"stations": rows,
		"problems": problems,
		"tables_not_in_tree": absent,
	}


static func _row(s: ArenaStation, hook: String, unresolved: Array[String]) -> Dictionary:
	var kinds: Dictionary[String, int] = {}
	for sp: ArenaStation.Spawn in s.spawns:
		kinds[sp.kind] = kinds.get(sp.kind, 0) + 1
	return {
		"id": s.id,
		"lane": s.lane,
		"area": s.area,
		"spawns": kinds,
		"props": s.props.size(),
		"knobs": s.knobs.size(),
		"unresolved_knobs": unresolved,
		"hook": hook,
	}
