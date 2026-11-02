class_name D5DialogueRun
extends D5HeroRun
## d5-close evidence (gap 8, the D5 "dialogue close-up" venue): the hero junction at 32 and 48 px/m
## with a comic dialogue panel on a UI layer: two D5 portraits (characters/art/d5/portraits/) at
## real UI size over a cream panel. The text is placeholder ink bars, not strings (the HUD lane
## owns the dialogue UI and its Loc keys). Shows whether the expressions read at UI size over the
## gameplay frame. Launch: d5_hero.gd -- --dialogue=<left>,<right> (portrait file names).

const PORTRAITS: String = "res://features/characters/art/d5/portraits/"
const PAPER: Color = Color(0.949, 0.910, 0.835)
const INK: Color = Color(0.090, 0.075, 0.106)
const PORTRAIT_PX: float = 200.0
const PANEL_H: float = 170.0
const MARGIN: float = 28.0
## placeholder "text" lines: fraction of the text column each bar fills
const LINES: Array[float] = [0.92, 0.78, 0.55]

var left_name: String = "rivet_angry"
var right_name: String = "cop_shouting"


func _init() -> void:
	super._init()
	zooms = [1.0, 1.5]


func _ready() -> void:
	super._ready()
	var ui: CanvasLayer = CanvasLayer.new()
	ui.layer = 20
	add_child(ui)
	var view: Vector2 = get_viewport().get_visible_rect().size
	var top: float = view.y - MARGIN - PANEL_H
	ui.add_child(_box(Rect2(MARGIN, top, view.x - MARGIN * 2.0, PANEL_H), 4))
	var p: float = PORTRAIT_PX
	var y: float = top - p * 0.22
	ui.add_child(_portrait(left_name, Rect2(MARGIN + 16.0, y, p, p)))
	ui.add_child(_portrait(right_name, Rect2(view.x - MARGIN - 16.0 - p, y, p, p)))
	var x0: float = MARGIN + 16.0 + p + 28.0
	var col: float = view.x - 2.0 * x0
	for i: int in LINES.size():
		var bar: ColorRect = ColorRect.new()
		bar.color = INK
		bar.position = Vector2(x0, top + 38.0 + i * 36.0)
		bar.size = Vector2(col * LINES[i], 10.0)
		ui.add_child(bar)


func _box(r: Rect2, border: int) -> Panel:
	var panel: Panel = Panel.new()
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = PAPER
	sb.border_color = INK
	sb.set_border_width_all(border)
	sb.shadow_color = INK
	sb.shadow_size = 1
	sb.shadow_offset = Vector2(6, 6)
	panel.add_theme_stylebox_override(&"panel", sb)
	panel.position = r.position
	panel.size = r.size
	return panel


func _portrait(file: String, r: Rect2) -> Panel:
	var frame: Panel = _box(r.grow(4.0), 4)
	var tex: TextureRect = TextureRect.new()
	tex.texture = load(PORTRAITS + file + ".png") as Texture2D
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	tex.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	tex.position = Vector2(4.0, 4.0)
	tex.size = r.size
	frame.add_child(tex)
	return frame
