class_name EnemyRoster
extends RefCounted
## enemies.json (gtai.enemies/1) read once into typed archetypes, weapons and squad limits,
## times already in 60 Hz ticks (SIM-01). Archetypes and weapons are keyed by their string id.

const TABLE: String = "res://data/tables/enemies.json"
const SCHEMA: String = "gtai.enemies/1"


class Weapon:
	extends EnemyWeapon

	static func from_row(t: DataTable, weapon_id: StringName, row: Dictionary) -> Weapon:
		var w: Weapon = Weapon.new()
		w.read(t, weapon_id, row)
		return w


class Archetype:
	extends RefCounted
	var id: StringName = &""
	var body: StringName = &"human"
	var hit_fx: StringName = &"blood"
	var weapon: Weapon = null
	var alt_weapon: Weapon
	var tier: int = 1
	var explicit_spawn: bool = false
	var shield_cos: float = 0.5
	var hp: float = 1.0
	var speed_mps: float = 3.0
	var strafe_mps: float = 1.5
	var accel_mps2: float = 12.0
	var turn_rad_per_tick: float = 0.1
	var preferred_m: float = 8.0
	var attack_m: float = 12.0
	var cover_bias: float = 0.0
	var peek_ticks: int = 0
	var production_weapon: StringName = &"assault-rifle"
	var production_damage: float = 0.0
	var aggression: float = 0.5
	var morale: float = 0.5
	var reaction_ticks: int = 30
	var telegraph_ticks: int = 30
	var stagger_ticks: int = 0
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
var aim_lead: float = 0.0
var recover_ticks: int = 30
var panic_ticks: int = 180
var sight_m: float = 24.0
var sight_cos: float = 0.5
var hearing_m: float = 22.0
var _explicit: Dictionary[StringName, Archetype] = {}
var _errors: Array[String] = []


static func shipped(path: String = TABLE, production: bool = false) -> EnemyRoster:
	var r: EnemyRoster = EnemyRoster.new()
	var t: DataTable = DataTable.open(path, SCHEMA)
	var wrows: Dictionary = t.object(t.raw, "weapons")
	for wid: String in wrows:
		r.weapons[StringName(wid)] = Weapon.from_row(t, StringName(wid), t.object(wrows, wid))
	for raw: Variant in t.array(t.raw, "archetypes"):
		var row: Dictionary = raw if raw is Dictionary else {}
		var a: Archetype = r._archetype(t, row)
		if row.get("production_only", false) == true and not production:
			continue
		if a.explicit_spawn and not production:
			r._explicit[a.id] = a
			continue
		if production:
			a.uses_cover = a.cover_bias > 0.0
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
	return archetypes.get(id if id != &"" else &"contractor", _explicit.get(id))


func _squad(t: DataTable, s: Dictionary) -> void:
	max_shooters = t.integer(s, "max_shooters")
	max_melee = t.integer(s, "max_melee")
	token_hold_ticks = CombatTuning.ticks(t.num(s, "token_hold_s"))
	aim_lock_ticks = CombatTuning.ticks(t.num(s, "aim_lock_s"))
	aim_lead = t.num(s, "aim_lead")
	recover_ticks = CombatTuning.ticks(t.num(s, "recover_s"))
	panic_ticks = CombatTuning.ticks(t.num(s, "panic_s"))
	sight_m = t.num(s, "sight_m")
	sight_cos = cos(deg_to_rad(t.num(s, "sight_deg")) * 0.5)
	hearing_m = t.num(s, "hearing_m")


func _archetype(t: DataTable, row: Dictionary) -> Archetype:
	var a: Archetype = Archetype.new()
	a.id = StringName(t.text(row, "id"))
	_read_foe(t, row, a)
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
	a.cover_bias = t.num(row, "cover_bias")
	a.peek_ticks = CombatTuning.ticks(t.num(row, "peek_s"))
	a.production_damage = t.num(row, "production_damage")
	if row.has("production_weapon"):
		a.production_weapon = StringName(t.text(row, "production_weapon"))
	a.aggression = t.num(row, "aggression")
	a.morale = t.num(row, "morale")
	a.reaction_ticks = CombatTuning.ticks(t.num(row, "reaction_s"))
	a.telegraph_ticks = CombatTuning.ticks(t.num(row, "telegraph_s"))
	a.stagger_ticks = CombatTuning.ticks(t.num(row, "stagger_s"))
	a.uses_cover = row.get("uses_cover", false) == true
	a.flanks = row.get("flanks", false) == true
	a.shield_front_mult = t.num(row, "shield_front_mult")
	var acc: Dictionary = t.object(row, "accuracy")
	a.acc_near_m = t.num(acc, "near_m")
	a.acc_near = t.num(acc, "near")
	a.acc_far_m = t.num(acc, "far_m")
	a.acc_far = t.num(acc, "far")
	return a


func _read_foe(t: DataTable, row: Dictionary, a: Archetype) -> void:
	var tier: float = t.num(row, "tier")
	a.tier = int(tier)
	if tier != a.tier or a.tier < 1 or a.tier > 5:
		_errors.append("%s: tier must be an integer from 1 to 5" % a.id)
	a.explicit_spawn = row.get("explicit_spawn", false) == true
	if row.has("alt_weapon"):
		a.alt_weapon = weapons.get(StringName(t.text(row, "alt_weapon")))
		if a.alt_weapon == null:
			_errors.append("%s: unknown alt_weapon" % a.id)
	if row.has("shield_arc_deg"):
		a.shield_cos = cos(deg_to_rad(t.num(row, "shield_arc_deg") * 0.5))
