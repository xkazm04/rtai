class_name EnemyRoster
extends RefCounted
## enemies.json (gtai.enemies/1) read once into typed archetypes, weapons and squad limits,
## times already in 60 Hz ticks (SIM-01). Archetypes and weapons are keyed by their string id.

const TABLE: String = "res://data/tables/enemies.json"
const SCHEMA: String = "gtai.enemies/1"


class Weapon:
	extends RefCounted
	var id: StringName = &""
	var melee: bool = false
	var burst: int = 1
	var burst_gap_ticks: int = 0
	var cooldown_ticks: int = 60
	var damage: float = 1.0
	var reach_m: float = 10.0
	var speed_mps: float = 20.0


class Archetype:
	extends RefCounted
	var id: StringName = &""
	var body: StringName = &"human"
	var hit_fx: StringName = &"blood"
	var weapon: Weapon = null
	var hp: float = 1.0
	var speed_mps: float = 3.0
	var strafe_mps: float = 1.5
	var accel_mps2: float = 12.0
	var turn_rad_per_tick: float = 0.1
	var preferred_m: float = 8.0
	var attack_m: float = 12.0
	var aggression: float = 0.5
	var morale: float = 0.5
	var reaction_ticks: int = 30
	var telegraph_ticks: int = 30
	var uses_cover: bool = false
	var flanks: bool = false
	var shield_front_mult: float = 1.0
	var acc_near_m: float = 4.0
	var acc_near: float = 0.7
	var acc_far_m: float = 18.0
	var acc_far: float = 0.3

	## The chance a shot at a standing target `dist_m` away hits (the accuracy curve).
	func accuracy(dist_m: float) -> float:
		var span: float = maxf(acc_far_m - acc_near_m, 0.01)
		var k: float = clampf((dist_m - acc_near_m) / span, 0.0, 1.0)
		return lerpf(acc_near, acc_far, k)


var archetypes: Dictionary[StringName, Archetype] = {}
var weapons: Dictionary[StringName, Weapon] = {}
var max_shooters: int = 2
var max_melee: int = 2
var token_hold_ticks: int = 150
var aim_lock_ticks: int = 12
var recover_ticks: int = 30
var panic_ticks: int = 180
var sight_m: float = 24.0
var sight_cos: float = 0.5
var hearing_m: float = 22.0
var _errors: Array[String] = []


static func shipped(path: String = TABLE) -> EnemyRoster:
	var r: EnemyRoster = EnemyRoster.new()
	var t: DataTable = DataTable.open(path, SCHEMA)
	var wrows: Dictionary = t.object(t.raw, "weapons")
	for wid: String in wrows:
		r.weapons[StringName(wid)] = _weapon(t, StringName(wid), t.object(wrows, wid))
	for raw: Variant in t.array(t.raw, "archetypes"):
		var row: Dictionary = raw if raw is Dictionary else {}
		var a: Archetype = r._archetype(t, row)
		r.archetypes[a.id] = a
	r._squad(t, t.object(t.raw, "squad"))
	r._errors.append_array(t.errors())
	if not r.ok():
		Log.error("enemy-ai", str(r._errors))
	return r


func ok() -> bool:
	return _errors.is_empty()


func errors() -> Array[String]:
	return _errors


func archetype(id: StringName) -> Archetype:
	return archetypes.get(id, null)


func _squad(t: DataTable, s: Dictionary) -> void:
	max_shooters = t.integer(s, "max_shooters")
	max_melee = t.integer(s, "max_melee")
	token_hold_ticks = CombatTuning.ticks(t.num(s, "token_hold_s"))
	aim_lock_ticks = CombatTuning.ticks(t.num(s, "aim_lock_s"))
	recover_ticks = CombatTuning.ticks(t.num(s, "recover_s"))
	panic_ticks = CombatTuning.ticks(t.num(s, "panic_s"))
	sight_m = t.num(s, "sight_m")
	sight_cos = cos(deg_to_rad(t.num(s, "sight_deg")) * 0.5)
	hearing_m = t.num(s, "hearing_m")


func _archetype(t: DataTable, row: Dictionary) -> Archetype:
	var a: Archetype = Archetype.new()
	a.id = StringName(t.text(row, "id"))
	a.body = StringName(t.text(row, "body"))
	a.hit_fx = StringName(t.text(row, "hit_fx"))
	var wid: StringName = StringName(t.text(row, "weapon"))
	a.weapon = weapons.get(wid, null)
	if a.weapon == null:
		_errors.append("%s: unknown weapon %s" % [a.id, wid])
		a.weapon = Weapon.new()
	a.hp = t.num(row, "hp")
	a.speed_mps = t.num(row, "speed_mps")
	a.strafe_mps = t.num(row, "strafe_mps")
	a.accel_mps2 = t.num(row, "accel_mps2")
	a.turn_rad_per_tick = deg_to_rad(t.num(row, "turn_deg_s")) * SimClock.TICK_DT
	a.preferred_m = t.num(row, "preferred_m")
	a.attack_m = t.num(row, "attack_m")
	a.aggression = t.num(row, "aggression")
	a.morale = t.num(row, "morale")
	a.reaction_ticks = CombatTuning.ticks(t.num(row, "reaction_s"))
	a.telegraph_ticks = CombatTuning.ticks(t.num(row, "telegraph_s"))
	a.uses_cover = row.get("uses_cover", false) == true
	a.flanks = row.get("flanks", false) == true
	a.shield_front_mult = t.num(row, "shield_front_mult")
	var acc: Dictionary = t.object(row, "accuracy")
	a.acc_near_m = t.num(acc, "near_m")
	a.acc_near = t.num(acc, "near")
	a.acc_far_m = t.num(acc, "far_m")
	a.acc_far = t.num(acc, "far")
	return a


static func _weapon(t: DataTable, id: StringName, row: Dictionary) -> Weapon:
	var w: Weapon = Weapon.new()
	w.id = id
	w.melee = row.get("melee", false) == true
	w.burst = t.integer(row, "burst")
	w.burst_gap_ticks = CombatTuning.ticks(t.num(row, "burst_gap_s"))
	w.cooldown_ticks = CombatTuning.ticks(t.num(row, "cooldown_s"))
	w.damage = t.num(row, "damage")
	w.reach_m = t.num(row, "reach_m")
	w.speed_mps = t.num(row, "speed_mps")
	return w
