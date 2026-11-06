class_name ReactTable
extends RefCounted
## The human reaction and death families (data/tables/human_reactions.json): each family's
## length and drawn travel, and which family a damage class (hit_feel.json ids) plays when it
## wounds (map) or kills (death_map). Lane human-reactions.

const TABLE: String = "res://data/tables/human_reactions.json"
const SCHEMA: String = "gtai.human_reactions/1"

var _len: Dictionary[StringName, float] = {}
var _travel: Dictionary[StringName, float] = {}
## snap_m (n7-ranged): how far the hit throws the body along the blow on its first frames.
var _snap: Dictionary[StringName, float] = {}
var _map: Dictionary[StringName, StringName] = {}
var _death: Dictionary[StringName, StringName] = {}
## weapon_wound: a weapon id whose wounding hit plays its own family (the plasma bolt's stagger).
var _weapon: Dictionary[StringName, StringName] = {}
var _errors: Array[String] = []


static func shipped(path: String = TABLE) -> ReactTable:
	var rt: ReactTable = ReactTable.new()
	var t: DataTable = DataTable.open(path, SCHEMA)
	for row: Variant in t.array(t.raw, "reactions"):
		var r: Dictionary = row if row is Dictionary else {}
		var id: StringName = StringName(t.text(r, "id"))
		rt._len[id] = t.num(r, "len_s")
		rt._travel[id] = t.num(r, "travel_m")
		if r.has("snap_m") and snap_on():
			rt._snap[id] = t.num(r, "snap_m")
	var m: Dictionary = t.object(t.raw, "map")
	for k: Variant in m:
		rt._map[StringName(str(k))] = StringName(str(m[k]))
	var d: Dictionary = t.object(t.raw, "death_map")
	for k: Variant in d:
		rt._death[StringName(str(k))] = StringName(str(d[k]))
	var w: Dictionary = t.object(t.raw, "weapon_wound") if t.raw.has("weapon_wound") else {}
	for k: Variant in w:
		rt._weapon[StringName(str(k))] = StringName(str(w[k]))
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


## The hit snap of `kind` (m; 0 when the family has none or `--react-snap=off`).
func snap(kind: StringName) -> float:
	return _snap.get(kind, 0.0)


static func snap_on() -> bool:
	return not OS.get_cmdline_user_args().has("--react-snap=off")


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


## The family `weapon`'s wounding hit plays over its hit class's (&"" when the class decides).
func weapon_wound(weapon: StringName) -> StringName:
	return _weapon.get(weapon, &"")


func death_for(hit_class: StringName) -> StringName:
	return _death.get(hit_class, &"death_bullet")
