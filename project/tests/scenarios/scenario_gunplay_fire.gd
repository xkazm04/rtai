extends Scenario
## features/combat/weapons, the shooting model end to end: (1) every core weapon's range lane run
## twice on the same seed gives the identical digest (replay-identical), and a planted fault
## (the target 5 cm further) moves it; (2) enemy fire is readable: a Rivet who sidesteps on the
## tell (also 250 ms late) takes at most half the hits of one standing still, and the
## planted fault (a gunner that keeps tracking through the lock) takes the dodge away.

const CORE: Array[StringName] = [
	&"pistol", &"machine_pistol", &"flamethrower", &"rocket_launcher", &"electro_gun", &"molotov"
]


func run(_tree: SceneTree) -> String:
	var table: WeaponTable = WeaponTable.shipped()
	if not table.ok():
		return "weapons.json does not load"
	var det: Dictionary = _determinism(table)
	var dodge: Dictionary = {}
	for w: StringName in [&"pistol", &"machine_pistol"]:
		dodge[String(w)] = _dodge(table, w)
	Log.info("scenario", "gunplay fire: determinism %s; dodge %s" % [det, dodge])
	var err: String = write_evidence("gunplay-fire.json", {"determinism": det, "dodge": dodge})
	if err != "":
		return err
	if det["mismatch"] != "":
		return det["mismatch"]
	for w: String in dodge:
		var d: Dictionary = dodge[w]
		var r: String = _judge_dodge(w, d)
		if r != "":
			return r
	return ""


func _determinism(table: WeaponTable) -> Dictionary:
	var out: Dictionary = {"mismatch": ""}
	for w: StringName in CORE:
		var lane: RangeDrill.Lane = RangeDrill.Lane.new()
		lane.weapon = w
		lane.distance_m = 12.0
		lane.strafe_mps = 3.2
		var a: int = RangeDrill.run(table, lane, _rng(7)).digest
		var b: int = RangeDrill.run(table, lane, _rng(7)).digest
		lane.distance_m = 12.05
		var c: int = RangeDrill.run(table, lane, _rng(7)).digest
		out[String(w)] = [a, b, c]
		if a != b:
			out["mismatch"] = "%s: same seed, different digest %d vs %d" % [w, a, b]
		elif a == c:
			out["mismatch"] = "%s: planted fault (target 5 cm off) not caught" % w
	return out


func _dodge(table: WeaponTable, w: StringName) -> Dictionary:
	var out: Dictionary = {}
	var cases: Dictionary = {
		"stand": [DodgeDrill.Policy.STAND, false],
		"strafe": [DodgeDrill.Policy.STRAFE, false],
		"react": [DodgeDrill.Policy.REACT, false],
		"react_250ms": [DodgeDrill.Policy.REACT, false],
		"react_no_lock": [DodgeDrill.Policy.REACT, true],
	}
	for key: String in cases:
		var s: DodgeDrill.Setup = DodgeDrill.Setup.new()
		s.weapon = w
		s.policy = cases[key][0]
		s.no_lock = cases[key][1]
		s.react_delay_ticks = 15 if key == "react_250ms" else 0
		out[key] = DodgeDrill.run(table, s, _rng(11)).to_dict()
	return out


func _judge_dodge(w: String, d: Dictionary) -> String:
	var stand: float = d["stand"]["hit_rate"]
	var react: float = d["react"]["hit_rate"]
	var no_lock: float = d["react_no_lock"]["hit_rate"]
	if d["stand"]["volleys"] < 3 or stand < 0.6:
		return "%s: a still Rivet is not under fire (%s)" % [w, d["stand"]]
	if react > stand * 0.5 or d["react_250ms"]["hit_rate"] > stand * 0.5:
		return "%s: the tell does not make the volley dodgeable (%s)" % [w, d]
	if no_lock <= react:
		return "%s: planted fault (no lock) did not take the dodge away (%s)" % [w, d]
	return ""


func _rng(seed_value: int) -> RandomNumberGenerator:
	return RngRegistry.new(seed_value).stream(&"gunplay")
