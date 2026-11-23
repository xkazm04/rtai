class_name ProloguePrompts
extends RefCounted
## One card owns the strip. Only a fresh offer can start the next lesson.
## History intervals are half-open: end_tick is the first tick without the card.

const COPY: Dictionary[String, String] = {
	"strike": "Strike Dale [fire]",
	"claw": "Quick claw [melee]",
	"guard": "Hold [guard] to guard",
	"roll": "Roll clear [roll]",
	"wheel": "Select pistol [wheel]",
	"fire": "Aim [aim] and fire [fire]",
}
const HOLD_TICKS: int = 2 * SimClock.TICK_RATE
const GAP_TICKS: int = int(0.5 * SimClock.TICK_RATE)
const HAND_ORDER: Array[String] = ["claw", "guard", "roll"]

var history: Array[Dictionary] = []
var _seen: Dictionary[String, bool] = {}
var _current: String = ""
var _until: int = -1
var _next_hand_tick: int = 0
var _text: QuestText = QuestText.new()


func offer(id: String, tick: int, first_catch_tick: int = -1) -> void:
	if _seen.has(id) or _current != "":
		return
	var hand: int = HAND_ORDER.find(id)
	if hand >= 0 and tick < _next_hand_tick:
		return
	if hand > 0 and not _seen.has(HAND_ORDER[hand - 1]):
		return
	if id == "roll" and (first_catch_tick < 0 or tick <= first_catch_tick):
		return
	_seen[id] = true
	_current = id
	_until = -1 if id in ["strike", "wheel"] else tick + HOLD_TICKS
	history.append({"id": id, "tick": tick, "end_tick": -1})


func step(tick: int) -> void:
	if _until >= 0 and tick >= _until:
		clear(_until)


func active(id: String) -> bool:
	return _current != "" and _current == id


func dismiss(id: String, tick: int) -> void:
	if active(id):
		clear(tick)


func clear(tick: int) -> void:
	if _current == "":
		return
	history.back()["end_tick"] = tick
	_next_hand_tick = maxi(tick, _until) + GAP_TICKS
	_current = ""
	_until = -1


func words(pad: bool) -> String:
	if _current == "":
		return ""
	var copy: String = _text.resolve(StringName("PROLOGUE__" + _current.to_upper()), COPY[_current])
	for action: StringName in [&"guard", &"roll"]:
		var key: String = ObjectiveHint.pad_name(action) if pad else ObjectiveHint.key_name(action)
		copy = copy.replace("[%s]" % action, "[%s]" % key)
	return ObjectiveHint.with_keys(copy.replace("[wheel]", "[%s]" % _wheel_key(pad)), pad)


func _wheel_key(pad: bool) -> String:
	if pad:
		return ObjectiveHint.pad_name(&"weapon_next")
	for event: InputEvent in InputMap.action_get_events(&"weapon_next"):
		if event is InputEventMouseButton:
			return event.as_text()
	return ObjectiveHint.key_name(&"weapon_next")
