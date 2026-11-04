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
## A hostile's shot leaving its gun: x, y (m), the born tick, the aim angle (the cops' muzzle).
var enemy_flashes: Array[Vector4] = []
## The last tick a round left Rivet's gun (the muzzle flash reads it).
var fired_tick: int = -100
var fired_count: int = 0
## Rounds seen last tick (GunFxRounds): Shot -> [pos, step, from_rivet].
var shots_seen: Dictionary = {}
var _seen_fired: int = 0
var _was_reloading: bool = false
var _last_tick: int = -1


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
	if reloading and not _was_reloading:
		_reload_drop(arena.rivet, row)
	_was_reloading = reloading
	GunFxRounds.track(self, arena, tick)
	for _t: int in n:
		_fly()
	_expire(tick)


func _claw(r: Fighter) -> Vector2:
	return muzzle(r, 0.15)


## A point `ahead_m` past Rivet's body along the aim, on his gun claw's side (claw_side_m: the
## rig holds the gun right of the centre line, so the flash, smoke and shells leave the claw).
func muzzle(r: Fighter, ahead_m: float) -> Vector2:
	var f: Vector2 = r.facing.normalized()
	var side: float = p.get("claw_side_m", 0.0)
	return r.pos + f * (r.radius_m + ahead_m) - f.orthogonal() * side


func _eject(r: Fighter, row: Dictionary, tick: int, count: int) -> void:
	var f: Vector2 = r.facing.normalized()
	var h: float = NoirPack.hash01(count * 7919 + 13)
	var at: Vector2 = muzzle(r, 0.55)
	var puff: float = row.get("smoke", 0.6)
	smoke.append(Vector4(at.x, at.y, float(tick), puff))
	var size: float = row.get("casing_m", 0.0)
	if size <= 0.0 or row.get("dump", 0) > 0:
		return
	# Shells kick out to the gun's right and a little back, 2.4-3.6 m/s.
	var v: Vector2 = (-f.orthogonal() * (2.4 + 1.2 * h) - f * (0.5 + h)) * SimClock.TICK_DT
	var lie_s: float = row.get("casing_s", 2.5)
	add_bit(_claw(r), v, roundi(lie_s * 60.0), size)


## A reload starts: an empty magazine falls from the claw (mag_drop), or a revolver dumps its
## spent shells all at once (dump = how many; they fan out under the claw).
func _reload_drop(r: Fighter, row: Dictionary) -> void:
	if row.get("mag_drop", true):
		add_bit(_claw(r), r.facing.rotated(2.2) * 1.2 * SimClock.TICK_DT, 240, -0.22)
	var dump: int = row.get("dump", 0)
	var size: float = row.get("casing_m", 0.0)
	var lie_s: float = row.get("casing_s", 3.0)
	for k: int in dump:
		var a: float = 1.6 + 1.4 * float(k) / maxf(float(dump - 1), 1.0)
		var v: Vector2 = r.facing.rotated(a) * (0.8 + 0.25 * float(k % 3)) * SimClock.TICK_DT
		add_bit(_claw(r), v, roundi(lie_s * 60.0), size)


func add_bit(at: Vector2, v: Vector2, lie_ticks: int, size: float) -> void:
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


func _expire(tick: int) -> void:
	while not impacts.is_empty() and tick - int(impacts[0].w) > SCUFF_TICKS:
		impacts.remove_at(0)
		impact_dir.remove_at(0)
	while not enemy_flashes.is_empty() and tick - int(enemy_flashes[0].z) > 3:
		enemy_flashes.remove_at(0)
	while not smoke.is_empty() and tick - int(smoke[0].z) > SMOKE_TICKS:
		smoke.remove_at(0)
	for i: int in range(bits.size() - 1, -1, -1):
		if bit_life[i] > int(bits[i].z) + 30:
			bits.remove_at(i)
			bit_vel.remove_at(i)
			bit_life.remove_at(i)
