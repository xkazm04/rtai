class_name GunHand
extends RefCounted
## The bridge from the weapon table to the arena's combat (CombatArena.gun): Rivet's held gun as
## a Trigger (semi on the press edge, bloom that recovers, magazine, reload) whose shots fly as
## CombatArena Shots with the row's speed, range and spread. Damage converts from table hp
## points (a human is target_hp.human) into Fighter hp (a human is 1). Null in quest 1, so the
## quest's own weapons and goldens stay as they are.

## A homing round leaves the claw splayed this far off the aim, alternating sides shot by shot,
## and curves back onto its target: the shard gun's swarm reads in every shot (DECISION 2026-11-04;
## 0 = straight out).
const HOMING_FAN_RAD: float = 0.35

var trigger: Trigger
var shots_fired: int = 0
## A bot's held fire button: a semi gun re-taps as soon as it is ready (dev scenes and bots
## only; a player's semi gun needs a new press).
var tap: bool = false
var _hp_scale: float = 0.01
var _rng: RandomNumberGenerator
var _pulled: bool = false


static func make(table: WeaponTable, weapon: StringName, rng: RandomNumberGenerator) -> GunHand:
	var g: GunHand = GunHand.new()
	g.trigger = Trigger.new(table.weapon(weapon))
	var human_hp: float = table.target_hp.get(&"human", 100.0)
	g._hp_scale = 1.0 / maxf(human_hp, 1.0)
	g._rng = rng
	return g


## The fire button is held this tick, aiming at `at`; returns the shots that leave (maybe none).
func pull(shooter: Fighter, at: Vector2) -> Array[Shot]:
	_pulled = true
	var out: Array[Shot] = []
	var aim: Vector2 = (at - shooter.pos).normalized()
	if tap and trigger.cooldown == 0 and not trigger.reloading():
		@warning_ignore("return_value_discarded")
		trigger.pull(false)
	if aim == Vector2.ZERO or not trigger.pull(true):
		return out
	var w: WeaponSpec = trigger.spec
	for i: int in w.pellets:
		var dir: Vector2 = trigger.shot_dir(aim, _rng)
		if w.homing_rad_per_tick > 0.0:
			dir = dir.rotated(HOMING_FAN_RAD * (1.0 if shots_fired % 2 == 0 else -1.0))
		var s: Shot = Shot.new()
		s.pos = shooter.pos + dir * (shooter.radius_m + 0.1)
		s.vel = dir * w.speed_mps
		s.from_rivet = true
		s.weapon = w.id
		s.damage = w.damage * _hp_scale
		s.left_m = w.range_m
		s.shooter_id = shooter.id
		s.spec = w
		s.origin = s.pos
		if w.kind == WeaponSpec.Kind.THROWN or w.kind == WeaponSpec.Kind.ROCKET:
			# Bottles land and rockets burst at the aimed point (or the first body, for rockets).
			s.left_m = clampf(shooter.pos.distance_to(at), 1.0, w.range_m)
		out.append(s)
	trigger.add_bloom()
	shots_fired += 1
	shooter.facing = aim
	return out


## Table hp points -> Fighter hp (a human of target_hp.human is 1).
func hp_scale() -> float:
	return _hp_scale


## Once per tick after the pulls: a tick without a pull is a release (semi needs the edge), then
## the trigger's cooldown, bloom and reload advance.
func settle() -> void:
	if not _pulled:
		@warning_ignore("return_value_discarded")
		trigger.pull(false)
	_pulled = false
	trigger.step()
