class_name WeaponTable
extends RefCounted
## weapons.json (gtai.weapons/1): every weapon row, the target classes and the enemy-fire scale
## (enemy rounds are slower and weaker so a strafe can beat them). Rows keep table order.

const TABLE: String = "res://data/tables/weapons.json"
const SCHEMA: String = "gtai.weapons/1"

var weapons: Dictionary[StringName, WeaponSpec] = {}
var order: Array[StringName] = []
## target id -> hp, metal flag, body class id (radius comes from bodies.json).
var target_hp: Dictionary[StringName, float] = {}
var target_metal: Dictionary[StringName, bool] = {}
var target_body: Dictionary[StringName, StringName] = {}
var enemy_speed_scale: float = 1.0
var enemy_damage_scale: float = 1.0
var enemy_tell_ticks: int = 0
var enemy_flash_ticks: int = 0
var aim_assist: AimAssist = null
var _errors: Array[String] = []


static func shipped(path: String = TABLE) -> WeaponTable:
	var t: DataTable = DataTable.open(path, SCHEMA)
	return from_table(t)


static func from_table(t: DataTable) -> WeaponTable:
	var wt: WeaponTable = WeaponTable.new()
	for row: Variant in t.array(t.raw, "weapons"):
		var r: Dictionary = row if row is Dictionary else {}
		var w: WeaponSpec = WeaponSpec.from_row(t, r)
		wt.weapons[w.id] = w
		wt.order.append(w.id)
	for row: Variant in t.array(t.raw, "targets"):
		var d: Dictionary = row if row is Dictionary else {}
		var tid: StringName = StringName(t.text(d, "id"))
		wt.target_hp[tid] = t.num(d, "hp")
		wt.target_metal[tid] = d.get("metal", false) == true
		wt.target_body[tid] = StringName(t.text(d, "body"))
	var ef: Dictionary = t.object(t.raw, "enemy_fire")
	wt.enemy_speed_scale = t.num(ef, "speed_scale")
	wt.enemy_damage_scale = t.num(ef, "damage_scale")
	wt.enemy_tell_ticks = WeaponSpec.ticks(t.num(ef, "tell_s"))
	wt.enemy_flash_ticks = WeaponSpec.ticks(t.num(ef, "muzzle_flash_s"))
	wt.aim_assist = AimAssist.from_table(t)
	wt._errors = t.errors()
	if not wt.ok():
		Log.error("weapons", str(wt._errors))
	return wt


func ok() -> bool:
	return _errors.is_empty()


func weapon(id: StringName) -> WeaponSpec:
	return weapons[id]


## The weapons a player can hold tonight (core + canon, enabled), in table order.
func playable() -> Array[StringName]:
	var out: Array[StringName] = []
	for id: StringName in order:
		if weapons[id].enabled:
			out.append(id)
	return out
