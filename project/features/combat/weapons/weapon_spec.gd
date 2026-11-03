class_name WeaponSpec
extends RefCounted
## One weapons.json row (gtai.weapons/1) as typed fields, times already in 60 Hz ticks (SIM-01)
## and angles in radians. Read-only once built; the tuning panel builds a fresh one.

enum Kind { BULLET, CONE, ROCKET, BOLT, THROWN }

const KINDS: Dictionary[String, Kind] = {
	"bullet": Kind.BULLET,
	"cone": Kind.CONE,
	"rocket": Kind.ROCKET,
	"bolt": Kind.BOLT,
	"thrown": Kind.THROWN,
}

var id: StringName = &""
var tier: StringName = &""
var kind: Kind = Kind.BULLET
var enabled: bool = true
var auto: bool = false
var hit_class: StringName = &"light"
var damage: float = 0.0
var interval_ticks: int = 1
var speed_mps: float = 30.0
var range_m: float = 20.0
var spread_rad: float = 0.0
var bloom_rad: float = 0.0
var bloom_max_rad: float = 0.0
var bloom_recover_per_tick: float = 0.0
var magazine: int = 0
var reload_ticks: int = 0
var pellets: int = 1
var splash_damage: float = 0.0
var splash_radius_m: float = 0.0
var dot_dps: float = 0.0
var dot_ticks: int = 0
var patch_radius_m: float = 0.0
var patch_ticks: int = 0
var chain_hops: int = 0
var chain_radius_m: float = 0.0
var stun_ticks: int = 0
var knockback_mps: float = 0.0
var tracer_len_m: float = 0.0
## Display scale of the held gun in the claw (REQUEST 9 -> rivet-motion reads it; 1.0 = model size).
var held_scale: float = 1.0


static func from_row(t: DataTable, row: Dictionary) -> WeaponSpec:
	var w: WeaponSpec = WeaponSpec.new()
	w.id = StringName(t.text(row, "id"))
	w.tier = StringName(t.text(row, "tier"))
	w.kind = KINDS.get(t.text(row, "kind"), Kind.BULLET)
	w.enabled = row.get("enabled", true) == true
	w.auto = t.text(row, "fire_mode") == "auto"
	w.hit_class = StringName(t.text(row, "hit_class"))
	w.damage = t.num(row, "damage")
	w.interval_ticks = maxi(roundi(SimClock.TICK_RATE / maxf(t.num(row, "rof_hz"), 0.01)), 1)
	w.speed_mps = t.num(row, "speed_mps")
	w.range_m = t.num(row, "range_m")
	w.spread_rad = deg_to_rad(t.num(row, "spread_deg"))
	w.bloom_rad = deg_to_rad(t.num(row, "spread_bloom_deg"))
	w.bloom_max_rad = deg_to_rad(t.num(row, "spread_max_deg"))
	w.bloom_recover_per_tick = deg_to_rad(t.num(row, "spread_recover_dps")) * SimClock.TICK_DT
	w.magazine = t.integer(row, "magazine")
	w.reload_ticks = ticks(t.num(row, "reload_s"))
	w.pellets = maxi(t.integer(row, "pellets"), 1)
	w.splash_damage = t.num(row, "splash_damage")
	w.splash_radius_m = t.num(row, "splash_radius_m")
	w.dot_dps = t.num(row, "dot_dps")
	w.dot_ticks = ticks(t.num(row, "dot_s"))
	w.patch_radius_m = t.num(row, "patch_radius_m")
	w.patch_ticks = ticks(t.num(row, "patch_s"))
	w.chain_hops = t.integer(row, "chain_hops")
	w.chain_radius_m = t.num(row, "chain_radius_m")
	w.stun_ticks = ticks(t.num(row, "stun_s"))
	w.knockback_mps = t.num(row, "knockback_mps")
	w.tracer_len_m = t.num(row, "tracer_len_m")
	w.held_scale = t.num(row, "held_scale") if row.has("held_scale") else 1.0
	return w


static func ticks(seconds: float) -> int:
	return ceili(seconds * SimClock.TICK_RATE - SimClock.EPSILON)
