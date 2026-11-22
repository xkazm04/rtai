class_name ProloguePrompts
extends RefCounted
## A threat gets its hint on the actual tick. Overlapping hints share the strip for
## their full reading time. Seen lessons survive checkpoint retries.

const COPY: Dictionary[String, String] = {
	"strike": "Strike Dale [fire]",
	"claw": "Quick claw [melee]",
	"guard": "Hold [guard] to guard",
	"roll": "Roll clear [roll]",
}
const HOLD_TICKS: int = 2 * SimClock.TICK_RATE

var history: Array[Dictionary] = []
var _seen: Dictionary[String, bool] = {}
var _until: Dictionary[String, int] = {}
var _text: QuestText = QuestText.new()


func offer(id: String, tick: int) -> void:
	if _seen.has(id):
		return
	_seen[id] = true
	_until[id] = tick + HOLD_TICKS
	history.append({"id": id, "tick": tick})


func step(tick: int) -> void:
	for id: String in _until.keys():
		if id != "strike" and tick >= _until[id]:
			@warning_ignore("return_value_discarded")
			_until.erase(id)


func active(id: String) -> bool:
	return _until.has(id)


func clear() -> void:
	_until.clear()


func words(pad: bool) -> String:
	var parts: PackedStringArray = []
	for id: String in _until:
		@warning_ignore("return_value_discarded")
		parts.append(_text.resolve(StringName("PROLOGUE__" + id.to_upper()), COPY[id]))
	if parts.is_empty():
		return ""
	var copy: String = "   ·   ".join(parts)
	for action: StringName in [&"guard", &"roll"]:
		var key: String = ObjectiveHint.pad_name(action) if pad else ObjectiveHint.key_name(action)
		copy = copy.replace("[%s]" % action, "[%s]" % key)
	return ObjectiveHint.with_keys(copy, pad)
