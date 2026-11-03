class_name HudFeed
extends RefCounted
## Fills quest 1's HudState from the stage and the quest runtime each frame (the boot side of
## features/hud, LAY-05): the beat head, heat pips, cash, weapon and magazine, and the subtitle
## (the runtime's line through QuestText / tr(), or Patch's refusal when the router gives one).

var _text: QuestText = QuestText.new()


func fill(state: HudState, stage: CollectCallStage, system: QuestSystem) -> void:
	if stage == null or system == null or system.runner == null:
		state.head = ""
		state.silent()
		return
	var runner: QuestRunner = system.runner
	state.head = _head(runner)
	state.heat = stage.heat.level
	state.heat_max = stage.heat.max_level
	state.cash = stage.wallet.cash
	state.heat_label = _text.resolve(&"HUD__HEAT", "HEAT")
	state.unarmed_label = _text.resolve(&"HUD__UNARMED", "unarmed")
	var weapon: String = stage.weapon_name()
	state.weapon = ""
	if weapon != "":
		var key: StringName = StringName("WEAPON__%s" % QuestText.symbol(weapon))
		state.weapon = _text.resolve(key, weapon)
	state.ammo = stage.arena.rifle_ammo if weapon == "assault-rifle" else -1
	var line: PackedStringArray = runner.lines.subtitle(_text)
	if stage.refusal_left > 0:
		line = _refusal(stage)
	if line.size() == 2:
		state.say(line[0], line[1])
	else:
		state.silent()


func _head(runner: QuestRunner) -> String:
	var beat: QuestBeat = runner.current_beat()
	var title: String = _text.resolve(beat.title_key, beat.title) if beat != null else ""
	if runner.state == QuestRunner.State.SUCCEEDED:
		title = _text.resolve(&"HUD__JOB_DONE", "Job done")
	return "%d/%d  %s" % [runner.beat_index + 1, runner.pkg.beats.size(), title]


func _refusal(stage: CollectCallStage) -> PackedStringArray:
	var row: Dictionary[String, String] = stage.router.refuse_line
	var who: String = _text.resolve(QuestText.cast_key(row["speaker"]), "Patch")
	return PackedStringArray([who, _text.resolve(StringName(row["key"]), row["text"])])
