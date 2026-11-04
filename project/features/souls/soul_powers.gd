class_name SoulPowers
extends RefCounted
## The ghost-power framework (features/souls/README.md): activation, duration, cooldown, the
## Madness meter stub and interruption, all on whole sim ticks. One power runs at a time. Each
## start and end emits the soul's bark id (the voice hook; audio lands later). Pure logic: the
## form (HaulerForm) and the link (GearboxLink) listen to started/ended and do the body work.

signal started(id: StringName, bark: StringName)
signal ended(id: StringName, reason: StringName, bark: StringName)

const OK: StringName = &"ok"
const ACTIVE: StringName = &"active"
const BUSY: StringName = &"busy"
const COOLING: StringName = &"cooldown"
const MAD: StringName = &"madness"
const UNKNOWN: StringName = &"unknown"
const EXPIRED: StringName = &"expired"

var table: PowerTable = null
var madness: float = 0.0
## The running power (&"" when none) and its ticks left.
var active: StringName = &""
var active_left: int = 0
## Counters for evidence: activations and ticks spent in each power.
var uses: Dictionary[StringName, int] = {}
var ticks_in: Dictionary[StringName, int] = {}
var _cooldown: Dictionary[StringName, int] = {}


func _init(p_table: PowerTable) -> void:
	table = p_table


## Tries to start `id`; returns OK or why not (ACTIVE, BUSY, COOLING, MAD, UNKNOWN).
func try_activate(id: StringName) -> StringName:
	var p: PowerDef = table.row(id)
	if p == null:
		return UNKNOWN
	if active == id:
		return ACTIVE
	if active != &"":
		return BUSY
	if cooldown_left(id) > 0:
		return COOLING
	if madness + p.madness_cost > table.madness_max:
		return MAD
	madness += p.madness_cost
	active = id
	active_left = p.duration_ticks
	uses[id] = uses.get(id, 0) + 1
	started.emit(id, p.bark_on)
	return OK


## Ends the running power early when its row lists `reason`; true when it ended.
func interrupt(reason: StringName) -> bool:
	if active == &"" or not table.row(active).interrupted_by(reason):
		return false
	_end(reason)
	return true


## One sim tick: the running power counts down, cooldowns count down, madness decays.
func tick() -> void:
	for id: StringName in _cooldown.keys():
		_cooldown[id] = maxi(0, _cooldown[id] - 1)
	if active == &"":
		madness = maxf(0.0, madness - table.madness_decay_per_s * SimClock.TICK_DT)
		return
	ticks_in[active] = ticks_in.get(active, 0) + 1
	active_left -= 1
	if active_left <= 0:
		_end(EXPIRED)


func cooldown_left(id: StringName) -> int:
	return _cooldown.get(id, 0)


func is_active(id: StringName) -> bool:
	return active == id


## 0..1 of the running power's duration left (for the HUD ring).
func left_k() -> float:
	if active == &"":
		return 0.0
	return float(active_left) / float(maxi(1, table.row(active).duration_ticks))


## Ends the running power by the player's own choice (GhostForms exits or switches); it cools down
## as if it expired. True when a power was running.
func release() -> bool:
	if active == &"":
		return false
	_end(&"released")
	return true


func _end(reason: StringName) -> void:
	var p: PowerDef = table.row(active)
	var id: StringName = active
	active = &""
	active_left = 0
	_cooldown[id] = p.cooldown_ticks
	ended.emit(id, reason, p.bark_off)
