class_name ReactTable
extends RefCounted
## The human reaction and death families (data/tables/human_reactions.json): each family's
## length and drawn travel, and which family a damage class (hit_feel.json ids) plays when it
## wounds (map) or kills (death_map). Lane human-reactions.

const TABLE: String = "res://data/tables/human_reactions.json"
const SCHEMA: String = "gtai.human_reactions/1"

var _len: Dictionary[StringName, float] = {}
var _travel: Dictionary[StringName, float] = {}
var _map: Dictionary[StringName, StringName] = {}
var _death: Dictionary[StringName, StringName] = {}
var _errors: Array[String] = []


static func shipped(path: String = TABLE) -> ReactTable:
	var rt: ReactTable = ReactTable.new()
	var t: DataTable = DataTable.open(path, SCHEMA)
	for row: Variant in t.array(t.raw, "reactions"):
		var r: Dictionary = row if row is Dictionary else {}
		var id: StringName = StringName(t.text(r, "id"))
		rt._len[id] = t.num(r, "len_s")
		rt._travel[id] = t.num(r, "travel_m")
	var m: Dictionary = t.object(t.raw, "map")
	for k: Variant in m:
		rt._map[StringName(str(k))] = StringName(str(m[k]))
	var d: Dictionary = t.object(t.raw, "death_map")
	for k: Variant in d:
		rt._death[StringName(str(k))] = StringName(str(d[k]))
	rt._errors = t.errors()
	if not rt.ok():
		Log.error("human_reactions", str(rt._errors))
	return rt


func ok() -> bool:
	return _errors.is_empty()


func length(kind: StringName) -> float:
	return _len.get(kind, 0.3)


func travel(kind: StringName) -> float:
	return _travel.get(kind, 0.0)


## The wound family for a hit of `hit_class` arriving along `local_dir` (rig space, +x = the
## way the body faces). A front-facing shield blocks; cover ducks; melee spins from the side
## and folds from the front.
func reaction_for(
	hit_class: StringName, local_dir: Vector2, shielded: bool, in_cover: bool
) -> StringName:
	if shielded and local_dir.x < 0.0:
		return &"shield"
	if in_cover:
		return &"cover"
	var kind: StringName = _map.get(hit_class, &"flinch")
	if kind == &"spin" and absf(local_dir.y) < absf(local_dir.x):
		return &"fold"
	return kind


func death_for(hit_class: StringName) -> StringName:
	return _death.get(hit_class, &"death_bullet")
