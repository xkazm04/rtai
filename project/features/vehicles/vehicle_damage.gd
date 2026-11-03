class_name VehicleDamage
extends RefCounted
## The shared damage and run-over rules (vehicle_handling.json `damage` + `kill_at`) and the
## mass-based impact: two bodies closing along a contact normal exchange the impulse
## j = (1 + e) * v_close / (1 / m1 + 1 / m2); each takes hp from its own speed change above
## dv_min, so a van hitting a hatchback wrecks the hatchback first. Two damage states, then a wreck.

const RESTITUTION: float = 0.25

var hp: float = 100.0
var d1_at: float = 30.0
var d2_at: float = 65.0
var dv_min: float = 3.0
var per_dv: float = 3.5
var ram_per_dv: float = 5.5
var wreck_s: float = 45.0
var kill_at: float = 4.0


static func load_rules(path: String = VehicleProfile.TABLE) -> VehicleDamage:
	var r: VehicleDamage = VehicleDamage.new()
	var t: DataTable = DataTable.open(path, VehicleProfile.SCHEMA)
	var d: Dictionary = t.object(t.raw, "damage")
	for f: String in ["hp", "d1_at", "d2_at", "dv_min", "per_dv", "ram_per_dv", "wreck_s"]:
		r.set(f, t.num(d, f))
	r.kill_at = t.num(t.raw, "kill_at")
	if not t.ok():
		Log.error("vehicles", str(t.errors()))
	return r


## hp lost for one speed change (m/s); ram = car against car.
func damage_for(dv: float, ram: bool = false) -> float:
	return maxf(0.0, dv - dv_min) * (ram_per_dv if ram else per_dv)


## The damage state for hp lost (the soul-hijack flag shows only on an undamaged body).
func state_for(lost: float, soul: bool) -> VehicleBody.State:
	if lost >= hp:
		return VehicleBody.State.WRECK
	if lost >= d2_at:
		return VehicleBody.State.D2
	if lost >= d1_at:
		return VehicleBody.State.D1
	return VehicleBody.State.HIJACKED if soul else VehicleBody.State.INTACT


## Adds hp lost to a body and moves its state on; true when this hit wrecked it.
func hurt(body: VehicleBody, dv: float, ram: bool = false) -> bool:
	var was: VehicleBody.State = body.state
	body.hp_lost += damage_for(dv, ram)
	body.state = state_for(body.hp_lost, body.soul_hijacked)
	return body.state == VehicleBody.State.WRECK and was != VehicleBody.State.WRECK


## Mass-based impulse between a and b along n (unit, from a to b). b_vel is b's velocity; b may
## be a sim car (b_body null, its velocity change is returned for the caller). Returns
## [dv_a, dv_b] (speed changes, m/s), and changes a.vel (and b_body.vel when given).
func collide(
	a: VehicleBody, b_vel: Vector2, b_mass: float, n: Vector2, b_body: VehicleBody
) -> Vector2:
	var close: float = (a.vel - b_vel).dot(n)
	if close <= 0.0:
		return Vector2.ZERO
	var j: float = (1.0 + RESTITUTION) * close / (1.0 / a.profile.mass + 1.0 / b_mass)
	var dva: float = j / a.profile.mass
	var dvb: float = j / b_mass
	a.vel -= n * dva
	if b_body != null:
		b_body.vel += n * dvb
	return Vector2(dva, dvb)
