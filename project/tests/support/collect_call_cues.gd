class_name CollectCallCues
extends RefCounted
## The cue kinds of CollectCallScript. run() performs one tick of a cue and returns true when
## it is complete. Rivet's input: idle, walk, walk_phone, press, torch. World stand-ins (see
## CollectCallScript.stubbed()): drain, heat, whisper, equip, wave, clear, boss, telegraph, hit,
## kill_boss; each speaks through the real Events bus the quest listens to.

const MERTZ: StringName = &"quartermaster-mertz"
const TAZER: StringName = &"robo-tazer"


static func run(s: CollectCallScript, cue: Array, ticks: int) -> bool:
	var kind: String = cue[0]
	var arg: Variant = cue[1] if cue.size() > 1 else null
	match kind:
		"idle":
			return not s.quest_runner().lines.busy()
		"walk", "walk_phone":
			return _walk(s, str(arg), kind == "walk_phone")
		"press":
			s.stub_world().interact = true
			return false
		"torch":
			return _torch(s, ticks)
		"drain":
			return _drain(s, ticks)
		"wave":
			var wave: int = arg
			return _wave(s, wave, ticks)
	_instant(s, kind, arg)
	return true


## One-tick world stand-ins.
static func _instant(s: CollectCallScript, kind: String, arg: Variant) -> void:
	match kind:
		"heat":
			var level: int = arg
			s.stub_world().set_wanted(level)
		"whisper":
			s.event_bus().whispers_spiked.emit()
		"equip":
			s.stub_world().weapon = str(arg)
		"clear":
			s.stub_world().cleared[str(arg)] = true
		"boss":
			s.event_bus().boss_engaged.emit(MERTZ)
		"telegraph":
			s.event_bus().attack_telegraphed.emit(TAZER)
		"hit":
			s.event_bus().player_hit.emit(TAZER)
			s.event_bus().whispers_spiked.emit()
		"kill_boss":
			s.event_bus().actor_killed.emit(
				StubQuestWorld.PLAYER_ID, CollectCallScript.MERTZ_ID, &"shot"
			)
		_:
			Log.error("quest-script", "unknown cue %s" % kind)


static func _walk(s: CollectCallScript, place: String, to_phone: bool) -> bool:
	var marker: QuestPlaces.Marker = s.stub_world().places().markers[place]
	var goal: Vector2 = marker.phone if to_phone else marker.at
	s.stub_world().move_toward(goal)
	return s.stub_world().rivet.distance_to(goal) <= CollectCallScript.ARRIVE_M


## Heat drains a level every DRAIN_EVERY ticks while Rivet lies low; done at 0.
static func _drain(s: CollectCallScript, ticks: int) -> bool:
	if s.stub_world().wanted == 0:
		return true
	if ticks > 0 and ticks % CollectCallScript.DRAIN_EVERY == 0:
		s.stub_world().set_wanted(s.stub_world().wanted - 1)
	return false


## Wave `wave` starts on its first tick; one contractor goes down every KILL_EVERY ticks.
static func _wave(s: CollectCallScript, wave: int, ticks: int) -> bool:
	if ticks == 0:
		s.event_bus().wave_started.emit(StringName(CollectCallScript.DOCK), wave)
		return false
	if ticks % CollectCallScript.KILL_EVERY != 0:
		return false
	s.event_bus().actor_killed.emit(StubQuestWorld.PLAYER_ID, s.next_victim(), &"shot")
	return ticks / CollectCallScript.KILL_EVERY >= CollectCallScript.WAVES[wave - 1]


## The welding torch on the crate stack: the voices spike as it catches (planted: never lit).
static func _torch(s: CollectCallScript, ticks: int) -> bool:
	if not s.torches:
		return false
	if ticks == 0:
		s.event_bus().whispers_spiked.emit()
	s.stub_world().interact = true
	return false
