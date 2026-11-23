class_name EnemyWeapon
extends RefCounted
## One enemies.json weapon, with durations converted to simulation ticks.

var id: StringName = &""
var round: StringName = &"small"
var splash_radius_m: float = 0.0
var splash_damage: float = 0.0
var melee: bool = false
var relocate_after_shots: int = 0
var aim_lead: float = 0.0
var burst: int = 1
var burst_gap_ticks: int = 0
var cooldown_ticks: int = 60
var pellets: int = 1
var spread_rad: float = 0.0
var damage: float = 1.0
var knockback_m: float = 0.0
var reach_m: float = 10.0
var speed_mps: float = 20.0
## melee only: the dash after the windup (0 = none), along the locked aim
var lunge_m: float = 0.0
var lunge_mps: float = 0.0


func read(t: DataTable, weapon_id: StringName, row: Dictionary) -> void:
	id = weapon_id
	if row.has("round"):
		round = StringName(t.text(row, "round"))
	splash_radius_m = t.num(row, "splash_radius_m") if row.has("splash_radius_m") else 0.0
	splash_damage = t.num(row, "splash_damage") if row.has("splash_damage") else 0.0
	melee = row.get("melee", false) == true
	if row.has("relocate_after_shots"):
		relocate_after_shots = t.integer(row, "relocate_after_shots")
	if row.has("aim_lead"):
		aim_lead = t.num(row, "aim_lead")
	burst = t.integer(row, "burst")
	burst_gap_ticks = CombatTuning.ticks(t.num(row, "burst_gap_s"))
	cooldown_ticks = CombatTuning.ticks(t.num(row, "cooldown_s"))
	damage = t.num(row, "damage")
	pellets = t.integer(row, "pellets") if row.has("pellets") else 1
	spread_rad = deg_to_rad(t.num(row, "spread_deg")) if row.has("spread_deg") else 0.0
	knockback_m = t.num(row, "knockback_m") if row.has("knockback_m") else 0.0
	reach_m = t.num(row, "reach_m")
	speed_mps = t.num(row, "speed_mps")
	lunge_m = t.num(row, "lunge_m") if row.has("lunge_m") else 0.0
	lunge_mps = t.num(row, "lunge_mps") if row.has("lunge_mps") else 0.0
