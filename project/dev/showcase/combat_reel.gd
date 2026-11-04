class_name CombatReel
extends InputSource
## The showcase's scripted fight (`--bot=reel` in the arena, also on `--arena=city`): one
## deterministic run of the real Rivet through every finished combat piece, in beats. It reads
## only the sim, and its TickInputs go through the same InputTape as live play, so a reel records
## and replays. Beats (metres from the arena hub, ticks at 60 Hz): walk a loop of the hub, strafe
## across it aiming one way, the range dummies (static, strafing, approaching) through the range
## bot, then the pit: the first wave by melee (close in, jab), the next by the gun. The beats grow
## as the night lanes land (weapon switch, signature kills, riot shield, robot thug).

const REACH_M: float = 0.6
## Melee: jab from this close (StagePilot's reach is 1.6 m plus the guard's radius).
const JAB_M: float = 1.5
const JAB_EVERY: int = 32
const DWELL_LINE: int = 60
## Guns: fire inside this distance, after the guard was inside it REACT_TICKS (a readable beat).
const FIRE_M: float = 13.0
const REACT_TICKS: int = 30
const PIT_ENTRY: Array[Vector2] = [Vector2(3.0, 3.0), Vector2(3.0, 10.0), Vector2(14.0, 17.0)]


class Beat:
	var id: StringName
	var ticks: int
	var points: Array[Vector2] = []
	var aim: Vector2 = Vector2.ZERO
	## The first `lead` points are walked; a melee line beat jabs at each point after them.
	var lead: int = 0

	func _init(p_id: StringName, p_ticks: int) -> void:
		id = p_id
		ticks = p_ticks


var stage: ArenaStage
var actions: PlayerActions
var beats: Array[Beat] = []
## The beat each tick ran (index), for the HUD and the log.
var beat_i: int = 0
## Pit kills credited to the beat that was running (beat id -> kills), for the scenario.
var kills_by_beat: Dictionary[StringName, int] = {}
## False plants the scenario's fault: every button off (aim and walk only).
var trigger: bool = true
var _beat_start: int = 0
var _next: int = 0
var _range: ArenaRangeBot
var _seen_since: int = -1
var _kills_before: int = 0


func _init(p_stage: ArenaStage, p_actions: PlayerActions) -> void:
	stage = p_stage
	actions = p_actions
	_range = ArenaRangeBot.new(p_stage, p_actions)
	beats = default_beats()


static func default_beats() -> Array[Beat]:
	var walk: Beat = Beat.new(&"walk", 300)
	walk.points = [Vector2(4.0, 1.5), Vector2(13.0, 1.5), Vector2(13.0, 4.0), Vector2(4.0, 4.0)]
	var strafe: Beat = Beat.new(&"strafe", 240)
	strafe.points = [Vector2(4.0, 1.0), Vector2(12.0, 1.0)]
	strafe.aim = Vector2.UP
	# rivet-motion's melee line (targets at x 0/2/4, metal at 6/8/10/14 on y -3), round its west end
	var line: Beat = Beat.new(&"melee_line", 660)
	line.points = [Vector2(-1.8, -6.0), Vector2(-1.8, -1.6)]
	line.lead = line.points.size()
	for x: float in [0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 14.0]:
		line.points.append(Vector2(x, -1.6))
	var melee: Beat = Beat.new(&"pit_melee", 900)
	melee.points = PIT_ENTRY
	var gun: Beat = Beat.new(&"pit_gun", 1200)
	gun.points = [PIT_ENTRY[PIT_ENTRY.size() - 1]]
	return [walk, strafe, Beat.new(&"range", 540), line, melee, gun]


func beat() -> Beat:
	return beats[mini(beat_i, beats.size() - 1)]


## Total ticks of the reel (a capture's --quit-after at 60 fps).
func length() -> int:
	var n: int = 0
	for b: Beat in beats:
		n += b.ticks
	return n


func sample(tick: int) -> TickInput:
	if beat_i < beats.size():
		var b_id: StringName = beats[beat_i].id
		kills_by_beat[b_id] = stage.pit.kills - _kills_before
	while beat_i < beats.size() and tick - _beat_start >= beats[beat_i].ticks:
		_kills_before = stage.pit.kills
		_beat_start += beats[beat_i].ticks
		beat_i += 1
		_next = 0
		_seen_since = -1
		var id: StringName = beats[beat_i].id if beat_i < beats.size() else &"end"
		Log.info("showcase", "reel beat %s at tick %d" % [id, tick])
	if beat_i >= beats.size():
		return _input(Vector2.ZERO, Vector2.DOWN, 0)
	var b: Beat = beats[beat_i]
	var local: int = tick - _beat_start
	match b.id:
		&"walk":
			return _path(b, true)
		&"strafe":
			return _strafe(b, local)
		&"range":
			return _range.sample(local)
		&"melee_line":
			return _line(b)
		_:
			return _pit(b, local, b.id == &"pit_melee")


