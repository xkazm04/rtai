class_name HudFeed
extends RefCounted
## Fills quest 1's HudState from the stage and the quest runtime each frame (the boot side of
## features/hud, LAY-05): the beat head, heat pips, cash, weapon and magazine, and the subtitle
## (the runtime's line through QuestText / tr(), or Patch's refusal when the router gives one).

var _text: QuestText = QuestText.new()
var _showcase: WeaponShowcase = WeaponShowcase.new()
var _art: WeaponArt = WeaponArt.new()
var _faces: PortraitBook = PortraitBook.new()


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
	state.weapon_icon = icon_of(StringName(weapon))
	if weapon != "":
		var key: StringName = StringName("WEAPON__%s" % QuestText.symbol(weapon))
		state.weapon = _text.resolve(key, weapon)
	state.ammo = stage.arena.rifle_ammo if weapon == "assault-rifle" else -1
	var line: PackedStringArray = runner.lines.subtitle(_text)
	var current: QuestLine = runner.lines.current
	var who: PackedStringArray = ["", ""]
	if current != null:
		who = PackedStringArray([current.speaker, current.id])
	if stage.refusal_left > 0:
		line = _refusal(stage)
		who = PackedStringArray(
			[stage.router.refuse_line["speaker"], stage.router.refuse_line["id"]]
		)
	if line.size() == 2:
		state.say(line[0], line[1])
		face(state, who[0], who[1])
	else:
		state.silent()


## n8-hud: the speaker's face for line `line_id` (PortraitBook), or none.
func face(state: HudState, speaker: String, line_id: String) -> void:
	state.portrait = _faces.face(speaker, line_id)
	state.portrait_device = _faces.is_device(speaker)
	state.portrait_key = speaker


## n8-hud: the HUD icon of weapon `id`: the showcase's flat icon cut, else the shipped icon part,
## else null (no art row: the ticket shows the name alone).
func icon_of(id: StringName) -> Texture2D:
	if id == &"" or not _art.has(id):
		return null
	var t: Texture2D = _showcase.texture(id, WeaponShowcase.ICON)
	return t if t != null else _art.icon_texture(id)


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
