class_name D5DialogueRun
extends D5HeroRun
## d5-close evidence (gap 8, the D5 "dialogue close-up" venue): the hero junction at 32 and 48 px/m
## with a comic dialogue panel on a UI layer: two D5 portraits (characters/art/d5/portraits/) at
## real UI size over a cream panel. The text is placeholder ink bars, not strings (the HUD lane
## owns the dialogue UI and its Loc keys). Shows whether the expressions read at UI size over the
## gameplay frame. Launch: d5_hero.gd -- --dialogue=<left>,<right> (portrait file names).
## --phone=<portrait> instead shows the phone close-up: the D5 phone frame (menus/art/d5/) with
## the portrait behind its keyed screen and a placeholder call strip.
## Dev A/B (iteration 10): D5_UI=sharp draws the portraits and the phone frame through look_d5_ui
## (D5_UI_SHARP overrides its unsharp amount, default 0.5); D5_UI_PX = the portrait size
## (default 200; 270 = a 1080p panel).

const PORTRAITS: String = "res://features/characters/art/d5/portraits/"
const PAPER: Color = Color(0.949, 0.910, 0.835)
const INK: Color = Color(0.090, 0.075, 0.106)
const PORTRAIT_PX: float = 200.0
const PANEL_H: float = 170.0
const MARGIN: float = 28.0
## placeholder "text" lines: fraction of the text column each bar fills
const LINES: Array[float] = [0.92, 0.78, 0.55]

const PHONE: String = "res://features/menus/art/d5/phone_frame.png"
## the keyed screen hole as fractions of the frame (tools/install_king_top.py prints them)
const SCREEN: Rect2 = Rect2(0.127, 0.1383, 0.75, 0.7064)
const PHONE_H: float = 600.0
const UI_SHADER: String = "res://assets/shaders/look_d5_ui.gdshader"

var left_name: String = "rivet_angry"
var right_name: String = "cop_shouting"
var phone_name: String = ""


func _init() -> void:
	super._init()
	zooms = [1.0, 1.5]


func _ready() -> void:
	super._ready()
	var ui: CanvasLayer = CanvasLayer.new()
	ui.layer = 20
	add_child(ui)
	var view: Vector2 = get_viewport().get_visible_rect().size
	if phone_name != "":
		_phone(ui, view)
		return
	var top: float = view.y - MARGIN - PANEL_H
	ui.add_child(_box(Rect2(MARGIN, top, view.x - MARGIN * 2.0, PANEL_H), 4))
	var p: float = OS.get_environment("D5_UI_PX").to_float()
	p = p if p > 0.0 else PORTRAIT_PX
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
	_ui_print(tex)
	tex.position = Vector2(4.0, 4.0)
	tex.size = r.size
	frame.add_child(tex)
	return frame


func _phone(ui: CanvasLayer, view: Vector2) -> void:
	var frame: TextureRect = TextureRect.new()
	frame.texture = load(PHONE) as Texture2D
	var aspect: float = float(frame.texture.get_width()) / frame.texture.get_height()
	var size: Vector2 = Vector2(PHONE_H * aspect, PHONE_H)
	var at: Vector2 = Vector2(view.x - MARGIN - size.x, view.y - MARGIN - size.y)
	var screen: Rect2 = Rect2(at + SCREEN.position * size, SCREEN.size * size)
	var pic: Panel = _portrait(phone_name, screen)
	(pic.get_theme_stylebox(&"panel") as StyleBoxFlat).shadow_size = 0
	ui.add_child(pic)
	var strip: ColorRect = ColorRect.new()
	strip.color = PAPER
	strip.position = Vector2(screen.position.x, screen.end.y - 74.0)
	strip.size = Vector2(screen.size.x, 74.0)
	ui.add_child(strip)
	for i: int in 2:
		var bar: ColorRect = ColorRect.new()
		bar.color = INK
		bar.position = strip.position + Vector2(18.0, 18.0 + i * 26.0)
		bar.size = Vector2((screen.size.x - 36.0) * (0.8 - i * 0.3), 9.0)
		ui.add_child(bar)
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_ui_print(frame)
	frame.position = at
	frame.size = size
	ui.add_child(frame)


func _ui_print(node: CanvasItem) -> void:
	if OS.get_environment("D5_UI") != "sharp":
		return
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = load(UI_SHADER) as Shader
	if OS.get_environment("D5_UI_SHARP") != "":
		mat.set_shader_parameter(&"sharp", OS.get_environment("D5_UI_SHARP").to_float())
	node.material = mat
