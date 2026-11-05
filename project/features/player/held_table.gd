class_name HeldTable
extends RefCounted
## d7-held: Rivet's hold per weapon class (data/tables/held_classes.json): which RigGrip kind
## poses both arms, where the gun claw and the off claw sit, the claw cell, the anchors (the off
## claw's place along the weapon), a blade's wrist turn and the walk/aim modifiers. Every weapon
## is in exactly one class. A broken row is an error, never a crash.

const TABLE: String = "res://data/tables/held_classes.json"
const SCHEMA: String = "gtai.held-classes/1"
const KINDS: Dictionary[String, int] = {
	"one_hand": RigGrip.Kind.ONE_HAND,
	"two_hand_long": RigGrip.Kind.TWO_HAND_LONG,
	"shoulder": RigGrip.Kind.SHOULDER,
	"hip": RigGrip.Kind.HIP,
	"thrown": RigGrip.Kind.THROWN,
	"blade": RigGrip.Kind.BLADE,
}
## The kinds both claws hold: each needs an off claw on the weapon (off_reach, fore_u).
const TWO_CLAW: Array[int] = [RigGrip.Kind.TWO_HAND_LONG, RigGrip.Kind.SHOULDER, RigGrip.Kind.HIP]


class Hold:
	extends RefCounted
	var id: StringName = &""
	var kind: int = RigGrip.Kind.ONE_HAND
	var weapons: Array[StringName] = []
	var claw: StringName = &"closed"
	var gun_reach: float = 0.97
	var off_reach: float = 0.0
	var across: float = 0.3
	var hand_z: float = -10.0
	var fore_u: float = -1.0
	var wrist_rad: float = 0.0
	var stride_k: float = 1.0
	var lean_px: float = 0.0


static var _shipped: HeldTable = null

var holds: Dictionary[StringName, Hold] = {}
var weapon_hold: Dictionary[StringName, StringName] = {}
var errors: Array[String] = []


## The shipped table, read once.
static func shipped() -> HeldTable:
	if _shipped == null:
		_shipped = from_table(DataTable.open(TABLE, SCHEMA))
	return _shipped


static func from_table(t: DataTable) -> HeldTable:
	var h: HeldTable = HeldTable.new()
	var rows: Dictionary = t.object(t.raw, "classes")
	for key: String in rows:
		var row: Dictionary = t.object(rows, key)
		var c: Hold = Hold.new()
		c.id = StringName(key)
		c.kind = KINDS.get(t.text(row, "kind"), -1)
		c.claw = StringName(t.text(row, "claw"))
		c.gun_reach = t.num(row, "gun_reach")
		c.off_reach = t.num(row, "off_reach")
		c.across = t.num(row, "across")
		c.hand_z = t.num(row, "hand_z")
		c.fore_u = t.num(row, "fore_u")
		c.wrist_rad = t.num(row, "wrist_rad")
		c.stride_k = t.num(row, "stride_k")
		c.lean_px = t.num(row, "lean_px")
		for w: Variant in t.array(row, "weapons"):
			c.weapons.append(StringName(str(w)))
		h.holds[c.id] = c
	h.errors = t.errors()
	h._index()
	return h


## The hold `weapon_id` is held in (null: unknown weapon or bare claw).
func hold_of(weapon_id: StringName) -> Hold:
	return holds.get(weapon_hold.get(weapon_id, &""), null)


## The first class (in id order) of RigGrip kind `kind` (null: none): a rig set to a kind alone.
func by_kind(kind: int) -> Hold:
	var ids: Array[StringName] = holds.keys()
	ids.sort()
	for id: StringName in ids:
		if holds[id].kind == kind:
			return holds[id]
	return null


func ok() -> bool:
	return errors.is_empty()


## Every weapon in one class; every class with its anchors (`missing` = weapons that must be in).
func check(missing: Array[StringName]) -> Array[String]:
	var out: Array[String] = []
	for w: StringName in missing:
		if not weapon_hold.has(w):
			out.append("held_classes.json: %s has no hold class" % w)
	for c: Hold in holds.values():
		var two: bool = c.kind in TWO_CLAW
		if c.kind < 0:
			out.append("held_classes.json: %s has an unknown kind" % c.id)
		if two and (c.off_reach <= 0.0 or c.fore_u < 0.0):
			out.append(
				"held_classes.json: %s needs the off claw's anchor (off_reach, fore_u)" % c.id
			)
		if not two and (c.off_reach > 0.0 or c.fore_u >= 0.0):
			out.append("held_classes.json: %s is one-claw but anchors the off claw" % c.id)
		if c.kind == RigGrip.Kind.BLADE and c.wrist_rad == 0.0:
			out.append("held_classes.json: %s is a blade with no wrist turn" % c.id)
	return out


func _index() -> void:
	for c: Hold in holds.values():
		for w: StringName in c.weapons:
			if weapon_hold.has(w):
				errors.append("held_classes.json: %s is in %s and %s" % [w, weapon_hold[w], c.id])
			weapon_hold[w] = c.id
	errors.append_array(check([]))
