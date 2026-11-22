class_name MeleeTable
extends RefCounted
## The claw and carried weapons use the same hit model. The mode selects either the weapon's
## single swing or its original chain. Version-one tables without a mode keep their chain.

const TABLE: String = "res://data/tables/rivet_melee.json"
const SCHEMA: String = "gtai.rivet-melee/1"
const WEAPONS: String = "res://data/tables/melee_weapons.json"
const WEAPONS_SCHEMA: String = "gtai.melee-weapons/1"
const CLAW: StringName = &"claw"

var id: StringName = CLAW
var electric: bool = false
var machine_stun_ticks: int = 0
var heavy_stun_ticks: int = 0
var never_finish: Array[StringName] = []
var kills_human: bool = false
var vs_shield: StringName = &"blocked"
var shield_break_ticks: int = 0
var single_swing: bool = false
var swing_style: StringName = &""
var hits: Array[MeleeHit]:
	get:
		return _single if single_swing else _chain
var cancel_ticks: int = 4
var combo_window_ticks: int = 12
var shock: Dictionary = {}
## Weapon-only: top-speed scale while a hit plays, the metal-chain radius, the blade length and
## grip (for the rig). The claw keeps the defaults.
var move_mult: float = 1.0
var chain_radius_m: float = 0.0
var length_m: float = 0.0
var grip: StringName = &"none"
## The plasma sword's timed deflect: hostile rounds within this of Rivet, in front, during a hit's
## active ticks go back at their shooter (0 = none).
var deflect_m: float = 0.0
## n17 rivet-strike (RivetLean): the drawn figure's lean back through the wind-up and into the
## strike, in degrees about his feet; 0 = upright.
var lean_back_deg: float = 0.0
var lean_in_deg: float = 0.0
var errors: Array[String] = []
var _single: Array[MeleeHit] = []
var _chain: Array[MeleeHit] = []


static func shipped() -> MeleeTable:
	return from_table(DataTable.open(TABLE, SCHEMA))


static func from_table(t: DataTable) -> MeleeTable:
	var m: MeleeTable = MeleeTable.new()
	_read_combo(t, t.object(t.raw, "claw"), m)
	m.shock = t.object(t.raw, "shock")
	m.errors.append_array(t.errors())
	if m.hits.is_empty():
		m.errors.append("rivet_melee.json: claw.hits is empty")
	return m


## The shipped melee weapon `weapon_id`, or a table whose errors name the missing row.
static func weapon(weapon_id: StringName) -> MeleeTable:
	return weapon_from(DataTable.open(WEAPONS, WEAPONS_SCHEMA), weapon_id)


static func weapon_from(t: DataTable, weapon_id: StringName) -> MeleeTable:
	var m: MeleeTable = MeleeTable.new()
	m.id = weapon_id
	var rows: Dictionary = t.object(t.raw, "weapons")
	if not rows.has(String(weapon_id)):
		m.errors.append_array(t.errors())
		m.errors.append("melee_weapons.json: no weapon %s" % weapon_id)
		return m
	var row: Dictionary = t.object(rows, String(weapon_id))
	_read_combo(t, row, m)
	m.move_mult = t.num(row, "move_mult")
	m.chain_radius_m = t.num(row, "chain_radius_m")
	m.length_m = t.num(row, "length_m")
	m.grip = StringName(t.text(row, "grip"))
	if row.has("deflect_m"):
		m.deflect_m = t.num(row, "deflect_m")
	if row.has("lean_in_deg"):
		m.lean_back_deg = t.num(row, "lean_back_deg")
		m.lean_in_deg = t.num(row, "lean_in_deg")
	if m.single_swing and row.has("swing_lean_deg"):
		var lean: Vector2 = t.vec(row, "swing_lean_deg")
		m.lean_back_deg = lean.x
		m.lean_in_deg = lean.y
	m.errors.append_array(t.errors())
	if m.hits.is_empty():
		m.errors.append("melee_weapons.json: %s.hits is empty" % weapon_id)
	return m