## Walk the beat's points in a loop (the facing follows the walk unless `aim` is set).
func _path(b: Beat, loop: bool) -> TickInput:
	var rivet: Vector2 = stage.arena.rivet.pos
	var to: Vector2 = stage.plan.base + b.points[_next % b.points.size()] - rivet
	if to.length() <= REACH_M and (loop or _next < b.points.size() - 1):
		_next += 1
	var aim: Vector2 = b.aim if b.aim != Vector2.ZERO else to.normalized()
	return _input(to.normalized(), aim, 0)


## Side to side between the two points while the aim holds one heading (the twin-stick read).
func _strafe(b: Beat, local: int) -> TickInput:
	var leg: int = (local / 80) % 2
	var to: Vector2 = stage.plan.base + b.points[leg] - stage.arena.rivet.pos
	return _input(to.limit_length(1.0), b.aim, 0)


## Walk the lead-in, then at each line point face north (the dummies) and jab DWELL_LINE ticks.
func _line(b: Beat) -> TickInput:
	if _next < b.lead:
		return _path(b, false)
	var rivet: Vector2 = stage.arena.rivet.pos
	var to: Vector2 = stage.plan.base + b.points[mini(_next, b.points.size() - 1)] - rivet
	if to.length() > REACH_M:
		_seen_since = -1
		return _input(to.limit_length(1.0), to.normalized(), 0)
	_seen_since += 1
	if _seen_since >= DWELL_LINE and _next < b.points.size() - 1:
		_next += 1
	return _input(Vector2.ZERO, Vector2.UP, _bit(&"melee", _seen_since == DWELL_LINE / 3))


## The pit: through the doors, then the nearest standing guard: melee closes in and jabs; the gun
## strafes across its line and fires once it has been in range REACT_TICKS.
func _pit(b: Beat, local: int, melee: bool) -> TickInput:
	var rivet: Vector2 = stage.arena.rivet.pos
	if _next < b.points.size():
		var to: Vector2 = stage.plan.base + b.points[_next] - rivet
		if to.length() <= REACH_M:
			_next += 1
		return _input(to.normalized(), to.normalized(), 0)
	var spot: Vector2 = stage.plan.base + b.points[b.points.size() - 1]
	var foe: Fighter = _nearest(rivet)
	if foe == null:
		_seen_since = -1
		return _input((spot - rivet).limit_length(1.0), Vector2.DOWN, 0)
	var gap: Vector2 = foe.pos - rivet
	var aim: Vector2 = gap.normalized()
	if melee:
		var jab: bool = gap.length() <= JAB_M and local % JAB_EVERY == 0
		return _input(aim if gap.length() > JAB_M * 0.7 else Vector2.ZERO, aim, _bit(&"melee", jab))
	var close: bool = gap.length() <= FIRE_M
	_seen_since = (local if _seen_since < 0 else _seen_since) if close else -1
	var fire: bool = close and local - _seen_since >= REACT_TICKS
	var side: float = 1.0 if (local / 45) % 2 == 0 else -1.0
	var drift: Vector2 = aim.orthogonal() * side * 0.8 + (spot - rivet).limit_length(1.0) * 0.4
	return _input(drift, aim, _bit(&"fire", fire))


func _nearest(at: Vector2) -> Fighter:
	var best: Fighter = null
	for f: Fighter in stage.pit.standing:
		if f.alive() and (best == null or at.distance_to(f.pos) < at.distance_to(best.pos)):
			best = f
	return best


func _bit(action: StringName, on: bool) -> int:
	return 1 << actions.bit(action) if on else 0


func _input(move: Vector2, aim: Vector2, extra: int) -> TickInput:
	var m: Vector2 = move.limit_length(1.0) * TickInput.AXIS_MAX
	var buttons: int = PlayerCommand.pack_aim(aim, actions) | (extra if trigger else 0)
	return TickInput.new(buttons, roundi(m.x), roundi(m.y))
