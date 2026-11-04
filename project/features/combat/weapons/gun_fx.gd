class_name GunFx
extends RefCounted
## Lane gunplay: what a table bullet gun leaves in the real fight, per weapon (gun_fx.json):
## ejected shells that hop, bounce and lie, an empty magazine dropped on a reload, gun smoke
## that drifts and fades, and where a round stops: dust and a scuff on the ground, sparks on
## metal (crates, railings) and on Rivet's plating (an enemy round that hit him), an ink burst
## on a body. Presentation only: stepped on the stage tick by the view, never by the sim, and
## varied by a hash of the shot count (no RNG stream). GunFxArt draws it.

enum Hit { GROUND, METAL, BODY, PLATING }

const PARAMS: String = "res://features/combat/weapons/gun_fx.json"
const MAX_BITS: int = 48
const HOP_TICKS: int = 14
const IMPACT_TICKS: int = 10
const SCUFF_TICKS: int = 240
const SMOKE_TICKS: int = 28

var p: Dictionary = {}
## Shells and dropped magazines: x, y (m), the ticks they lie before fading, the size (m;
## < 0 = a magazine); bit_life = their age in ticks.
var bits: Array[Vector4] = []
var bit_vel: PackedVector2Array = PackedVector2Array()
var bit_life: PackedInt32Array = PackedInt32Array()
## Where rounds stopped: x, y, Hit, the born tick; and the round's travel direction.
var impacts: Array[Vector4] = []
var impact_dir: PackedVector2Array = PackedVector2Array()
## Gun smoke: x, y, the born tick, the scale.
var smoke: Array[Vector4] = []
## The last tick a round left Rivet's gun (the muzzle flash reads it).
var fired_tick: int = -100
var fired_count: int = 0
var _seen_fired: int = 0
var _was_reloading: bool = false
var _last_tick: int = -1
var _shots: Dictionary = {}


func _init() -> void:
	p = NoirLook.read_params(PARAMS)


## The presentation row of a weapon (gun_fx.json weapons.<id>, else default).
func look(weapon: StringName) -> Dictionary:
	var rows: Dictionary = p.get("weapons", {})
	return rows.get(String(weapon), p.get("default", {}))


func color(key: String) -> Color:
	var pal: Dictionary = p.get("palette", {})
	var hex: String = pal.get(key, "#f2e8d5")
	return Color(hex)


## Advance to the stage tick: new shells and smoke for every round that left, a magazine on a
## reload start, impacts for the rounds that are gone, and the shells' flight.
func step(arena: CombatArena, tick: int) -> void:
	if tick == _last_tick or arena.gun == null:
		return
	var n: int = clampi(tick - _last_tick, 1, 10)
	_last_tick = tick
	var gun: GunHand = arena.gun
	var row: Dictionary = look(gun.trigger.spec.id)
	if gun.shots_fired > _seen_fired:
		fired_tick = tick
		for k: int in mini(gun.shots_fired - _seen_fired, 3):
			_eject(arena.rivet, row, tick, gun.shots_fired - k)
		_seen_fired = gun.shots_fired
		fired_count = gun.shots_fired
	var reloading: bool = gun.trigger.reloading()
	if reloading and not _was_reloading and row.get("mag_drop", true):
		var drop: Vector2 = arena.rivet.facing.rotated(2.2) * 1.2 * SimClock.TICK_DT
		_add_bit(_claw(arena.rivet), drop, 240, -0.22)
	_was_reloading = reloading
	_track_shots(arena, tick)
	for _t: int in n:
		_fly()
	_expire(tick)


func _claw(r: Fighter) -> Vector2:
	return r.pos + r.facing.normalized() * (r.radius_m + 0.15)


