class_name KeysFilmCaps
extends Control
## The event sent to Godot also supplies the glyph. Lifetimes use the take's fixed clock.

const FADE: int = 18
const KEY_SIZE: int = 56
const WORD_SIZE: int = 28

var _glyphs: Dictionary[StringName, String] = {}
var _words: Dictionary[StringName, String] = {}
var _released: Dictionary[StringName, int] = {}
var _tick: int = 0


func send(action: StringName, down: bool, tick: int, word: String) -> bool:
	for bound: InputEvent in InputMap.action_get_events(action):
		if bound is InputEventKey:
			var key: InputEventKey = bound.duplicate() as InputEventKey
			key.pressed = down
			var glyph: String = key.as_text_physical_keycode()
			Input.parse_input_event(key)
			Input.flush_buffered_events()
			_glyphs[action] = glyph
			_words[action] = word
			_released[action] = -1 if down else tick
			var edge: String = "down" if down else "up"
			Log.info("keys_film", "tick %d | %s | %s | %s" % [tick, glyph, action, edge])
			return true
	return false


func advance(tick: int) -> void:
	_tick = tick
	for action: StringName in _released.keys():
		if _released[action] >= 0 and tick - _released[action] >= FADE:
			@warning_ignore("return_value_discarded")
			_released.erase(action)
	queue_redraw()


func _draw() -> void:
	var x: float = 32.0
	var y: float = size.y - 255.0
	var font: Font = ThemeDB.fallback_font
	for action: StringName in _released:
		var age: int = 0 if _released[action] < 0 else _tick - _released[action]
		var alpha: float = 1.0 - float(age) / FADE
		var glyph: String = _glyphs[action]
		var key_w: float = maxf(72.0, font.get_string_size(glyph, 0, -1, KEY_SIZE).x + 32.0)
		var word: String = _words[action]
		var word_w: float = font.get_string_size(word, 0, -1, WORD_SIZE).x + 36.0
		draw_rect(Rect2(x + 4, y + 5, key_w + word_w, 80), Color(GhostFormHud.INK, alpha))
		draw_rect(Rect2(x, y, key_w, 80), Color(GhostFormHud.PAPER, alpha))
		draw_rect(Rect2(x + key_w, y, word_w, 80), Color(GhostFormHud.INK, alpha))
		draw_rect(Rect2(x + key_w, y + 74, word_w, 6), Color(GhostFormHud.TEAL, alpha))
		draw_string(
			font,
			Vector2(x, y + 60),
			glyph,
			HORIZONTAL_ALIGNMENT_CENTER,
			key_w,
			KEY_SIZE,
			Color(GhostFormHud.INK, alpha)
		)
		draw_string(
			font,
			Vector2(x + key_w, y + 49),
			word,
			HORIZONTAL_ALIGNMENT_CENTER,
			word_w,
			WORD_SIZE,
			Color(GhostFormHud.PAPER, alpha)
		)
		x += key_w + word_w + 16.0
