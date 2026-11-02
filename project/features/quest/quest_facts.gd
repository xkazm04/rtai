class_name QuestFacts
extends RefCounted
## What a bark can react to (quest_rules.json `conditions` and `event_tags`): a snapshot of the
## world's state each tick (soul, madness, heat, weapon) and the facts recently recorded from the
## typed Events (F-04) plus the contract's own (`quest:<verb>_done`). A fact holds for
## event_window_s after it was recorded. Listens to the injected bus while a contract runs and
## is detached when it ends (GDS-10).

## The Events signals (and the contract itself) a fact can come from.
const SOURCES: PackedStringArray = [
	"actor_killed",
	"wanted_changed",
	"wave_started",
	"boss_engaged",
	"attack_telegraphed",
	"player_hit",
	"whispers_spiked",
	"quest",
]

var soul: String = "rivet"
var madness: String = "lucid"
var heat: int = 0
var weapon: String = "none"
var _last: Dictionary[String, int] = {}
var _now: int = 0
var _window_ticks: int = 0
var _player_id: int = -1
var _level: int = 0
var _bus: EventBus = null
var _bound: Dictionary[StringName, Callable] = {}


func _init(window_ticks: int) -> void:
	_window_ticks = window_ticks


func attach(bus: EventBus, world: QuestWorld) -> void:
	detach()
	_bus = bus
	_player_id = world.player_id()
	_level = world.wanted_level()
	_bound = {
		&"actor_killed": _on_actor_killed,
		&"wanted_changed": _on_wanted_changed,
		&"wave_started": _on_wave_started,
		&"boss_engaged": _on_boss_engaged,
		&"attack_telegraphed": _on_attack_telegraphed,
		&"player_hit": _on_player_hit,
		&"whispers_spiked": _on_whispers_spiked,
	}
	for signal_name: StringName in _bound:
		if bus.connect(signal_name, _bound[signal_name]) != OK:
			Log.error("quest", "facts could not listen to %s" % signal_name)


func detach() -> void:
	if _bus == null:
		return
	for signal_name: StringName in _bound:
		if _bus.is_connected(signal_name, _bound[signal_name]):
			_bus.disconnect(signal_name, _bound[signal_name])
	_bound.clear()
	_bus = null


## Called first on every tick: the state conditions read this snapshot.
func begin_tick(tick: int, world: QuestWorld) -> void:
	_now = tick
	soul = world.soul_name()
	madness = world.madness_band()
	heat = world.wanted_level()
	weapon = world.weapon_name()


func note(fact: String) -> void:
	_last[fact] = _now


func recent(fact: String) -> bool:
	return _last.has(fact) and _now - _last[fact] <= _window_ticks


## The facts and their ticks in name order, for the replay state hash (SIM-05).
func write_state(out: StreamPeerBuffer) -> void:
	var names: Array[String] = []
	names.assign(_last.keys())
	names.sort()
	for fact: String in names:
		out.put_utf8_string(fact)
		out.put_32(_last[fact])


func _on_actor_killed(killer_id: int, _victim_id: int, _kind: StringName) -> void:
	note("actor_killed")
	if killer_id == _player_id:
		note("actor_killed:by_player")


func _on_wanted_changed(level: int) -> void:
	note("wanted_changed")
	if level < _level:
		note("wanted_changed:falling")
	elif level > _level:
		note("wanted_changed:rising")
	_level = level


func _on_wave_started(_encounter: StringName, _wave: int) -> void:
	note("wave_started")


func _on_boss_engaged(_boss: StringName) -> void:
	note("boss_engaged")


func _on_attack_telegraphed(with_weapon: StringName) -> void:
	note("attack_telegraphed")
	note("attack_telegraphed:%s" % with_weapon)


func _on_player_hit(with_weapon: StringName) -> void:
	note("player_hit")
	note("player_hit:%s" % with_weapon)


func _on_whispers_spiked() -> void:
	note("whispers_spiked")
