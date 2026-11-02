class_name HudView
extends Node2D
## Quest 1's HUD in screen space (under a CanvasLayer): the beat, heat 0-3 as siren pips, cash
## and the weapon in hand, and the subtitle box: the runtime's line on screen (speaker name and
## typed-out words through QuestText / tr()), or Patch's refusal when the router gives one.

const TEXT_SIZE: int = 30
const NAME_SIZE: int = 26
const MARGIN: float = 36.0

var stage: CollectCallStage
var system: QuestSystem
var _text: QuestText = QuestText.new()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if stage == null or system == null or system.runner == null:
		return
	var screen: Vector2 = get_viewport_rect().size
	_top_left()
	_top_right(screen)
	var line: PackedStringArray = system.runner.lines.subtitle(_text)
	if stage.refusal_left > 0:
		line = _refusal()
	if line.size() == 2:
		_subtitle(screen, line[0], line[1])


func _top_left() -> void:
	var runner: QuestRunner = system.runner
	var beat: QuestBeat = runner.current_beat()
	var title: String = _text.resolve(beat.title_key, beat.title) if beat != null else ""
	if runner.state == QuestRunner.State.SUCCEEDED:
		title = _text.resolve(&"HUD__JOB_DONE", "Job done")
	var head: String = "%d/%d  %s" % [runner.beat_index + 1, runner.pkg.beats.size(), title]
	_panel(Rect2(MARGIN, MARGIN, 640, 96))
	_say(Vector2(MARGIN + 18, MARGIN + 38), head, 30, Ink.INK)
	var heat_word: String = _text.resolve(&"HUD__HEAT", "HEAT")
	_say(Vector2(MARGIN + 18, MARGIN + 80), heat_word, 24, Ink.INK)
	for i: int in stage.heat.max_level:
		var pip: Rect2 = Rect2(MARGIN + 110 + i * 46, MARGIN + 58, 36, 26)
		draw_rect(pip, Ink.VERMILION if i < stage.heat.level else Ink.CREAM, true)
		draw_rect(pip, Ink.INK, false, 3.0)


func _top_right(screen: Vector2) -> void:
	var box: Rect2 = Rect2(screen.x - MARGIN - 380, MARGIN, 380, 96)
	_panel(box)
	var cash: String = "$%s" % _thousands(stage.wallet.cash)
	_say(box.position + Vector2(18, 44), cash, 34, Ink.INK)
	var weapon: String = stage.weapon_name()
	var weapon_text: String = _text.resolve(
		StringName("WEAPON__%s" % QuestText.symbol(weapon)), weapon
	)
	if weapon == "":
		weapon_text = _text.resolve(&"HUD__UNARMED", "unarmed")
	_say(box.position + Vector2(18, 82), weapon_text, 24, Ink.VERMILION)


func _refusal() -> PackedStringArray:
	var row: Dictionary[String, String] = stage.router.refuse_line
	var who: String = _text.resolve(QuestText.cast_key(row["speaker"]), "Patch")
	return PackedStringArray([who, _text.resolve(StringName(row["key"]), row["text"])])


func _subtitle(screen: Vector2, who: String, words: String) -> void:
	var box: Rect2 = Rect2(MARGIN * 4, screen.y - MARGIN - 200, screen.x - MARGIN * 8, 200)
	_panel(box)
	_say(box.position + Vector2(24, 40), who.to_upper(), NAME_SIZE, Ink.VERMILION)
	var font: Font = ThemeDB.fallback_font
	var at: Vector2 = box.position + Vector2(24, 84)
	draw_multiline_string(font, at, words, 0, box.size.x - 48, TEXT_SIZE, 4, Ink.INK)


func _panel(r: Rect2) -> void:
	draw_rect(r, Ink.CREAM, true)
	draw_rect(r, Ink.INK, false, 4.0)


func _say(at: Vector2, words: String, size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, at, words, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


func _thousands(n: int) -> String:
	var digits: String = str(absi(n))
	var out: String = ""
	for i: int in digits.length():
		if i > 0 and (digits.length() - i) % 3 == 0:
			out += ","
		out += digits[i]
	return out
