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
	state.full_words = ""
	if current != null:
		who = PackedStringArray([current.speaker, current.id])
		state.full_words = _text.resolve(current.key, current.text)
	if stage.refusal_left > 0:
		line = _refusal(stage)
		state.full_words = line[1]
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


## n8-hud: fill() for quest 1's `view`, plus the HUD's clear points on its camera (its scale, Kerf's
## glide and the forms lift off Rivet, as ObjectiveView places its ring).
func fill_view(view: CollectCallView, stage: CollectCallStage, system: QuestSystem) -> void:
	fill(view.hud_view.state, stage, system)
	if stage == null:
		return
	var off: Vector2 = Vector2(0.0, view.forms_lift_m)
	if stage.pilot != null:
		off += KerfGlide.offset_m(stage.pilot.kerf, stage.tick)
	var screen: Vector2 = view.hud_view.get_viewport_rect().size
	view.hud_view.state.clear_px = clear(stage, system, screen, view.px_per_m, off)


## n8-hud: the screen points (px) the HUD's corners must not hide on a `screen`-sized view: Rivet,
## the objective's goal (with a quest), every living hostile and, while hot, the police patrols
## (CastView draws them only then): a cop under the ticket is a cop you cannot see. The camera
## centres Rivet less `cam_off_m`; the tilt squashes ground y.
static func clear(
	stage: CollectCallStage,
	system: QuestSystem,
	screen: Vector2,
	px_per_m: float,
	cam_off_m: Vector2
) -> PackedVector2Array:
	var out: Array[Vector2] = []
	if stage == null or not HudSee.SEE:
		return PackedVector2Array()
	var k: Vector2 = Vector2(px_per_m, px_per_m * ViewMode.shared().ground_k())
	var rivet: Vector2 = stage.arena.rivet.pos
	out.append(screen * 0.5 - cam_off_m * k)
	var has_quest: bool = system != null and system.runner != null
	var goal: Vector2 = ObjectiveHint.of(stage, system).goal if has_quest else Vector2.INF
	if goal != Vector2.INF:
		out.append(screen * 0.5 + (goal - rivet - cam_off_m) * k)
	for h: Fighter in stage.arena.hostiles:
		if h.alive():
			out.append(screen * 0.5 + (h.pos - rivet - cam_off_m) * k)
	for p: Vector2 in stage.patrol_pos:
		if stage.heat.level > 0:
			out.append(screen * 0.5 + (p - rivet - cam_off_m) * k)
	return PackedVector2Array(out)
