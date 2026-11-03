extends SceneTree
## Headless A/B of squad.aim_lead over many seeds: the three-pairs staging of the rig fight clips,
## the human-like PitDummy (react 15 ticks, reads 70 % of tells, 4 deg aim error), no render.
## Usage: <godot> --headless --path project -s res://dev/enemy_ai/aim_lead_ab.gd
##   -- [--seeds=20] [--seconds=25] [--read=0.7 (tells read)] [--salt=1|0] [--out=<json>]

const SPOTS: Array[Vector2] = [
	Vector2(9, -6),
	Vector2(-1, 2.5),
	Vector2(16, 5),
	Vector2(15, -3),
	Vector2(19, -10),
	Vector2(19, 9)
]
const LEADS: Array[float] = [0.0, 0.8]

var _read: float = 0.7
var _salt: bool = true


func _initialize() -> void:
	var seeds: int = 20
	var seconds: float = 25.0
	var out: String = ""
	for a: String in OS.get_cmdline_user_args():
		var key: String = a.get_slice("=", 0).trim_prefix("--")
		var val: String = a.get_slice("=", 1)
		match key:
			"seeds":
				seeds = int(val)
			"seconds":
				seconds = float(val)
			"read":
				_read = float(val)
			"salt":
				_salt = val != "0"
			"out":
				out = val
			_:
				printerr("aim_lead_ab: unknown argument %s" % a)
				quit(2)
				return
	var report: Dictionary = {
		"schema": "gtai.aim-lead-ab/1",
		"seeds": seeds,
		"seconds": seconds,
		"read": _read,
		"read_salt_by_seed": _salt
	}
	for lead: float in LEADS:
		report["lead_%.1f" % lead] = _sum(lead, seeds, roundi(seconds * 60.0))
	var text: String = JSON.stringify(report, "  ", true)
	printerr(text)
	if out != "":
		var f: FileAccess = FileAccess.open(out, FileAccess.WRITE)
		if f != null:
			@warning_ignore("return_value_discarded")
			f.store_string(text + "\n")
			f.close()
	quit(0)


func _sum(lead: float, seeds: int, ticks: int) -> Dictionary:
	var keys: Array[String] = ["shots", "shot_hits", "swings", "swing_hits"]
	var tot: Dictionary[String, float] = {}
	for k: String in keys:
		tot[k] = 0.0
	var damage: float = 0.0
	for s: int in seeds:
		var pit: Object = _fight(31 + s, lead, ticks)
		var st: Dictionary = pit.get("stats")
		for k: String in keys:
			var v: float = st.get(k, 0.0)
			tot[k] += v
		var hp: float = pit.get("rivet_hp")
		damage += 400.0 - hp
	tot["shot_hit_rate"] = tot["shot_hits"] / maxf(tot["shots"], 1.0)
	tot["rivet_damage_per_fight"] = damage / float(seeds)
	return tot


func _fight(seed: int, lead: float, ticks: int) -> Object:
	var layout: GDScript = load("res://features/combat/ai/pit_layout.gd")
	var pit: Object = layout.call("build", seed)
	pit.set("rivet_pos", Vector2(-5.0, 0.0))
	var ids: Array[StringName] = []
	for i: int in SPOTS.size():
		ids.append(&"patrol_cop" if i % 2 == 0 else &"robot_thug")
	layout.call("place", pit, ids, PackedVector2Array(SPOTS))
	pit.set("rivet_hp", 400.0)
	var roster: Object = pit.get("roster")
	roster.set("aim_lead", lead)
	var dummy: Object = (load("res://features/combat/ai/pit_dummy.gd") as GDScript).new(
		2, pit.get("rivet_pos")
	)
	dummy.set("fire_m", 10.0)
	dummy.set("react_ticks", 15)
	dummy.set("read_frac", _read)
	dummy.set("read_salt", seed if _salt else 0)
	dummy.set("aim_err_deg", 4.0)
	dummy.set("watch_rounds", false)
	for t: int in ticks:
		dummy.call("step", pit)
		pit.call("step")
	return pit
