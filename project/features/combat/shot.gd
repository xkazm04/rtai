class_name Shot
extends RefCounted
## A nail or a rifle round in flight: straight line, fixed speed, a range it dies at.

const SMALL: StringName = &"small"
const LARGE: StringName = &"large"

var size: StringName = SMALL:
	set(value):
		size = value
		size_known = true
## A typed weapon already supplied the size, or the arena resolved a bare enemy round.
var size_known: bool = false
var pos: Vector2 = Vector2.ZERO
var vel: Vector2 = Vector2.ZERO
var from_rivet: bool = true
var weapon: StringName = &""
var damage: float = 1.0
var left_m: float = 20.0
var shooter_id: int = 0
## Lane gunplay: the weapons.json row of a GunHand round (FightAreas lands its area effects); null
## for quest 1's own weapons.
var spec: WeaponSpec = null
## Where the round left the muzzle (views: the rocket's trail, the bottle's arc).
var origin: Vector2 = Vector2.ZERO
## Lane gunplay: where a homing round has been (the curved trail; view only, not replay state).
var trail: PackedVector2Array = PackedVector2Array()
## Lane gunplay: a charge gun's full-charge round (damage already set; views draw it fat).
var charged: bool = false


static func fire(shooter: Fighter, dir: Vector2, w: CombatTuning.Weapon) -> Shot:
	var s: Shot = Shot.new()
	s.pos = shooter.pos + dir * (shooter.radius_m + 0.1)
	s.vel = dir * w.speed_mps
	s.from_rivet = shooter.kind == Fighter.Kind.RIVET
	s.weapon = w.id
	s.size = w.round
	s.damage = w.damage if s.from_rivet else w.damage_vs_rivet
	s.left_m = w.range_m
	s.shooter_id = shooter.id
	return s


## All three weapon tables share the optional round enum and report errors through their loader.
static func read_size(t: DataTable, row: Dictionary, id: StringName) -> StringName:
	if not row.has("round"):
		return SMALL
	var value: String = t.text(row, "round")
	match value:
		"small":
			return SMALL
		"large":
			return LARGE
		_:
			t._errors.append("%s.round: expected small or large, got '%s'" % [id, value])
			return SMALL


## Moves one tick; returns the segment start (for the hit test along the path).
func advance() -> Vector2:
	var from: Vector2 = pos
	pos += vel * SimClock.TICK_DT
	left_m -= vel.length() * SimClock.TICK_DT
	return from


func spent() -> bool:
	return left_m <= 0.0


## Did the path from `from` to pos pass within `r` of `at`?
func crossed(from: Vector2, at: Vector2, r: float) -> bool:
	return Geometry2D.get_closest_point_to_segment(at, from, pos).distance_to(at) <= r
