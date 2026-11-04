class_name KillLab
extends RefCounted
## The signature-kill lab (lane brutality, arena arg `--sig-lab`, dev capture only): a line of
## contractors stands in front of Rivet at the hub and he fires his `--sig-gun` at the next one
## every SHOT_EVERY ticks, so each kill plays framed in the camera at any zoom. The guards hold
## their fire (their cooldown is pinned). When the line is down, a new line steps in.
## With a `blade` (a melee_weapons.json id, until the arsenal lane's melee weapons go live) Rivet
## lunges at the guard instead, slashes through the arena's damage chokepoint and steps back.

const SHOT_EVERY: int = 110
const FIRST_SHOT: int = 60
## The line, metres from Rivet's start: in front of him and a little to each side.
const LINE: PackedVector2Array = [
	Vector2(2.5, 1.5),
	Vector2(3.0, 3.0),
	Vector2(2.0, 3.5),
	Vector2(3.5, 2.0),
	Vector2(2.2, 2.5),
	Vector2(3.2, 4.2)
]
## The blade's line: spread out, so each cut body lies clear of the next guard.
const BLADE_LINE: PackedVector2Array = [
	Vector2(3.0, -0.6),
	Vector2(3.0, 2.2),
	Vector2(0.6, 3.6),
	Vector2(5.6, 0.8),
	Vector2(5.0, 3.6),
	Vector2(2.6, 5.4)
]
const HOLD_FIRE: int = 100000
## How far a burning guard may run from its mark (metres): the panic stays in the camera.
const RUN_M: float = 1.8
## The blade strike: ticks of the lunge, ticks back to the mark, the stand-off and the damage.
const LUNGE_TICKS: int = 7
const BACK_TICKS: int = 30
const STRIKE_M: float = 1.0
const BLADE_DAMAGE: float = 999.0

var guards: Array[Fighter] = []
## Each guard's mark (they stand on it: no walk-in, no spawn spread).
var spots: PackedVector2Array = PackedVector2Array()
var shots: int = 0
## The melee weapon Rivet swings (empty: he fires his gun).
var blade: StringName = &""
## Ticks Rivet stays on the victim after the blow (the chainsaw's grind) before he steps back.
var hold_ticks: int = 0
var _next: int = 0
var _home: Vector2 = Vector2.INF
var _victim: Fighter = null
var _strike_t: int = -1


func setup(stage: ArenaStage) -> void:
	_line(stage)


func step(stage: ArenaStage, tick: int) -> void:
	for n: int in guards.size():
		var g: Fighter = guards[n]
		g.cooldown = HOLD_FIRE
		g.tell_left = 0
		if g.alive():  # a burning guard runs ablaze, tethered so the fire kill stays in frame
			var run: float = RUN_M if _burning(stage, g) else 0.0
			g.pos = spots[n] + (g.pos - spots[n]).limit_length(run)
	if not blade.is_empty():
		_step_blade(stage)
	if tick < FIRST_SHOT or (tick - FIRST_SHOT) % SHOT_EVERY != 0:
		return
	var target: Fighter = _target()
	if target == null:
		_line(stage)
		return
	if not blade.is_empty():
		_victim = target
		_strike_t = 0
	elif stage.arena.rivet_fire(target.pos):
		shots += 1


## The lunge to STRIKE_M short of the victim, the slash (a lethal hit along the lunge), the walk
## back to Rivet's mark. Sim state on the 60 Hz tick, no dice.
func _step_blade(stage: ArenaStage) -> void:
	var r: Fighter = stage.arena.rivet
	if _home == Vector2.INF:
		_home = r.pos
	if _strike_t < 0:
		return
	_strike_t += 1
	var to: Vector2 = (_victim.pos - _home).normalized()
	var spot: Vector2 = _victim.pos - to * STRIKE_M
	r.facing = to
	if _strike_t <= LUNGE_TICKS:
		r.pos = _home.lerp(spot, float(_strike_t) / LUNGE_TICKS)
	if _strike_t == LUNGE_TICKS and _victim.alive():
		stage.arena.hit_dir = to
		stage.arena.hit_at = _victim.pos
		stage.arena.damage(_victim, BLADE_DAMAGE, r.id, blade)
		shots += 1
	elif _strike_t > LUNGE_TICKS + hold_ticks:
		var k: float = float(_strike_t - LUNGE_TICKS - hold_ticks) / BACK_TICKS
		r.pos = spot.lerp(_home, minf(k, 1.0))
		_strike_t = -1 if k >= 1.0 else _strike_t


func _burning(stage: ArenaStage, g: Fighter) -> bool:
	var areas: FightAreas = stage.arena.areas
	return areas != null and areas.fx.has(g.id) and areas.fx[g.id].burn_ticks > 0


func _target() -> Fighter:
	for n: int in guards.size():
		var g: Fighter = guards[(_next + n) % guards.size()]
		if g.alive():
			_next = (_next + n + 1) % guards.size()
			return g
	return null


func _line(stage: ArenaStage) -> void:
	guards.clear()
	spots.clear()
	_next = 0
	for off: Vector2 in BLADE_LINE if not blade.is_empty() else LINE:
		var g: Fighter = stage.arena.spawn_guard(stage.plan.rivet_start + off)
		g.pos = stage.plan.rivet_start + off
		g.cooldown = HOLD_FIRE
		@warning_ignore("return_value_discarded")
		spots.append(g.pos)
		guards.append(g)
