class_name MeleeTable
extends RefCounted
## One melee combo as timing data: the hits as windup / active / recovery ticks, the cancel point
## and the combo window. The bare claw (data/tables/rivet_melee.json, with the charged shock) and
## each melee weapon (data/tables/melee_weapons.json: electro_baton, katana) load into the same
## shape, so MeleeCombo plays any of them. A broken row is an error, never a crash.

const TABLE: String = "res://data/tables/rivet_melee.json"
const SCHEMA: String = "gtai.rivet-melee/1"
const WEAPONS: String = "res://data/tables/melee_weapons.json"
const WEAPONS_SCHEMA: String = "gtai.melee-weapons/1"
const CLAW: StringName = &"claw"

var id: StringName = CLAW
var hits: Array[MeleeHit] = []
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
var errors: Array[String] = []


static func shipped() -> MeleeTable:
	return from_table(DataTable.open(TABLE, SCHEMA))


static func from_table(t: DataTable) -> MeleeTable:
	var m: MeleeTable = MeleeTable.new()
	_read_combo(t, t.object(t.raw, "claw"), m)
	m.shock = t.object(t.raw, "shock")
	m.errors = t.errors()
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
		m.errors = t.errors()
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
	m.errors = t.errors()
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
	m.cancel_ticks = t.integer(combo, "cancel_ticks")
	m.combo_window_ticks = t.integer(combo, "combo_window_ticks")
	for raw: Variant in t.array(combo, "hits"):
		var row: Dictionary = raw if raw is Dictionary else {}
		var h: MeleeHit = MeleeHit.new()
		h.id = StringName(t.text(row, "id"))
		h.windup = t.integer(row, "windup_ticks")
		h.active = t.integer(row, "active_ticks")
		h.recovery = t.integer(row, "recovery_ticks")
		h.reach_m = t.num(row, "reach_m")
		h.cone_dot = t.num(row, "cone_dot")
		h.damage = t.num(row, "damage")
		h.knockback_m = t.num(row, "knockback_m")
		# Weapon-only fields: the claw rows omit them and keep 0 (the claw may lunge: it steps in).
		if row.has("stun_ticks"):
			h.stun_ticks = t.integer(row, "stun_ticks")
			h.chain_hops = t.integer(row, "chain_hops")
		if row.has("lunge_m"):
			h.lunge_m = t.num(row, "lunge_m")
		if row.has("grind_ticks"):
			h.grind_ticks = t.integer(row, "grind_ticks")
		if row.has("grind_min_ticks"):
			h.grind_min_ticks = t.integer(row, "grind_min_ticks")
		m.hits.append(h)


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
