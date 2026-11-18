class_name PlayerCover
extends RefCounted
## A ground stance on a station face. The arena's ordinary shot segments and fighter positions
## decide every hit, including at a fully extended corner peek.

enum Phase { OFF, SNAP, IN, PEEK, LEAVE }

var enabled: bool = false
var phase: Phase = Phase.OFF
var spot: CoverQuery.CoverSpot
var snap_reach_m: float
var snap_ticks: int
var move_mps: float
var peek_m: float
var peek_ticks: int
var edge_m: float
var leave_dot: float
var leave_ticks: int
var _origin: Vector2
var _position: Vector2
var _frame: int
var _away: int
var _end: int
var _probe: VaultProbe


func interrupt() -> void:
	phase = Phase.OFF
	spot = null


func blocks_fire() -> bool:
	return phase != Phase.OFF and (phase != Phase.PEEK or _frame < peek_ticks)


## Returns true when cover consumed this tick's movement. A roll exit takes the normal roll
## step immediately, without probing the wall for a vault.
func drive(stage: CollectCallStage, pilot: StagePilot, c: PlayerCommand, walk: float) -> bool:
	if not enabled:
		if spot != null:
			interrupt()
		return false
	var motion: PlayerMotion = pilot.motion
	var press: bool = c.was_pressed(pilot.actions, &"cover")
	var roll: bool = c.was_pressed(pilot.actions, &"roll")
	if phase == Phase.OFF:
		if not press or roll or not motion.can_roll() or not _enter(stage, motion):
			return false
	elif roll or press or stage.arena.rivet.pos != _position or stage.intent.move_to != Vector2.INF:
		interrupt()
		if roll:
			stage.intent.move_by = motion.step(c, walk, pilot.actions)
		return roll
	if phase == Phase.SNAP:
		if not _snap(stage):
			interrupt()
			return false
	elif c.move.limit_length(1.0).dot(spot.normal) > leave_dot:
		phase = Phase.LEAVE
		_away += 1
		if _away >= leave_ticks:
			interrupt()
			return false
	else:
		_away = 0
		_slide_or_peek(stage, c, c.is_held(pilot.actions, &"fire"))
	motion.mover.facing = c.aim if c.aim != Vector2.ZERO else spot.normal
	stage.intent.move_by = Vector2.ZERO
	return true


func _enter(stage: CollectCallStage, motion: PlayerMotion) -> bool:
	if stage.hidden_in != "" or stage.intent.move_to != Vector2.INF or not stage is ArenaStage:
		return false
	motion.vault.bind_solids(stage)
	_probe = motion.vault.probe
	_origin = stage.arena.rivet.pos
	if not _clear(stage, _origin):
		return false
	var r: float = stage.arena.rivet.radius_m
	for s: CoverQuery.CoverSpot in CoverQuery.near(_origin, snap_reach_m, _probe.boxes, r, peek_m):
		if not s.protects_shots or not _clear(stage, s.at):
			continue
		motion.stop()
		spot = s
		_frame = 0
		_end = 0
		_away = 0
		_position = _origin
		phase = Phase.SNAP
		return true
	return false


func _clear(stage: CollectCallStage, p: Vector2) -> bool:
	return _probe.clear_at(p, stage.arena.rivet.radius_m) and stage.collide_preview(p) == p


func _place(stage: CollectCallStage, p: Vector2) -> bool:
	if not _clear(stage, p):
		return false
	_position = p
	stage.arena.rivet.pos = p
	return true


func _snap(stage: CollectCallStage) -> bool:
	var p: Vector2 = _origin.lerp(spot.at, float(_frame + 1) / snap_ticks)
	if not _place(stage, spot.at if _frame + 1 == snap_ticks else p):
		return false
	_frame += 1
	if _frame == snap_ticks:
		phase = Phase.IN
		_frame = 0
	return true


func _slide_or_peek(stage: CollectCallStage, c: PlayerCommand, fire: bool) -> void:
	var t: Vector2 = spot.tangent
	if _frame == 0:
		phase = Phase.IN
		var ds: float = c.move.limit_length(1.0).dot(t) * move_mps * SimClock.TICK_DT
		var along: float = clampf(
			(spot.at + t * ds).dot(t), spot.box.position.dot(t), spot.box.end.dot(t)
		)
		var p: Vector2 = spot.at * spot.normal.abs() + t * along
		if _place(stage, p):
			spot.at = p
		var left: float = spot.at.dot(t) - spot.box.position.dot(t)
		var right: float = spot.box.end.dot(t) - spot.at.dot(t)
		if minf(left, right) > edge_m:
			return
		_end = -1 if left <= right else 1
	var wants: bool = fire or c.aim.dot(t * _end) > SimClock.EPSILON
	var next: int = clampi(_frame + (1 if wants else -1), 0, peek_ticks)
	var edge: Vector2 = spot.edge_a if _end < 0 else spot.edge_b
	var p: Vector2 = edge if next == peek_ticks else spot.at.lerp(edge, float(next) / peek_ticks)
	if _place(stage, p):
		_frame = next
	phase = Phase.PEEK if _frame > 0 else Phase.IN


func write_state(out: StreamPeerBuffer) -> void:
	if phase == Phase.OFF:
		return
	out.put_u8(phase)
	out.put_32(_frame)
	out.put_32(_away)
	out.put_32(_end)
	for p: Vector2 in [_origin, _position, spot.at, spot.box.position, spot.box.size, spot.normal]:
		out.put_float(p.x)
		out.put_float(p.y)
