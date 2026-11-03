class_name PitDummy
extends RefCounted
## A scripted Rivet for tuning and tests: stands, or watches the tells and dodges (sidesteps a
## locked aim line, backs out of a melee windup, steps across an incoming round), and can fight
## back with nails at the nearest enemy it sees. It plays like a player who reads telegraphs.

enum Mode { STAND, DODGE, FIGHT }

const RUN_MPS: float = 5.0
const ACCEL_MPS2: float = 40.0
const NAIL_GAP_TICKS: int = 21
const THREAT_S: float = 0.35
## Ticks to keep clear of a line after a dodge before drifting home.
const CALM_TICKS: int = 45

var mode: Mode = Mode.DODGE
var shoots: bool = true
## Also sidestep rounds already in flight (off: only the tells are read).
var watch_rounds: bool = true
## Nails only enemies nearer than this (a player engages at a range, not across the pit).
var fire_m: float = 22.0
## A human's reaction: start dodging this many ticks after a tell appears (-1: a perfect reader
## who moves exactly as the aim locks; about 15 ticks = 0.25 s is a player who watches).
var react_ticks: int = -1
## The share of tells it notices at all (1 = every one; a busy player misses some).
var read_frac: float = 1.0
## Nail aim error, degrees either side (0 = perfect aim). The spread is a fixed low-discrepancy
## sequence, not an RNG draw, so the dummy never touches the fight's RNG streams.
var aim_err_deg: float = 0.0
var _nails: int = 0
var _side: float = 1.0
var _nail_cd: int = 0
var _home: Vector2 = Vector2.ZERO
var _calm: int = 0


func _init(p_mode: Mode, home: Vector2 = Vector2.ZERO) -> void:
	mode = p_mode
	_home = home


func step(pit: EnemyPit) -> void:
	var want: Vector2 = Vector2.ZERO
	if mode != Mode.STAND:
		want = _dodge(pit)
		_calm = CALM_TICKS if want != Vector2.ZERO else maxi(_calm - 1, 0)
		if want == Vector2.ZERO and _calm == 0:
			want = EnemySenses.push_out(_home, 0.0, pit.cover) - pit.rivet_pos
			want = want.limit_length(1.0) * RUN_MPS * 0.5
	pit.rivet_vel = pit.rivet_vel.move_toward(want, ACCEL_MPS2 * SimClock.TICK_DT)
	var next: Vector2 = pit.rivet_pos + pit.rivet_vel * SimClock.TICK_DT
	next = EnemySenses.push_out(next, pit.rivet_radius, pit.cover)
	pit.rivet_pos = next.clamp(pit.bounds.position, pit.bounds.end)
	_nail_cd = maxi(_nail_cd - 1, 0)
	if mode == Mode.FIGHT and shoots and _nail_cd == 0:
		_fire_nearest(pit)


func _dodge(pit: EnemyPit) -> Vector2:
	for e: EnemyAgent in pit.agents:
		var firing: bool = e.state == EnemyAgent.State.FIRE
		if not firing and not _reads(e, pit):
			continue
		var to: Vector2 = pit.rivet_pos - e.pos
		if e.melee():
			return to.normalized() * RUN_MPS
		return _across(e.aim, to)
	for s: Shot in pit.shots:
		if s.from_rivet or not watch_rounds:
			continue
		var rel: Vector2 = pit.rivet_pos - s.pos
		var along: float = rel.dot(s.vel.normalized())
		if along > 0.0 and along < s.vel.length() * THREAT_S:
			return _across(s.vel.normalized(), rel)
	return Vector2.ZERO


## Whether it is dodging `e`'s tell this tick (a perfect reader, or a human-like one).
func _reads(e: EnemyAgent, pit: EnemyPit) -> bool:
	if e.state != EnemyAgent.State.WINDUP:
		return false
	if react_ticks < 0:
		return e.timer <= pit.roster.aim_lock_ticks + 4
	var started: int = e.id * 7919 + pit.tick - e.state_ticks
	var noticed: bool = fposmod(float(started) * 0.618034, 1.0) < read_frac
	return noticed and e.state_ticks >= react_ticks


## Sidestep perpendicular to `line`, toward the side Rivet already leans to.
func _across(line: Vector2, rel: Vector2) -> Vector2:
	var side: Vector2 = line.orthogonal()
	if absf(side.dot(rel)) > 0.05:
		_side = signf(side.dot(rel))
	return side * _side * RUN_MPS


func _fire_nearest(pit: EnemyPit) -> void:
	var best: EnemyAgent = null
	var best_d: float = INF
	for e: EnemyAgent in pit.agents:
		if not e.alive() or EnemySenses.blocked(pit.rivet_pos, e.pos, pit.cover):
			continue
		var d: float = pit.rivet_pos.distance_to(e.pos)
		if d < best_d:
			best_d = d
			best = e
	if best != null and best_d < fire_m:
		_nails += 1
		var err: float = (fposmod(float(_nails) * 0.618034, 1.0) * 2.0 - 1.0) * aim_err_deg
		pit.rivet_fire((best.pos - pit.rivet_pos).normalized().rotated(deg_to_rad(err)))
		_nail_cd = NAIL_GAP_TICKS