## The ids in melee_weapons.json, sorted alphabetically (the panel's weapon list). Sorted as
## Strings: StringName order is by interned pointer, so it depends on what was interned first.
static func weapon_ids() -> Array[StringName]:
	var t: DataTable = DataTable.open(WEAPONS, WEAPONS_SCHEMA)
	var keys: PackedStringArray = PackedStringArray()
	for key: Variant in t.object(t.raw, "weapons").keys():
		@warning_ignore("return_value_discarded")
		keys.append(str(key))
	keys.sort()
	var out: Array[StringName] = []
	for key: String in keys:
		out.append(StringName(key))
	return out


static func _read_combo(t: DataTable, combo: Dictionary, m: MeleeTable) -> void:
	m.electric = combo.get("electric", false) == true
	m.machine_stun_ticks = (
		t.integer(combo, "machine_stun_ticks") if combo.has("machine_stun_ticks") else 0
	)
	m.heavy_stun_ticks = (
		t.integer(combo, "heavy_stun_ticks") if combo.has("heavy_stun_ticks") else 0
	)
	for enemy_id: String in combo.get("never_finish", []):
		m.never_finish.append(StringName(enemy_id))
	m.kills_human = combo.get("kills_human", false) == true
	m.vs_shield = StringName(str(combo.get("vs_shield", "blocked")))
	if combo.has("shield_break_ticks"):
		m.shield_break_ticks = t.integer(combo, "shield_break_ticks")
	m.cancel_ticks = t.integer(combo, "cancel_ticks")
	m.combo_window_ticks = t.integer(combo, "combo_window_ticks")
	var mode: Variant = t.raw.get("single_swing", false)
	if mode is bool:
		m.single_swing = mode
	else:
		m.errors.append("single_swing must be a boolean")
	if combo.has("swing") or m.single_swing:
		m.swing_style = StringName(t.text(combo, "swing_style"))
		m._single.append(_read_hit(t, t.object(combo, "swing")))
	for raw: Variant in t.array(combo, "hits"):
		var row: Dictionary = raw if raw is Dictionary else {}
		m._chain.append(_read_hit(t, row))


static func _read_hit(t: DataTable, row: Dictionary) -> MeleeHit:
	var h: MeleeHit = MeleeHit.new()
	h.id = StringName(t.text(row, "id"))
	h.windup = t.integer(row, "windup_ticks")
	h.active = t.integer(row, "active_ticks")
	h.recovery = t.integer(row, "recovery_ticks")
	h.reach_m = t.num(row, "reach_m")
	h.cone_dot = t.num(row, "cone_dot")
	h.damage = t.num(row, "damage")
	h.knockback_m = t.num(row, "knockback_m")
	# The claw omits weapon stun and chain fields, but its hits can still lunge.
	if row.has("stun_look"):
		h.stun_look = StringName(t.text(row, "stun_look"))
	if row.has("stun_ticks"):
		h.stun_ticks = t.integer(row, "stun_ticks")
		h.chain_hops = t.integer(row, "chain_hops")
	if row.has("lunge_m"):
		h.lunge_m = t.num(row, "lunge_m")
	if row.has("lunge_ticks"):
		h.lunge_ticks = mini(t.integer(row, "lunge_ticks"), maxi(h.windup - 1, 0))
	if row.has("grind_ticks"):
		h.grind_ticks = t.integer(row, "grind_ticks")
	if row.has("grind_min_ticks"):
		h.grind_min_ticks = t.integer(row, "grind_min_ticks")
	return h


## True when a hit of this combo grinds (the chainsaw): its hold counter is replay state.
func grinds() -> bool:
	for h: MeleeHit in hits:
		if h.grind_ticks > 0:
			return true
	return false


func ok() -> bool:
	return errors.is_empty()


## The bodies a landed hit reaches: `first` (the struck body), then, when that body is metal and
## the hit has chain_hops, the arc hops metal-to-metal within this weapon's chain_radius_m (the
## electro baton's finisher; the same walk as the charged shock). A human struck first never arcs.
func chain_for(
	hit: MeleeHit, pos: PackedVector2Array, metal: PackedByteArray, first: int
) -> PackedInt32Array:
	if hit.chain_hops <= 0 or metal[first] == 0:
		return PackedInt32Array([first])
	return MeleeShock.chain_path(pos, metal, first, hit.chain_hops, chain_radius_m)
