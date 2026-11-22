class_name BotProfile
extends RefCounted
## One skill row plus the shared threat and bonus values for this run.

const TABLE: String = "res://data/tables/test_player.json"
const SCHEMA: String = "gtai.test_player/1"

var id: StringName
var reaction_ticks: int
var rest_hp: float
var retreat_hp: float
var aim_error_deg: float
var tells_read: float
var guard_lead_ticks: int
var roll_skill: float
var blast_margin_m: float
var cover_seek_m: float
var move_use: float
var form_use: float
var large_tell_bonus: float
var threat_weights: Dictionary[StringName, float] = {}
var _pick_values: Dictionary = {}


static func shipped(profile_id: StringName) -> BotProfile:
	var table: DataTable = DataTable.open(TABLE, SCHEMA)
	for row: Dictionary in table.array(table.raw, "rows"):
		if StringName(table.text(row, "id")) != profile_id:
			continue
		var profile: BotProfile = BotProfile.new()
		profile.id = profile_id
		profile.reaction_ticks = table.integer(row, "reaction_ticks")
		profile.rest_hp = table.num(row, "rest_hp")
		profile.retreat_hp = table.num(row, "retreat_hp")
		profile.aim_error_deg = table.num(row, "aim_error_deg")
		profile.tells_read = table.num(row, "tells_read")
		profile.guard_lead_ticks = table.integer(row, "guard_lead_ticks")
		profile.roll_skill = table.num(row, "roll_skill")
		profile.blast_margin_m = table.num(row, "blast_margin_m")
		profile.cover_seek_m = table.num(row, "cover_seek_m")
		profile.move_use = table.num(row, "move_use")
		profile.form_use = table.num(row, "form_use")
		profile.large_tell_bonus = table.num(table.raw, "large_tell_bonus")
		profile._pick_values = table.object(table.raw, "pick_values")
		profile.threat_weights.assign(table.object(table.raw, "threat_weights"))
		return profile if table.ok() else null
	return null


func pick_value(kind: StringName, ref: StringName) -> float:
	var values: Dictionary = _pick_values.get(kind, {})
	var refs: Dictionary = values.get("refs", {})
	var base: float = values.get("base", 0.0)
	var extra: float = refs.get(ref, 0.0)
	return base + extra
