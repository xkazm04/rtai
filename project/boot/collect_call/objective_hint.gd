class_name ObjectiveHint
extends RefCounted
## Where quest 1 wants Rivet now and what to press, for a player who has never seen it: one goal
## point per beat state (the dumpster, the ringing phone, the next ally, Dock 9, the crates, the
## Harbor Road skip or phone) and one prompt naming the bound keys, or the pad's buttons when a
## pad was used last (read from the InputMap, so a rebinding shows through). Reads only.

const MEET_ORDER: Array[String] = ["Juno", "Brass", "Dr. Kilohm", "Don Fax"]
## Glyph labels for a pad in the common A/B/X/Y layout (Godot's JoyButton / JoyAxis numbers).
const PAD_BUTTONS: Dictionary[int, String] = {
	0: "A", 1: "B", 2: "X", 3: "Y", 4: "Back", 6: "Start", 9: "LB", 10: "RB"
}
const PAD_AXES: Dictionary[int, String] = {4: "LT", 5: "RT"}

var goal: Vector2 = Vector2.INF
var key: StringName = &""
var text: String = ""
## Formatted into the resolved text's %s ("" for none).
var arg: String = ""


static func of(stage: CollectCallStage, system: QuestSystem) -> ObjectiveHint:
	var h: ObjectiveHint = ObjectiveHint.new()
	var runner: QuestRunner = system.runner
	var beat: QuestBeat = runner.current_beat() if runner != null else null
	if beat == null or runner.state != QuestRunner.State.ACTIVE:
		return h
	var l: StageLayout = stage.layout
	match beat.id:
		"b1-dumpster":
			h._dumpster(stage)
		"b2-payphone":
			h._mark(
				l.phones["Factory Row corner"], &"SLICE__HINT_PHONE", "Answer the payphone: [use]"
			)
		"b3-toner-room":
			h._meet(stage, runner)
		"b4-dock":
			h._dock(stage)
		"b5-quartermaster":
			h._boss(stage)
		"b6-hot-walk":
			if stage.heat.level > 0:
				h._mark(
					l.hide_at["harbor-skip"], &"SLICE__HINT_COOL", "Too hot to call. Hide: [use]"
				)
			else:
				h._mark(
					l.phones["Harbor Road"], &"SLICE__HINT_PAID", "Call Patch to get paid: [use]"
				)
	return h


## The prompt in the player's language, the ally's name and the keys (pad buttons if `pad`) in.
func words(t: QuestText, pad: bool = false) -> String:
	var resolved: String = t.resolve(key, text)
	return with_keys(resolved % arg if arg != "" else resolved, pad)


## The prompt with [action] replaced by the action's first bound key (or mouse button), or by its
## first pad button or trigger when `pad`.
static func with_keys(prompt: String, pad: bool = false) -> String:
	var move: Array[String] = []
	for dir: String in ["up", "left", "down", "right"]:
		move.append(key_name(StringName("move_" + dir)))
	var move_label: String = "L-stick" if pad else " ".join(PackedStringArray(move))
	var out: String = prompt.replace("[move]", "[%s]" % move_label)
	out = out.replace("[aim]", "[R-stick]" if pad else "[mouse]")
	for action: String in ["use", "fire", "melee", "pause"]:
		var id: StringName = &"interact" if action == "use" else StringName(action)
		out = out.replace("[%s]" % action, "[%s]" % (pad_name(id) if pad else key_name(id)))
	for i: int in RivetCarry.SLOTS:  # n7-melee: [slot2] -> the carry slot's key
		out = out.replace("[slot%d]" % (i + 1), "[%s]" % key_name(RivetCarry.SLOT_ACTIONS[i]))
	return out


## The action's first pad button or trigger label ("A", "RT"); the key name when it has none.
static func pad_name(action: StringName) -> String:
	if not InputMap.has_action(action):
		return String(action)
	for ev: InputEvent in InputMap.action_get_events(action):
		if ev is InputEventJoypadButton:
			var b: InputEventJoypadButton = ev
			if PAD_BUTTONS.has(b.button_index):
				return PAD_BUTTONS[b.button_index]
		if ev is InputEventJoypadMotion:
			var m: InputEventJoypadMotion = ev
			if PAD_AXES.has(m.axis):
				return PAD_AXES[m.axis]
	return key_name(action)


static func key_name(action: StringName) -> String:
	if not InputMap.has_action(action):
		return String(action)
	for ev: InputEvent in InputMap.action_get_events(action):
		if ev is InputEventKey:
			var k: InputEventKey = ev
			return OS.get_keycode_string(k.physical_keycode)
		if ev is InputEventMouseButton:
			var m: InputEventMouseButton = ev
			return "LMB" if m.button_index == MOUSE_BUTTON_LEFT else "RMB"
	return String(action)


func _mark(at: Vector2, k: StringName, english: String) -> void:
	goal = at
	key = k
	text = english


## The first minute: walk and hide, then (while the sirens pass) the pause key.
func _dumpster(stage: CollectCallStage) -> void:
	if stage.hidden_in == "":
		var at: Vector2 = stage.layout.hide_at["dumpster"]
		_mark(at, &"SLICE__HINT_HIDE", "Walk [move] to the dumpster, hide: [use]")
	else:
		_mark(Vector2.INF, &"SLICE__HINT_STAY", "Stay hidden. Let the sirens pass. [pause] pauses.")


func _meet(stage: CollectCallStage, runner: QuestRunner) -> void:
	if runner.lines.busy():
		_mark(Vector2.INF, &"SLICE__HINT_LISTEN", "Listen.")
		return
	for tag: String in MEET_ORDER:
		if not runner.objective.met.has(tag) and stage.layout.places.actors.has(tag):
			var at: Vector2 = stage.layout.places.actors[tag].at
			_mark(at, &"SLICE__HINT_MEET", "Talk to %s: [use]")
			arg = tag
			return
	_mark(Vector2.INF, &"SLICE__HINT_LISTEN", "Listen.")


func _dock(stage: CollectCallStage) -> void:
	var dock: Vector2 = stage.layout.marker("Dock 9 bonded storage").at
	var fight: String = "Hold Dock 9: aim [aim], [fire] to shoot, [melee] to shock"
	var carry: RivetCarry = stage.pilot.carry if stage.pilot != null else null
	if carry != null and carry.sheathe:  # n7-melee: quest 1's carried blade and its key
		for i: int in RivetCarry.SLOTS:
			if carry.slots[i] != &"":
				fight += ", [slot%d] for the blade" % (i + 1)
				break
	_mark(dock, &"SLICE__HINT_FIGHT", fight)
	var arena: CombatArena = stage.arena
	if not arena.rifle_drops.is_empty() and arena.rivet.weapon != &"assault-rifle":
		_mark(arena.rifle_drops[0], &"SLICE__HINT_RIFLE", "Grab the rifle: [use]")


func _boss(stage: CollectCallStage) -> void:
	var boss: Fighter = stage.arena.boss
	if boss == null or boss.alive():
		_mark(Vector2.INF, &"SLICE__HINT_BOSS", "Mertz: shoot him when he vents. [fire]")
	elif not stage.crates_burning:
		_mark(stage.layout.crates_at, &"SLICE__HINT_TORCH", "Torch the crates: [use]")
	else:
		_mark(Vector2.INF, &"SLICE__HINT_WATCH", "Watch it burn.")
