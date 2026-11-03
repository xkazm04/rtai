class_name VehicleContacts
extends RefCounted
## Contacts of one service car per tick: the hull against solid cells (push out, bounce, damage
## from the speed lost), against sim traffic and other service cars (two circles per car, the
## mass-based impulse of VehicleDamage), and against people in the footprint (a kill above
## kill_at, else a knockdown). Results land in the public lists for the service to emit.

const HALF_L: float = 2.3
const HALF_W: float = 0.95
const CIRCLE_OFF: float = 1.25
const CIRCLE_R: float = 1.05
const WALL_E: float = 0.2

## Sim slots this tick: people struck [slot, killed 0/1] pairs, and traffic speed changes.
var struck: PackedInt32Array = PackedInt32Array()
var traffic_hits: Dictionary[int, float] = {}
var _rules: VehicleDamage
var _profiles: Dictionary[StringName, VehicleProfile]


func _init(rules: VehicleDamage, profiles: Dictionary[StringName, VehicleProfile]) -> void:
	_rules = rules
	_profiles = profiles


func begin() -> void:
	struck.clear()
	traffic_hits.clear()


## Six hull points against solid cells: push out along the shallowest axis, bounce the normal
## velocity, hurt the body by the normal speed it lost.
func hull(b: VehicleBody, world: VehicleWorld) -> void:
	var right: Vector2 = Vector2(-b.head.y, b.head.x)
	for p: int in 6:
		var f: float = HALF_L if p < 2 else (-HALF_L if p < 4 else 0.0)
		var s: float = HALF_W if (p % 2) == 0 else -HALF_W
		var q: Vector2 = b.pos + b.head * f + right * s
		if not world.solid(q.x, q.y):
			continue
		var n: Vector2 = _push_axis(q)
		b.pos += n * (_depth(q, n) + 0.01)
		var vn: float = b.vel.dot(n)
		if vn < 0.0:
			b.vel -= n * vn * (1.0 + WALL_E)
			@warning_ignore("return_value_discarded")
			_rules.hurt(b, -vn * (1.0 + WALL_E))


## Against every sim car near b: separate, exchange the impulse, record the traffic car's dv.
func traffic(b: VehicleBody, world: VehicleWorld) -> void:
	var recs: PackedFloat64Array = world.cars_near(b.pos, 7.0)
	for r: int in range(0, recs.size(), VehicleWorld.CAR_STRIDE):
		var slot: int = int(recs[r])
		var at: Vector2 = Vector2(recs[r + 2], recs[r + 3])
		var head: Vector2 = Vector2(recs[r + 4], recs[r + 5])
		var n: Vector2 = _overlap(b.pos, b.head, at, head)
		if n == Vector2.ZERO:
			continue
		var kind: StringName = VehicleProfile.archetype_of_variant(
			int(recs[r + 7]), recs[r + 1] > 0.5
		)
		var mass: float = _mass_of(kind)
		var dv: Vector2 = _rules.collide(b, head * recs[r + 6], mass, n, null)
		@warning_ignore("return_value_discarded")
		_rules.hurt(b, dv.x)
		if dv.y > 0.0:
			var was: float = traffic_hits.get(slot, 0.0)
			traffic_hits[slot] = maxf(was, dv.y)


## Two service cars (a driven car into a parked one, or into a wreck).
func pair(a: VehicleBody, b: VehicleBody) -> void:
	var n: Vector2 = _overlap(a.pos, a.head, b.pos, b.head)
	if n == Vector2.ZERO:
		return
	b.pos += n * 0.05
	var dv: Vector2 = _rules.collide(a, b.vel, b.profile.mass, n, b)
	@warning_ignore("return_value_discarded")
	_rules.hurt(a, dv.x)
	@warning_ignore("return_value_discarded")
	_rules.hurt(b, dv.y)


## People inside the footprint of a moving car: killed above kill_at, else knocked aside.
func people(b: VehicleBody, world: VehicleWorld) -> void:
	var v: float = b.speed()
	if v < 1.0:
		return
	var recs: PackedFloat64Array = world.people_near(b.pos, 4.0)
	for r: int in range(0, recs.size(), VehicleWorld.PERSON_STRIDE):
		if recs[r + 3] > 0.5:
			continue
		var rel: Vector2 = Vector2(recs[r + 1], recs[r + 2]) - b.pos
		var f: float = rel.dot(b.head)
		var s: float = rel.dot(Vector2(-b.head.y, b.head.x))
		if absf(f) >= HALF_L + 0.3 or absf(s) >= HALF_W + 0.3:
			continue
		var slot: int = int(recs[r])
		var killed: bool = world.strike_person(slot, b.vel, v > _rules.kill_at)
		struck.append_array([slot, 1 if killed else 0])
		b.vel *= 0.93


## The contact normal (unit, from a to b) when the two cars' circle pairs overlap, else zero.
## Separates a by the deepest overlap.
func _overlap(pa: Vector2, ha: Vector2, pb: Vector2, hb: Vector2) -> Vector2:
	var best: float = 0.0
	var n: Vector2 = Vector2.ZERO
	for i: int in 2:
		var ca: Vector2 = pa + ha * (CIRCLE_OFF if i == 0 else -CIRCLE_OFF)
		for j: int in 2:
			var cb: Vector2 = pb + hb * (CIRCLE_OFF if j == 0 else -CIRCLE_OFF)
			var d: Vector2 = cb - ca
			var l: float = d.length()
			var depth: float = 2.0 * CIRCLE_R - l
			if depth > best and l > 1e-6:
				best = depth
				n = d / l
	return n


func _mass_of(kind: StringName) -> float:
	var p: VehicleProfile = _profiles.get(kind, null)
	return p.mass if p != null else 1450.0


## The outward axis of the shallowest cell face at q.
static func _push_axis(q: Vector2) -> Vector2:
	var fx: float = q.x - floorf(q.x)
	var fy: float = q.y - floorf(q.y)
	var m: float = minf(minf(fx, 1.0 - fx), minf(fy, 1.0 - fy))
	if m == fx:
		return Vector2.LEFT
	if m == 1.0 - fx:
		return Vector2.RIGHT
	if m == fy:
		return Vector2.UP
	return Vector2.DOWN


static func _depth(q: Vector2, n: Vector2) -> float:
	var fx: float = q.x - floorf(q.x)
	var fy: float = q.y - floorf(q.y)
	if n == Vector2.LEFT:
		return fx
	if n == Vector2.RIGHT:
		return 1.0 - fx
	if n == Vector2.UP:
		return fy
	return 1.0 - fy
