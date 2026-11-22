class_name GauntletPickCard
extends Button
## A keyboard-focusable offer on the HUD's memo paper, using the arena's ghost and weapon art.

const INK: Color = HudArt.INK

var row: Dictionary
var art: HudArt
var feed: HudFeed
var _kind: String
var _title: String
var _number: String
var _illustration: Texture2D
var _ghost: GhostCard


func _ready() -> void:
	flat = true
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	custom_minimum_size = Vector2(238, 232)
	var ref: StringName = row["ref"]
	var kind: String = str(row["kind"]).to_upper()
	_title = tr("GAUNTLET__%s__%s" % [kind, String(ref).to_upper()])
	_kind = tr("GAUNTLET__KIND__%s" % kind)
	match str(row["kind"]):
		"stat":
			# All stat strengths share the same translated stat name.
			var k: float = row["k"]
			_number = tr("GAUNTLET__GAIN").format({"percent": roundi((k - 1.0) * 100.0)})
		"weapon":
			_illustration = feed.icon_of(ref)
		"ghost":
			_illustration = GhostChipFace.face(ref)
			var host: Node2D = Node2D.new()
			host.position = custom_minimum_size * Vector2(0.5, 0.54)
			add_child(host)
			_ghost = GhostCard.new(String(ref), 3.4, 0.5)
			_ghost.step(host, [], Vector2.ZERO, 32.0)
			if _ghost.is_drawn():
				var sprite: Sprite2D = host.get_node(^"ghost_card") as Sprite2D
				var height_px: float = sprite.get_rect().size.y * sprite.scale.y
				host.scale = Vector2.ONE * minf(1.0, 96.0 / height_px)
	var title: String = _title
	if not _number.is_empty():
		title = tr("GAUNTLET__GAIN_TITLE").format({"gain": _number, "title": _title})
	accessibility_name = tr("GAUNTLET__CARD_NAME").format({"kind": _kind, "title": title})


func _draw() -> void:
	if art == null:
		return
	var box: Rect2 = Rect2(Vector2.ZERO, size)
	var paper: Texture2D = art.texture(art.memo_art)
	HudView.nine(self, paper, box, art.memo_margin_px, art.memo_scale)
	var font: Font = ThemeDB.fallback_font
	var left: Vector2 = Vector2(23, 50)
	draw_string(font, left, _kind.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, size.x - 88, 15, INK)
	var key: Rect2 = Rect2(size.x - 51, 25, 28, 27)
	draw_rect(key, INK)
	draw_string(
		font,
		key.position + Vector2(0, 20),
		tr("GAUNTLET__SLOT").format({"slot": get_index() + 1}),
		HORIZONTAL_ALIGNMENT_CENTER,
		key.size.x,
		17,
		Color.WHITE
	)
	draw_line(Vector2(23, 60), Vector2(size.x - 23, 60), Color(INK, 0.4), 1.0)
	if not _number.is_empty():
		draw_string(font, Vector2(0, 148), _number, HORIZONTAL_ALIGNMENT_CENTER, size.x, 49, INK)
	elif _illustration != null and (_ghost == null or not _ghost.is_drawn()):
		var band: Vector2 = Vector2(size.x - 70, 91)
		var tex: Vector2 = _illustration.get_size()
		var fit: Vector2 = tex * minf(band.x / tex.x, band.y / tex.y)
		draw_texture_rect(_illustration, Rect2(Vector2(size.x * 0.5, 121) - fit * 0.5, fit), false)
	draw_string(
		font, Vector2(14, size.y - 34), _title, HORIZONTAL_ALIGNMENT_CENTER, size.x - 28, 22, INK
	)
	_draw_focus()


func _draw_focus() -> void:
	if has_focus() or is_hovered():
		draw_rect(Rect2(Vector2(8, 9), size - Vector2(16, 17)), INK, false, 2.0)
