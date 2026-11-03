class_name MeleeShock
extends RefCounted
## Rivet's charged electroshock on the fixed tick (rivet_melee.json `shock`): holding melee
## charges from 0; a release before `charge_min_ticks` is a tap (the claw combo takes it), a
## release after it discharges: the stun scales with the charge, then the arc hops to the nearest
## metal target within `chain_radius_m` of the last one, up to `chain_hops` times.

var charge_min: int = 12
var charge_full: int = 54
var stun_min: int = 60
var stun_full: int = 150
var reach_m: float = 1.6
var chain_radius_m: float = 3.0
var chain_hops: int = 3
var charge: int = 0
var held: bool = false


static func from_row(t: DataTable, row: Dictionary) -> MeleeShock:
	var s: MeleeShock = MeleeShock.new()
	s.charge_min = t.integer(row, "charge_min_ticks")
	s.charge_full = maxi(t.integer(row, "charge_full_ticks"), s.charge_min + 1)
	s.stun_min = t.integer(row, "stun_min_ticks")
	s.stun_full = t.integer(row, "stun_full_ticks")
	s.reach_m = t.num(row, "reach_m")
	s.chain_radius_m = t.num(row, "chain_radius_m")
	s.chain_hops = t.integer(row, "chain_hops")
	return s


## One tick of the melee button. Returns the stun ticks of a discharge on this tick, 0 for
## nothing (still charging, idle) and -1 for a tap released before the charge threshold.
func step(down: bool) -> int:
	if down:
		held = true
		charge = mini(charge + 1, charge_full)
		return 0
	if not held:
		return 0
	held = false
	var c: int = charge
	charge = 0
	if c < charge_min:
		return -1
	return roundi(lerpf(stun_min, stun_full, charge01(c)))


## 0..1 between the threshold and full charge (the rig's glow and the HUD ring read it).
func charge01(c: int = -1) -> float:
	var v: int = charge if c < 0 else c
	return clampf(float(v - charge_min) / float(charge_full - charge_min), 0.0, 1.0)


## The arc's path: from `first`, hop to the nearest unvisited metal target within the chain
## radius of the last one. Returns the indices hit, `first` included.
func chain(pos: PackedVector2Array, metal: PackedByteArray, first: int) -> PackedInt32Array:
	return chain_path(pos, metal, first, chain_hops, chain_radius_m)


## The shared arc walk: the charged shock and a weapon hit with chain_hops (the electro baton's
## finisher, MeleeTable.chain_for) both hop through it.
static func chain_path(
	pos: PackedVector2Array, metal: PackedByteArray, first: int, hops: int, radius_m: float
) -> PackedInt32Array:
	var hit: PackedInt32Array = PackedInt32Array([first])
	var at: Vector2 = pos[first]
	for _h: int in hops:
		var best: int = -1
		var best_d: float = radius_m
		for i: int in pos.size():
			var d: float = pos[i].distance_to(at)
			if metal[i] != 0 and not hit.has(i) and d <= best_d:
				best = i
				best_d = d
		if best < 0:
			break
		@warning_ignore("return_value_discarded")
		hit.append(best)
		at = pos[best]
	return hit
