class_name HeatMeter
extends RefCounted
## Heat (the wanted level, 0 to max_level, 3 in Act 1). Violence a human sees raises it; every
## drain_s_per_level seconds out of every human's sight lowers it one level, and being seen
## restarts that count. The one setter is set_level(), and it emits Events.wanted_changed
## (ARC-08). Ticks only (SIM-01); no randomness.

const TABLE: String = "res://data/tables/heat.json"
const SCHEMA: String = "gtai.heat/1"

var level: int = 0
var max_level: int = 3
var drain_ticks: int = 360
var sight_m: float = 10.0
## The level dropped on the last step (the `heat-dropping` cue).
var dropped: bool = false
var _unseen_ticks: int = 0
var _events: EventBus


func _init(events: EventBus, path: String = TABLE) -> void:
	_events = events
	var t: DataTable = DataTable.open(path, SCHEMA)
	max_level = t.integer(t.raw, "max_level")
	drain_ticks = ceili(t.num(t.raw, "drain_s_per_level") * SimClock.TICK_RATE)
	sight_m = t.num(t.raw, "sight_m")
	if not t.ok():
		Log.error("heat", str(t.errors()))


## The one writer of the level: clamped, and emitted when it changes.
func set_level(next: int) -> void:
	var clamped: int = clampi(next, 0, max_level)
	if clamped == level:
		return
	level = clamped
	_unseen_ticks = 0
	_events.wanted_changed.emit(level)


## Violence a human saw.
func raise_by(levels: int) -> void:
	set_level(level + levels)


## One tick. `seen`: a human (cop, guard) has Rivet in sight this tick.
func step(seen: bool) -> void:
	dropped = false
	if level == 0 or seen:
		_unseen_ticks = 0
		return
	_unseen_ticks += 1
	if _unseen_ticks >= drain_ticks:
		set_level(level - 1)
		dropped = true


## Seconds of hiding left until heat is 0, if Rivet stays out of sight.
func seconds_to_cool() -> float:
	if level == 0:
		return 0.0
	return float(level * drain_ticks - _unseen_ticks) * SimClock.TICK_DT


func write_state(out: StreamPeerBuffer) -> void:
	out.put_8(level)
	out.put_32(_unseen_ticks)
