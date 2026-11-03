class_name BodyTable
extends RefCounted
## Reader for data/tables/bodies.json (gtai.bodies/1): body size classes (radius, mass) and the
## tackle matrix. Every non-reserved attacker/defender pair must have a rule; a missing class or
## rule is a load error, never a silent default (a planted zero radius fails the scenarios).

const PATH: String = "res://data/tables/bodies.json"
const SCHEMA: String = "gtai.bodies/1"
const RESULTS: Array[StringName] = [&"blocked", &"knockdown", &"shove", &"stagger"]

var tackle_mps: float = 0.0
var flee_s: float = 0.0
var _radius: Dictionary[StringName, float] = {}
var _mass: Dictionary[StringName, float] = {}
var _rules: Dictionary[StringName, BodyRule] = {}
var _errors: Array[String] = []


static func load_default() -> BodyTable:
	return from_table(DataTable.open(PATH, SCHEMA))


static func from_table(t: DataTable) -> BodyTable:
	var b: BodyTable = BodyTable.new()
	b.tackle_mps = t.num(t.raw, "tackle_mps")
	b.flee_s = t.num(t.raw, "flee_s")
	var live: Array[StringName] = []
	for row: Variant in t.array(t.raw, "classes"):
		var c: Dictionary = row if row is Dictionary else {}
		var id: StringName = StringName(t.text(c, "id"))
		b._radius[id] = t.num(c, "radius_m")
		b._mass[id] = t.num(c, "mass_kg")
		if not c.get("reserved", false):
			live.append(id)
	for row: Variant in t.array(t.raw, "rules"):
		var r: Dictionary = row if row is Dictionary else {}
		var br: BodyRule = BodyRule.from_row(t, r)
		b._rules[key(br.attacker, br.defender)] = br
	b._errors = t.errors()
	b._check(live)
	return b


static func key(attacker: StringName, defender: StringName) -> StringName:
	return StringName("%s>%s" % [attacker, defender])


func ok() -> bool:
	return _errors.is_empty()


func errors() -> Array[String]:
	return _errors.duplicate()


func radius(cls: StringName) -> float:
	return _radius.get(cls, 0.0)


func mass(cls: StringName) -> float:
	return _mass.get(cls, 0.0)


## The rule for `attacker` running or walking into `defender` (null when missing).
func rule(attacker: StringName, defender: StringName) -> BodyRule:
	return _rules.get(key(attacker, defender), null)


## The share of an overlap the defender takes: attacker mass / (attacker + defender mass).
func share(attacker: StringName, defender: StringName) -> float:
	var ma: float = mass(attacker)
	var md: float = mass(defender)
	return ma / (ma + md) if ma + md > 0.0 else 0.5


func _check(live: Array[StringName]) -> void:
	for id: StringName in _radius:
		if _radius[id] <= 0.0 or _mass[id] <= 0.0:
			_errors.append("bodies.json: class %s needs radius_m and mass_kg > 0" % id)
	for a: StringName in live:
		for d: StringName in live:
			var r: BodyRule = rule(a, d)
			if r == null:
				_errors.append("bodies.json: no rule %s -> %s" % [a, d])
			elif not (r.walk in RESULTS and r.run in RESULTS):
				_errors.append("bodies.json: rule %s -> %s has an unknown result" % [a, d])
