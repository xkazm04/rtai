class_name SquadCostSections
extends ArenaSquad
## Probe-only timing of the calls in ArenaSquad.step. Use a separate replay so clock reads
## and counter writes never enter the normal step or the headline hostile/tick samples.

var assign_us: int
var sight_us: int
var plan_us: int
var neighbour_us: int
var motor_us: int
var swing_us: int


func assign(arena: CombatArena) -> Array[Fighter]:
	var start: int = Time.get_ticks_usec()
	var order: Array[Fighter] = super.assign(arena)
	assign_us += Time.get_ticks_usec() - start
	return order


func step(h: Fighter, arena: CombatArena, rng: RandomNumberGenerator) -> Shot:
	var mind: SquadMind = minds[h.id]
	var e: EnemyAgent = mind.agent
	var start: int = Time.get_ticks_usec()
	e.pos = h.pos
	e.sees = _map.sight_line(e.pos, pit.rivet_pos)
	sight_us += Time.get_ticks_usec() - start
	start = Time.get_ticks_usec()
	var desired: Vector2 = mind.velocity(pit, _map, _fallen)
	if h.swing_left > 0:
		desired = Vector2.ZERO
	plan_us += Time.get_ticks_usec() - start
	start = Time.get_ticks_usec()
	if not plant_no_separation:
		var gap: float = EnemyMotor.SEPARATION_GAP_M if e.melee() else SquadMind.SPACING_GAP_M
		desired += EnemyMotor.separation(e, pit.agents, pit, gap, true)
	neighbour_us += Time.get_ticks_usec() - start
	start = Time.get_ticks_usec()
	EnemyMotor.steer(e, desired, pit.rivet_pos, pit)
	h.pos = e.pos
	h.facing = e.facing
	motor_us += Time.get_ticks_usec() - start
	start = Time.get_ticks_usec()
	var shot: Shot
	if e.melee():
		mind.swing(h, arena, _map)
	else:
		shot = _ranged(mind, h, arena, rng)
	swing_us += Time.get_ticks_usec() - start
	return shot


func totals() -> Dictionary:
	return {
		"assign": assign_us,
		"sight": sight_us,
		"plan": plan_us,
		"neighbour": neighbour_us,
		"motor": motor_us,
		"swing": swing_us,
	}
