class_name ArcBall
extends RefCounted
## The Robo-tazer's shot: a slow, fat ball of arc that bends slightly toward metal (Rivet first,
## when he is in sense range, else the nearest metal prop) and bursts on Rivet, on metal, or at
## the end of its life. The burst chains to the metal around it (chain_radius_m, chain_hops);
## Rivet is hit when the burst or a chained arc reaches him. A zigzag tether trails to the muzzle.

var pos: Vector2 = Vector2.ZERO
var vel: Vector2 = Vector2.ZERO
var muzzle: Vector2 = Vector2.ZERO
var age: int = 0
var burst: bool = false
## The burst's arc path, impact first (for the VFX); empty until it bursts.
var arcs: Array[Vector2] = []
var hit_rivet: bool = false
var _t: Dictionary[String, float] = {}


static func launch(from: Vector2, toward: Vector2, tuning: CombatTuning) -> ArcBall:
	var b: ArcBall = ArcBall.new()
	b._t = tuning.tazer
	b.pos = from
	b.muzzle = from
	b.vel = (toward - from).normalized() * b._t["ball_speed_mps"]
	return b


## One tick of flight; bursts (and resolves the chain) when it touches Rivet or metal.
func step(rivet: Vector2, rivet_r: float, metal: PackedVector2Array) -> void:
	if burst:
		return
	age += 1
	var aim: Vector2 = _metal_target(rivet, metal)
	if aim != Vector2.INF:
		var turn: float = deg_to_rad(_t["homing_deg_per_s"]) * SimClock.TICK_DT
		var want: float = vel.angle_to(aim - pos)
		vel = vel.rotated(clampf(want, -turn, turn))
	pos += vel * SimClock.TICK_DT
	var r: float = _t["ball_radius_m"]
	var touched: bool = pos.distance_to(rivet) <= r + rivet_r or _touches(metal, r + 0.3)
	if touched or age >= CombatTuning.ticks(_t["ball_life_s"]):
		_burst(rivet, metal)


func _metal_target(rivet: Vector2, metal: PackedVector2Array) -> Vector2:
	var sense: float = _t["metal_sense_m"]
	if pos.distance_to(rivet) <= sense:
		return rivet
	var best: Vector2 = Vector2.INF
	for m: Vector2 in metal:
		if pos.distance_to(m) <= sense and pos.distance_to(m) < pos.distance_to(best):
			best = m
	return best


func _touches(metal: PackedVector2Array, r: float) -> bool:
	for m: Vector2 in metal:
		if pos.distance_to(m) <= r:
			return true
	return false


## The arcs hop from the impact to the nearest unvisited metal (Rivet included) in reach.
func _burst(rivet: Vector2, metal: PackedVector2Array) -> void:
	burst = true
	arcs.append(pos)
	var reach: float = _t["chain_radius_m"]
	var pool: Array[Vector2] = [rivet]
	for m: Vector2 in metal:
		pool.append(m)
	var at: Vector2 = pos
	for _hop: int in roundi(_t["chain_hops"]):
		var next: int = -1
		for i: int in pool.size():
			var d: float = at.distance_to(pool[i])
			if d <= reach and (next < 0 or d < at.distance_to(pool[next])):
				next = i
		if next < 0:
			break
		at = pool[next]
		arcs.append(at)
		hit_rivet = hit_rivet or at == rivet
		pool.remove_at(next)
