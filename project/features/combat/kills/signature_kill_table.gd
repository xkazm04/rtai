class_name SignatureKillTable
extends RefCounted
## signature_kills.json read as data (lane brutality): the signature kill of each advanced weapon,
## looked up by the weapon id a lethal hit carries. `gore_full` false (`--gore=reduced`) makes
## every lookup miss, so the victim takes the standard death and nothing is dismembered.

const PATH: String = "res://data/tables/signature_kills.json"
const SCHEMA: String = "gtai.signature_kills/1"

var leftover_budget: int = 12
var gore_full: bool = true
var problems: Array[String] = []
var _by_victim: Dictionary[StringName, Dictionary] = {}
var _by_weapon: Dictionary[StringName, SignatureKill] = {}


static func load_table(path: String = PATH) -> SignatureKillTable:
	return from_table(DataTable.open(path, SCHEMA))


static func from_table(t: DataTable) -> SignatureKillTable:
	var out: SignatureKillTable = SignatureKillTable.new()
	if t.ok():
		out.leftover_budget = maxi(1, t.integer(t.raw, "leftover_budget"))
		for v: Variant in t.array(t.raw, "kills"):
			if v is Dictionary:
				var d: Dictionary = v
				var row: SignatureKill = SignatureKill.from_dict(t, d)
				out._by_weapon[row.weapon] = row
				out._read_variants(t, d, row)
				for also: Variant in d.get("also_weapons", []):  # e.g. Rivet's charged claw shock
					out._by_weapon[StringName(str(also))] = row
	out.problems = t.errors()
	return out


static func variant_data(base: Dictionary, victim: String, patch: Dictionary) -> Dictionary:
	var data: Dictionary = base.merged(patch, true)
	data["id"] = "%s_%s" % [base["id"], victim]
	for key: String in ["fx", "cells"]:
		if patch.has(key):
			var defaults: Dictionary = base.get(key, {})
			var override: Dictionary = patch[key]
			data[key] = defaults.merged(override, true)
	return data


func _read_variants(t: DataTable, base: Dictionary, row: SignatureKill) -> void:
	var variants: Dictionary = base.get("variants", {})
	if variants.is_empty():
		return
	var resolved: Dictionary[StringName, SignatureKill] = {}
	for victim: String in variants:
		var patch: Dictionary = variants[victim]
		var data: Dictionary = variant_data(base, victim, patch)
		var variant: SignatureKill = SignatureKill.from_dict(t, data)
		variant.victim = StringName(victim)
		variant.kit = StringName(str(data.get("kit", "")))
		variant.kit_m = t.num(data, "kit_m") if data.has("kit_m") else 0.0
		variant.plate_m = t.num(data, "plate_m") if data.has("plate_m") else 0.0
		resolved[variant.victim] = variant
	_by_victim[row.weapon] = resolved


## `--gore=full|reduced` (default full) from the launch args.
static func gore_from_args(value: String) -> bool:
	return value != "reduced"


## The weapon's signature kill, or null (no row, or reduced gore).
func for_weapon(weapon: StringName, victim: StringName = &"") -> SignatureKill:
	if not gore_full:
		return null
	return _lookup(weapon, victim)


## Mechanical shutdown leaves the chassis whole at either gore setting.
func shutdown(victim: StringName) -> SignatureKill:
	return _lookup(&"electric_shutdown", victim)


func _lookup(weapon: StringName, victim: StringName) -> SignatureKill:
	var base: SignatureKill = _by_weapon.get(weapon)
	if base != null and _by_victim.has(base.weapon):
		return _by_victim[base.weapon].get(victim, base)
	return base


func weapons() -> Array[StringName]:
	var out: Array[StringName] = []
	out.assign(_by_weapon.keys())
	out.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	return out
