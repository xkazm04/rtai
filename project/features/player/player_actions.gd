class_name PlayerActions
extends RefCounted
## The gameplay actions as data (data/tables/input_actions.json, STM-09): which bit each takes in
## TickInput.buttons, its default keys, mouse and gamepad bindings, plus the aim quantisation and
## the movement feel. install() registers them into the InputMap at boot, so a later settings
## screen rebinds the InputMap, never code (GDS-08: no raw keycodes outside this table).

const TABLE: String = "res://data/tables/input_actions.json"
const SCHEMA: String = "gtai.input-actions/1"
const ACTION_DEADZONE: float = 0.08

var bits: Dictionary[StringName, int] = {}
var aim_shift: int = 16
var aim_steps: int = 256
var aim_range_m: float = 14.0
var stick_deadzone: float = 0.25
var accel_mps2: float = 30.0
var brake_mps2: float = 40.0
var turn_dps: float = 720.0
var strafe_scale: float = 0.85
var rows: Array[Dictionary] = []
var errors: Array[String] = []


static func shipped() -> PlayerActions:
	return from_table(DataTable.open(TABLE, SCHEMA))


static func from_table(t: DataTable) -> PlayerActions:
	var a: PlayerActions = PlayerActions.new()
	var aim: Dictionary = t.object(t.raw, "aim")
	a.aim_shift = t.integer(aim, "aim_shift")
	a.aim_steps = t.integer(aim, "aim_steps")
	a.aim_range_m = t.num(aim, "aim_range_m")
	a.stick_deadzone = t.num(aim, "stick_deadzone")
	var move: Dictionary = t.object(t.raw, "move")
	a.accel_mps2 = t.num(move, "accel_mps2")
	a.brake_mps2 = t.num(move, "brake_mps2")
	a.turn_dps = t.num(move, "turn_dps")
	a.strafe_scale = t.num(move, "strafe_scale")
	for raw: Variant in t.array(t.raw, "rows"):
		var row: Dictionary = raw if raw is Dictionary else {}
		a.rows.append(row)
		var b: int = t.integer(row, "bit")
		if b >= 0:
			a.bits[StringName(t.text(row, "id"))] = b
	a.errors = t.errors()
	return a


func bit(action: StringName) -> int:
	return bits.get(action, -1)


## Registers every action and its default events into the InputMap (idempotent).
func install() -> void:
	for row: Dictionary in rows:
		var id: StringName = StringName(str(row.get("id", "")))
		if InputMap.has_action(id):
			InputMap.erase_action(id)
		InputMap.add_action(id, ACTION_DEADZONE)
		for ev: InputEvent in events_of(row):
			InputMap.action_add_event(id, ev)


static func events_of(row: Dictionary) -> Array[InputEvent]:
	var out: Array[InputEvent] = []
	for key: Variant in row.get("keys", []):
		var k: InputEventKey = InputEventKey.new()
		k.physical_keycode = OS.find_keycode_from_string(str(key))
		out.append(k)
	for button: Variant in row.get("mouse", []):
		var m: InputEventMouseButton = InputEventMouseButton.new()
		m.button_index = _int(button) as MouseButton
		out.append(m)
	for button: Variant in row.get("joy_buttons", []):
		var j: InputEventJoypadButton = InputEventJoypadButton.new()
		j.button_index = _int(button) as JoyButton
		j.device = -1
		out.append(j)
	for pair: Variant in row.get("joy_axes", []):
		var axis: Array = pair if pair is Array else [0, 1]
		var mo: InputEventJoypadMotion = InputEventJoypadMotion.new()
		mo.axis = _int(axis[0]) as JoyAxis
		mo.axis_value = float(_int(axis[1]))
		mo.device = -1
		out.append(mo)
	return out


## A JSON number (always a float from the JSON class) as an int.
static func _int(v: Variant) -> int:
	if v is int:
		return v
	var f: float = v if v is float else 0.0
	return roundi(f)
