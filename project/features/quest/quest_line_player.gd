class_name QuestLinePlayer
extends RefCounted
## Quest lines as data (the spike's quest_lines, on ticks): a beat's lineIds queue as
## speaker-tagged subtitles, each typed out and then held. Lines with `when` conditions are
## barks: armed for the whole active contract, each fires once, the first tick all of its
## conditions hold, and cuts the queue (never the line on screen). Timing reads the package's
## source text, so the sim (and its replay hash) does not depend on the player's locale.


class Shown:
	extends RefCounted
	var line_id: String = ""
	var speaker: String = ""
	var bark: bool = false
	var tick: int = 0
	var beat: int = -1


var shown: Array[Shown] = []
var current: QuestLine = null
var current_ticks: int = 0
var _pkg: QuestPackage
var _rules: QuestRules
var _queue: Array[QuestLine] = []
var _armed: Array[QuestLine] = []
var _current_length: int = 0


func _init(pkg: QuestPackage, rules: QuestRules) -> void:
	_pkg = pkg
	_rules = rules
	_armed = pkg.barks()


## A beat's spoken lines join the queue; a bark listed in a beat still waits for its conditions.
func play_beat(beat: QuestBeat) -> void:
	for line_id: String in beat.line_ids:
		var line: QuestLine = _pkg.line(line_id)
		if not line.is_bark():
			_queue.append(line)


func armed_barks() -> int:
	return _armed.size()


func busy() -> bool:
	return current != null or not _queue.is_empty()


## One tick. Barks are armed only while the contract is active.
func step(tick: int, beat_index: int, world: QuestWorld, active: bool) -> void:
	if active:
		_fire_barks(world)
	if current != null:
		current_ticks += 1
		if current_ticks >= _current_length:
			current = null
	if current == null and not _queue.is_empty():
		var next: QuestLine = _queue.pop_front()
		_show(next, tick, beat_index)


## The subtitle on screen now: the speaker's name and the typed-out part of the line.
func subtitle(text: QuestText) -> PackedStringArray:
	if current == null:
		return PackedStringArray()
	var speaker: String = current.speaker
	var who: String = text.resolve(QuestText.cast_key(speaker), _pkg.speaker_name(speaker))
	var words: String = text.resolve(current.key, current.text)
	var typed: float = current_ticks * SimClock.TICK_DT * _rules.tuning["line_type_cps"]
	return PackedStringArray([who, words.left(floori(typed + SimClock.EPSILON))])


func fully_typed() -> bool:
	return current != null and current.typed_chars(current_ticks, _rules) >= current.text.length()


func write_state(out: StreamPeerBuffer) -> void:
	out.put_utf8_string(current.id if current != null else "")
	out.put_32(current_ticks)
	out.put_32(_queue.size())
	out.put_32(_armed.size())
	out.put_32(shown.size())


func _fire_barks(world: QuestWorld) -> void:
	var fired: int = 0
	for line: QuestLine in _armed.duplicate():
		if line.holds(world.soul_name(), world.madness_band(), world.wanted_level()):
			_armed.erase(line)
			if _queue.insert(fired, line) == OK:
				fired += 1


func _show(line: QuestLine, tick: int, beat_index: int) -> void:
	current = line
	current_ticks = 0
	_current_length = line.duration_ticks(_rules)
	var entry: Shown = Shown.new()
	entry.line_id = line.id
	entry.speaker = line.speaker
	entry.bark = line.is_bark()
	entry.tick = tick
	entry.beat = beat_index
	shown.append(entry)
