class_name ArsenalTable
extends RefCounted
## How Rivet holds each weapon (data/tables/rivet_arsenal.json): per grip class the draw and stow
## ticks, the recoil kick and the walk scale; the reload split (magazine out, in, cock) as
## fractions of a weapon's reload_s; and every weapon id's grip class. A broken row is an error,
## never a crash.

const TABLE: String = "res://data/tables/rivet_arsenal.json"
const SCHEMA: String = "gtai.rivet-arsenal/1"


class Grip:
	extends RefCounted
	var id: StringName = &""
	var draw_ticks: int = 1
	var stow_ticks: int = 1
	var kick: float = 1.0
	var move_mult: float = 1.0
	var held_scale: float = 1.0


var grips: Dictionary[StringName, Grip] = {}
var weapon_grip: Dictionary[StringName, StringName] = {}
## Weapons drawn with another weapon's held art until their own lands (weapon_art.json).
var art_stand_in: Dictionary[StringName, StringName] = {}
var out_k: float = 0.3
var in_k: float = 0.45
var cock_k: float = 0.25
var errors: Array[String] = []


static func shipped() -> ArsenalTable:
	return from_table(DataTable.open(TABLE, SCHEMA))


static func from_table(t: DataTable) -> ArsenalTable:
	var a: ArsenalTable = ArsenalTable.new()
	var rows: Dictionary = t.object(t.raw, "classes")
	for key: String in rows:
		var row: Dictionary = t.object(rows, key)
		var g: Grip = Grip.new()
		g.id = StringName(key)
		g.draw_ticks = t.integer(row, "draw_ticks")
		g.stow_ticks = t.integer(row, "stow_ticks")
		g.kick = t.num(row, "kick")
		g.move_mult = t.num(row, "move_mult")
		g.held_scale = t.num(row, "held_scale")
		a.grips[g.id] = g
	var r: Dictionary = t.object(t.raw, "reload")
	a.out_k = t.num(r, "out_k")
	a.in_k = t.num(r, "in_k")
	a.cock_k = t.num(r, "cock_k")
	var w: Dictionary = t.object(t.raw, "weapons")
	for key: String in w:
		a.weapon_grip[StringName(key)] = StringName(t.text(w, key))
	if t.raw.has("art_stand_in"):
		var st: Dictionary = t.object(t.raw, "art_stand_in")
		for key: String in st:
			a.art_stand_in[StringName(key)] = StringName(t.text(st, key))
	a.errors = t.errors()
	a._check()
	return a


## The weapon_art id that draws `weapon_id` in the claw.
func art_id(weapon_id: StringName) -> StringName:
	return art_stand_in.get(weapon_id, weapon_id)


## The grip a weapon is held in (null: unknown weapon or bare claw).
func grip_of(weapon_id: StringName) -> Grip:
	var g: StringName = weapon_grip.get(weapon_id, &"")
	return grips.get(g, null)


func ok() -> bool:
	return errors.is_empty()


func _check() -> void:
	for g: Grip in grips.values():
		if g.draw_ticks < 1 or g.stow_ticks < 1:
			errors.append("rivet_arsenal.json: %s must take at least one tick each way" % g.id)
	for w: StringName in weapon_grip:
		if not grips.has(weapon_grip[w]):
			errors.append("rivet_arsenal.json: %s has no grip class %s" % [w, weapon_grip[w]])
	if absf(out_k + in_k + cock_k - 1.0) > 0.001:
		errors.append("rivet_arsenal.json: reload fractions must sum to 1")
