class_name BossAttack
extends RefCounted
## One boss attack as data (data/tables/bosses.json `attacks.<id>`), in ticks. The tell is the
## windup: the aim tracks Rivet until `lock` ticks before the active window, then freezes, so a
## move after the lock dodges (enemy-ai's aim-lock rule, scaled up for a boss). The first
## `punish` ticks of the recovery take `punish_k` damage: the reward for a read.

enum Shape { NONE, LINE, CONE, CIRCLE, CHARGE }

const SHAPES: Dictionary[String, Shape] = {
	"none": Shape.NONE,
	"line": Shape.LINE,
	"cone": Shape.CONE,
	"circle": Shape.CIRCLE,
	"charge": Shape.CHARGE,
}

var id: StringName = &""
var shape: Shape = Shape.NONE
var windup: int = 60
var lock: int = 12
var active: int = 30
var recovery: int = 60
var punish: int = 30
var punish_k: float = 1.0
var cooldown: int = 120
var damage: float = 0.0
var range_m: float = 0.0
var width_m: float = 1.0
var arc_deg: float = 45.0
var radius_m: float = 2.0
var move_mps: float = 0.0
## A circle that leaps: its ring tracks Rivet up to this far out, and the boss hops onto it
## through the lock (0 = the ring stays on the boss).
var leap_m: float = 0.0
var min_m: float = 0.0
var max_m: float = 100.0
var weight: float = 1.0
var adds_archetype: StringName = &""
var adds_count: int = 0


static func from_row(t: DataTable, p_id: String, row: Dictionary) -> BossAttack:
	var a: BossAttack = BossAttack.new()
	a.id = StringName(p_id)
	a.shape = SHAPES.get(t.text(row, "shape"), Shape.NONE)
	a.windup = ticks(t.num(row, "windup_s"))
	a.lock = mini(ticks(t.num(row, "aim_lock_s")), a.windup)
	a.active = maxi(ticks(t.num(row, "active_s")), 1)
	a.recovery = ticks(t.num(row, "recovery_s"))
	a.punish = mini(ticks(t.num(row, "punish_s")), a.recovery)
	a.punish_k = t.num(row, "punish_k")
	a.cooldown = ticks(t.num(row, "cooldown_s"))
	a.damage = t.num(row, "damage")
	a.range_m = t.num(row, "range_m")
	a.min_m = t.num(row, "min_m")
	a.max_m = t.num(row, "max_m")
	a.weight = t.num(row, "weight")
	a.width_m = opt(row, "width_m", a.width_m)
	a.arc_deg = opt(row, "arc_deg", a.arc_deg)
	a.radius_m = opt(row, "radius_m", a.radius_m)
	a.move_mps = opt(row, "move_mps", a.move_mps)
	a.leap_m = opt(row, "leap_m", a.leap_m)
	var adds: Dictionary = opt_object(row, "adds")
	a.adds_archetype = StringName(str(adds.get("archetype", "")))
	a.adds_count = roundi(opt(adds, "count", 0.0))
	return a


## An optional number (JSON numbers are floats), or `fallback`.
static func opt(row: Dictionary, key: String, fallback: float) -> float:
	var v: Variant = row.get(key)
	return v if v is float else fallback


## An optional object, or {}.
static func opt_object(row: Dictionary, key: String) -> Dictionary:
	var v: Variant = row.get(key)
	return v if v is Dictionary else {}


static func ticks(seconds: float) -> int:
	return roundi(seconds / SimClock.TICK_DT)


## Windup + active + recovery, in ticks.
func length() -> int:
	return windup + active + recovery


## True when Rivet at `dist_m` is in the band this attack is picked for.
func fits(dist_m: float) -> bool:
	return dist_m >= min_m and dist_m <= max_m
