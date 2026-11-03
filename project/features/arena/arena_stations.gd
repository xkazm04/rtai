class_name ArenaStations
extends RefCounted
## Every station file under data/tables/arena_stations/ (one per lane, gtai.arena-station/1),
## read in file-name order so the arena builds the same way on every machine. A lane adds a
## station by adding its file; a broken file is reported and skipped, never fatal.

const DIR: String = "res://data/tables/arena_stations"
const SCHEMA: String = "gtai.arena-station/1"

var stations: Array[ArenaStation] = []
var errors: Array[String] = []


static func shipped(dir: String = DIR) -> ArenaStations:
	var out: ArenaStations = ArenaStations.new()
	var files: PackedStringArray = DirAccess.get_files_at(dir)
	files.sort()
	for f: String in files:
		if f.get_extension() == "json":
			out.add_file("%s/%s" % [dir, f])
	return out


func add_file(path: String) -> void:
	add_text(FileAccess.get_file_as_string(path), path.get_file())


func add_text(json: String, file_name: String) -> void:
	var t: DataTable = DataTable.parse(json, SCHEMA, file_name)
	var lane: String = t.text(t.raw, "lane")
	var found: Array[ArenaStation] = []
	for v: Variant in t.array(t.raw, "stations"):
		var row: Dictionary = v if v is Dictionary else {}
		found.append(ArenaStation.from_row(t, row, lane))
	if not t.ok():
		errors.append_array(t.errors())
		Log.warn("arena", "station file skipped: %s" % [t.errors()])
		return
	stations.append_array(found)


func by_id(id: String) -> ArenaStation:
	for s: ArenaStation in stations:
		if s.id == id:
			return s
	return null


func in_area(area: String) -> Array[ArenaStation]:
	var out: Array[ArenaStation] = []
	for s: ArenaStation in stations:
		if s.area == area:
			out.append(s)
	return out
