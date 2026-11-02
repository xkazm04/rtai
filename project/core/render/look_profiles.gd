class_name LookProfiles
extends RefCounted
## Look profiles as data (data/tables/look_profiles.json, gtai.look-profiles/1): every print-pass
## parameter per art direction (D1, D4, D5), a zoom-driven blend (D4 at gameplay zoom toward D5
## at arena zoom) and the --look= ids. resolve() returns a LookParams for an id at a px/m;
## views push it into their materials with LookParams.apply(). Render only.

const TABLE: String = "res://data/tables/look_profiles.json"
const SCHEMA: String = "gtai.look-profiles/1"
## The zoom-driven blend (the default) and the raw art (no print pass).
const AUTO: StringName = &"auto"
const OFF: StringName = &"off"

static var _shared: LookProfiles = null

var default_id: StringName = AUTO
var blend_from: StringName = &"d4"
var blend_to: StringName = &"d4"
var start_ppm: float = 48.0
var full_ppm: float = 64.0
var profiles: Dictionary[StringName, LookParams] = {}


static func shared() -> LookProfiles:
	if _shared == null:
		_shared = LookProfiles.from_json(FileAccess.get_file_as_string(TABLE))
	return _shared


static func from_json(text: String) -> LookProfiles:
	var out: LookProfiles = LookProfiles.new()
	var parser: JSON = JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		return out
	var d: Dictionary = parser.data
	if d.get("schema", "") != SCHEMA:
		return out
	var def: String = d["default"]
	out.default_id = StringName(def)
	var b: Dictionary = d["zoom_blend"]
	var bf: String = b["from"]
	var bt: String = b["to"]
	out.blend_from = StringName(bf)
	out.blend_to = StringName(bt)
	out.start_ppm = b["start_ppm"]
	out.full_ppm = b["full_ppm"]
	for row: Dictionary in d["profiles"]:
		var pid: String = row["id"]
		out.profiles[StringName(pid)] = LookParams.from_row(row)
	return out


## Every id --look= accepts: the profiles, `auto` and `off`.
func ids() -> Array[StringName]:
	var out: Array[StringName] = [AUTO, OFF]
	out.append_array(profiles.keys())
	return out


func has(id: StringName) -> bool:
	return id == AUTO or id == OFF or profiles.has(id)


## The parameters of `id` seen at `ppm` screen px per metre. `auto` blends blend_from ->
## blend_to between start_ppm and full_ppm; an unknown id falls back to the default.
func resolve(id: StringName, ppm: float) -> LookParams:
	if id == OFF:
		var off: LookParams = profiles[blend_from].duplicate_params()
		off.printed = false
		return off
	if profiles.has(id):
		return profiles[id]
	if id != AUTO and default_id != AUTO and profiles.has(default_id):
		return profiles[default_id]
	return LookParams.lerp_params(profiles[blend_from], profiles[blend_to], blend_weight(ppm))


## 0 at or below start_ppm, 1 at or above full_ppm, smooth between (no visible step on a zoom).
func blend_weight(ppm: float) -> float:
	if full_ppm <= start_ppm:
		return 1.0 if ppm >= full_ppm else 0.0
	return smoothstep(start_ppm, full_ppm, ppm)