func _eject(r: Fighter, row: Dictionary, tick: int, count: int) -> void:
	var f: Vector2 = r.facing.normalized()
	var h: float = NoirPack.hash01(count * 7919 + 13)
	var at: Vector2 = r.pos + f * (r.radius_m + 0.55)
	var puff: float = row.get("smoke", 0.6)
	smoke.append(Vector4(at.x, at.y, float(tick), puff))
	var size: float = row.get("casing_m", 0.0)
	if size <= 0.0:
		return
	# Shells kick out to the gun's right and a little back, 2.4-3.6 m/s.
	var v: Vector2 = (-f.orthogonal() * (2.4 + 1.2 * h) - f * (0.5 + h)) * SimClock.TICK_DT
	var lie_s: float = row.get("casing_s", 2.5)
	_add_bit(_claw(r), v, roundi(lie_s * 60.0), size)


func _add_bit(at: Vector2, v: Vector2, lie_ticks: int, size: float) -> void:
	if bits.size() >= MAX_BITS:
		bits.remove_at(0)
		bit_vel.remove_at(0)
		bit_life.remove_at(0)
	bits.append(Vector4(at.x, at.y, float(lie_ticks), size))
	@warning_ignore("return_value_discarded")
	bit_vel.append(v)
	@warning_ignore("return_value_discarded")
	bit_life.append(0)


func _fly() -> void:
	for i: int in bits.size():
		bit_life[i] += 1
		if bit_life[i] > HOP_TICKS + 10:
			continue
		bits[i].x += bit_vel[i].x
		bits[i].y += bit_vel[i].y
		# a bounce at the end of the hop loses most of the speed
		bit_vel[i] *= 0.4 if bit_life[i] == HOP_TICKS else 0.93


## Every Rivet bullet (and every enemy round) that left the fight since last tick stopped where
## it was last seen: on a body, on Rivet's plating, on metal, or on the ground.
func _track_shots(arena: CombatArena, tick: int) -> void:
	var now: Dictionary = {}
	for s: Shot in arena.shots:
		if not s.from_rivet or s.spec == null or s.spec.kind == WeaponSpec.Kind.BULLET:
			now[s] = [s.pos, s.vel * SimClock.TICK_DT, s.from_rivet]
	for s: Variant in _shots:
		if not now.has(s):
			var last: Array = _shots[s]
			_impact(arena, last, tick)
	_shots = now


## The round's last step (seen pos -> one tick on) is swept: the first body (or Rivet, for an
## enemy round) it crosses is where it stopped; else it fell at the step's end (metal near it
## sparks, the ground scuffs).
func _impact(arena: CombatArena, last: Array, tick: int) -> void:
	var from: Vector2 = last[0]
	var hop: Vector2 = last[1]
	var at: Vector2 = from + hop
	var kind: Hit = Hit.GROUND
	var bodies: Array[Fighter] = [arena.rivet]
	if last[2]:
		bodies = arena.hostiles
	for h: Fighter in bodies:
		var c: Vector2 = Geometry2D.get_closest_point_to_segment(h.pos, from, from + hop)
		if c.distance_to(h.pos) <= h.radius_m + 0.3:
			kind = Hit.BODY if last[2] else Hit.PLATING
			at = c
			break
	if kind == Hit.GROUND:
		for m: Vector2 in arena.metal:
			if m.distance_to(at) <= 0.9:
				kind = Hit.METAL
	impacts.append(Vector4(at.x, at.y, float(kind), float(tick)))
	@warning_ignore("return_value_discarded")
	impact_dir.append(hop.normalized())


func _expire(tick: int) -> void:
	while not impacts.is_empty() and tick - int(impacts[0].w) > SCUFF_TICKS:
		impacts.remove_at(0)
		impact_dir.remove_at(0)
	while not smoke.is_empty() and tick - int(smoke[0].z) > SMOKE_TICKS:
		smoke.remove_at(0)
	for i: int in range(bits.size() - 1, -1, -1):
		if bit_life[i] > int(bits[i].z) + 30:
			bits.remove_at(i)
			bit_vel.remove_at(i)
			bit_life.remove_at(i)
