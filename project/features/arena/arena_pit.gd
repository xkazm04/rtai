class_name ArenaPit
extends RefCounted
## The pit's waves: once Rivet is inside the pit (trigger_inset_m in from its edge) and no pit
## guard is standing, the next wave comes after gap_s: first_wave guards, grow more each wave, up
## to max_wave, each at the pit's "enemy" spawn points in turn (CombatArena.spawn_guard spreads
## them). They are the real GuardBrain contractors with their real rifles. Rivet's death clears
## the pit and starts it again from wave 1. Numbers: arena.json "pit".

var points: Array[Vector2] = []
var zone: Rect2 = Rect2()
var first_wave: int = 2
var grow: int = 1
var max_wave: int = 5
var gap_ticks: int = 150
var wave: int = 0
var kills: int = 0
var waves_cleared: int = 0
var standing: Array[Fighter] = []
var _due_tick: int = -1


static func from_plan(
	plan: ArenaPlan, stations: ArenaStations, cells: StageCells = null
) -> ArenaPit:
	var p: ArenaPit = ArenaPit.new()
	var rule: Dictionary = plan.pit
	var area: ArenaPlan.Area = plan.area(str(rule.get("area", "pit")))
	var inset: float = _num(rule, "trigger_inset_m", 3.0)
	p.zone = area.rect.grow(-inset) if area != null else Rect2()
	p.first_wave = roundi(_num(rule, "first_wave", 2.0))
	p.grow = roundi(_num(rule, "grow", 1.0))
	p.max_wave = roundi(_num(rule, "max_wave", 5.0))
	p.gap_ticks = roundi(_num(rule, "gap_s", 2.5) / SimClock.TICK_DT)
	for s: ArenaStation in stations.stations:
		if area != null and s.area == area.id:
			for sp: ArenaStation.Spawn in s.spawns:
				if sp.kind == "enemy" and (cells == null or cells.clear(plan.base + sp.at, 0.5)):
					p.points.append(plan.base + sp.at)
	return p


static func _num(rule: Dictionary, key: String, fallback: float) -> float:
	var v: Variant = rule.get(key, fallback)
	if v is float:
		return v
	if v is int:
		var i: int = v
		return float(i)
	return fallback


func step(arena: CombatArena, tick: int) -> void:
	for f: Fighter in standing.duplicate():
		if not f.alive():
			standing.erase(f)
			kills += 1
			if standing.is_empty():
				waves_cleared += 1
	if not standing.is_empty() or points.is_empty():
		return
	if not zone.has_point(arena.rivet.pos):
		_due_tick = -1
		return
	if _due_tick < 0:
		_due_tick = tick + (gap_ticks if wave > 0 else 0)
	if tick >= _due_tick:
		_spawn_wave(arena)


## Rivet went down: the standing guards leave (no kill counted) and the pit starts over.
func reset(arena: CombatArena) -> void:
	for f: Fighter in standing:
		arena.hostiles.erase(f)
	standing.clear()
	wave = 0
	_due_tick = -1


func _spawn_wave(arena: CombatArena) -> void:
	wave += 1
	var n: int = mini(first_wave + grow * (wave - 1), max_wave)
	for i: int in n:
		standing.append(arena.spawn_guard(points[(wave + i) % points.size()]))
	arena.announce_wave(&"arena_pit", wave)
	_due_tick = -1
	Log.info("arena", "pit wave %d: %d guards" % [wave, n])
