class_name HudView
extends Node2D
## Quest 1's HUD in screen space (under a CanvasLayer): the beat, heat 0-3 as siren pips, cash
## and the weapon in hand, and the subtitle box: the runtime's line on screen (speaker name and
## typed-out words through QuestText / tr()), or Patch's refusal when the router gives one.

const TEXT_SIZE: int = 30
const NAME_SIZE: int = 26
const MARGIN: float = 36.0

const HUD_ART: String = "res://features/hud/art/"
## 9-slice margin of the torn-paper memo frame, in frame px (2x art), and its draw scale.
const MEMO_MARGIN: float = 44.0
const MEMO_SCALE: float = 0.5
## hud_digits.png (features/hud/art/README.md): 112 x 160 cells, cap 120 px, baseline y 140.
const DIGITS: String = "0123456789$/x+-:,.%#"
const DIGIT_CELL: Vector2 = Vector2(112.0, 160.0)
const DIGIT_ADVANCE: PackedFloat32Array = [
	70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 58, 74, 66, 62, 36, 32, 32, 98, 80
]

var stage: CollectCallStage
var system: QuestSystem
var _tex: Dictionary[String, Texture2D] = {}
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
		var pip: Rect2 = Rect2(MARGIN + 110 + i * 46, MARGIN + 52, 38, 38)
		var lit: bool = i < stage.heat.level
		draw_texture_rect(_art("wanted_pip_full" if lit else "wanted_pip_empty"), pip, false)


func _top_right(screen: Vector2) -> void:
	var box: Rect2 = Rect2(screen.x - MARGIN - 420, MARGIN - 8, 420, 104)
	draw_texture_rect(_art("cash_frame"), box, false)
	var cash: String = "$%s" % _thousands(stage.wallet.cash)
	_ink_digits(box.position + Vector2(112, 50), cash, 32.0)
	var weapon: String = stage.weapon_name()
	var weapon_text: String = _text.resolve(
		StringName("WEAPON__%s" % QuestText.symbol(weapon)), weapon
	)
	if weapon == "":
		weapon_text = _text.resolve(&"HUD__UNARMED", "unarmed")
	_say(box.position + Vector2(112, 76), weapon_text, 22, Ink.INK)


func _refusal() -> PackedStringArray:
	var row: Dictionary[String, String] = stage.router.refuse_line
	var who: String = _text.resolve(QuestText.cast_key(row["speaker"]), "Patch")
	return PackedStringArray([who, _text.resolve(StringName(row["key"]), row["text"])])


func _subtitle(screen: Vector2, who: String, words: String) -> void:
	var box: Rect2 = Rect2(MARGIN * 4, screen.y - MARGIN - 236, screen.x - MARGIN * 8, 236)
	_panel(box)
	_say(box.position + Vector2(24, 58), who.to_upper(), NAME_SIZE, Ink.VERMILION)
	var font: Font = ThemeDB.fallback_font
	var at: Vector2 = box.position + Vector2(24, 100)
	draw_multiline_string(font, at, words, 0, box.size.x - 48, TEXT_SIZE, 4, Ink.INK)


func _panel(r: Rect2) -> void:
	# 18 px of extra paper on top: the tape strip sits above the first line of text
	_nine(_art("memo_frame"), r.grow_individual(10.0, 28.0, 10.0, 10.0), MEMO_MARGIN, MEMO_SCALE)


func _art(name: String) -> Texture2D:
	if not _tex.has(name):
		_tex[name] = load(HUD_ART + name + ".png") as Texture2D
	return _tex[name]


## A 9-slice draw of `t` into `r`: corners kept at `scale`, edges and centre stretched.
func _nine(t: Texture2D, r: Rect2, m: float, scale: float) -> void:
	var ts: Vector2 = Vector2(t.get_size())
	var sx: PackedFloat32Array = [0.0, m, ts.x - m, ts.x]
	var sy: PackedFloat32Array = [0.0, m, ts.y - m, ts.y]
	var d: float = m * scale
	var dx: PackedFloat32Array = [r.position.x, r.position.x + d, r.end.x - d, r.end.x]
	var dy: PackedFloat32Array = [r.position.y, r.position.y + d, r.end.y - d, r.end.y]
	for j: int in 3:
		for i: int in 3:
			var src: Rect2 = Rect2(sx[i], sy[j], sx[i + 1] - sx[i], sy[j + 1] - sy[j])
			var dst: Rect2 = Rect2(dx[i], dy[j], dx[i + 1] - dx[i], dy[j + 1] - dy[j])
			draw_texture_rect_region(t, dst, src)


func _say(at: Vector2, words: String, size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, at, words, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


## The hand-inked numeral strip on the baseline `at`, cap height 0.92 of `size` (the condensed caps
## need more height than the sans to carry the same weight). Unknown characters advance a space.
func _ink_digits(at: Vector2, value: String, size: float) -> void:
	var s: float = size * 0.92 / 120.0
	var x: float = at.x
	for ch: String in value:
		var k: int = DIGITS.find(ch)
		if k < 0:
			x += 30.0 * s
			continue
		var adv: float = DIGIT_ADVANCE[k]
		var src: Rect2 = Rect2(Vector2(k * DIGIT_CELL.x, 0.0), DIGIT_CELL)
		var pos: Vector2 = Vector2(x - (DIGIT_CELL.x - adv) * 0.5 * s, at.y - 140.0 * s)
		draw_texture_rect_region(_art("hud_digits"), Rect2(pos, DIGIT_CELL * s), src)
		x += adv * s


func _thousands(n: int) -> String:
	var digits: String = str(absi(n))
	var out: String = ""
	for i: int in digits.length():
		if i > 0 and (digits.length() - i) % 3 == 0:
			out += ","
		out += digits[i]
	return out
