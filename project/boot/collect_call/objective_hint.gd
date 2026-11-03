class_name ObjectiveHint
extends RefCounted
## Where quest 1 wants Rivet now and what to press, for a player who has never seen it: one goal
## point per beat state (the dumpster, the ringing phone, the next ally, Dock 9, the crates, the
## Harbor Road skip or phone) and one prompt naming the bound keys (read from the InputMap, so
## a rebinding shows through). Reads the stage and the quest, never writes them.

const MEET_ORDER: Array[String] = ["Juno", "Brass", "Dr. Kilohm", "Don Fax"]

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
			if stage.hidden_in == "":
				h._mark(l.hide_at["dumpster"], &"SLICE__HINT_HIDE", "Hide in the dumpster: [use]")
			else:
				h._mark(Vector2.INF, &"SLICE__HINT_STAY", "Stay hidden. Let the sirens pass.")
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


## The prompt in the player's language, with the ally's name and the bound keys filled in.
func words(t: QuestText) -> String:
	var resolved: String = t.resolve(key, text)
	return with_keys(resolved % arg if arg != "" else resolved)


## The prompt with [action] replaced by the action's first bound key (or mouse button).
static func with_keys(prompt: String) -> String:
	var out: String = prompt
	for action: String in ["use", "fire", "melee"]:
		var id: StringName = &"interact" if action == "use" else StringName(action)
		out = out.replace("[%s]" % action, "[%s]" % key_name(id))
	return out


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
	_mark(dock, &"SLICE__HINT_FIGHT", "Hold Dock 9: aim, [fire] to shoot, [melee] to shock")
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
