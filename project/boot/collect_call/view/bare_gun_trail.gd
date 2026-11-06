class_name BareGunTrail
extends RefCounted
## n7-ranged it24: the shot trail (WeaponFxTrail) for Rivet's spec-less rounds, quest 1's picked-up
## assault rifle, which fires on combat.json's path with no GunFx to see its rounds stop. Each
## view tick it remembers the stand-in rounds in flight; a round gone since the last tick whose
## last step crossed a hostile leaves a trail from where it left the gun to the wound, for the
## stand-in's hit_feel.json `trail_ticks` (BareGunFx: assault-rifle draws as machine_pistol).
## Render only: reads the arena, writes nothing (quest 1's replay holds). Off: the trail's own
## switches (`--shot-trail=off`, `--feel=off`) or `--weapon-fx=shapes` (no stand-in).

## Hits within this of a body's radius count (GunFxRounds' body sweep).
const HIT_PAD_M: float = 0.3

var trails: Array[WeaponFxTrail.Trail] = []
## Shot -> [last pos, the step it makes per tick, where it left the gun, the stand-in id].
var _seen: Dictionary = {}
var _last_tick: int = -1


## Advance to `tick`: trails for the stand-in rounds that stopped in a hostile since last tick.
func step(arena: CombatArena, tick: int) -> void:
	if tick == _last_tick:
		return
	_last_tick = tick
	var now: Dictionary = {}
	for s: Shot in arena.shots:
		var id: StringName = BareGunFx.stand_in(s)
		if id == &"" or not arena.tuning.weapons.has(s.weapon):
			continue
		var w: CombatTuning.Weapon = arena.tuning.weapon(s.weapon)
		var flew: float = maxf(w.range_m - s.left_m, 0.0)
		var from: Vector2 = s.pos - s.vel.normalized() * flew
		now[s] = [s.pos, s.vel * SimClock.TICK_DT, from, id]
	for s: Variant in _seen:
		if not now.has(s):
			var last: Array = _seen[s]
			_stopped(arena, last, tick)
	_seen = now
	WeaponFxTrail.expire(trails, tick)


func draw(ci: CanvasItem) -> void:
	WeaponFxTrail.draw(ci, trails, _last_tick)


func _stopped(arena: CombatArena, last: Array, tick: int) -> void:
	var at: Vector2 = last[0]
	var hop: Vector2 = last[1]
	var from: Vector2 = last[2]
	var id: StringName = last[3]
	for h: Fighter in arena.hostiles:
		var c: Vector2 = Geometry2D.get_closest_point_to_segment(h.pos, at, at + hop)
		if c.distance_to(h.pos) <= h.radius_m + HIT_PAD_M:
			WeaponFxTrail.add(trails, from, c, id, tick)
			return
