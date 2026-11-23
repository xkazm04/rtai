class_name GhostHudHints
extends RefCounted
## Draw the live deploy binding under the loaded form when a device supplies one.


static func binding(action: StringName) -> String:
	var key: String = ObjectiveHint.key_name(action)
	if key == String(action):
		key = ""
	return PadGlyphArt.action_hint(action, key) if PadGlyphArt.active() else key


static func label(hud: GhostFormHud, at: Vector2, hint: String) -> void:
	var ts: int = hud.layout.text_size
	var baseline: Vector2 = at + Vector2(0.0, 6.0 + ts)
	if PadGlyphArt.active():
		baseline.x -= PadGlyphArt.line_size(hint, ts).x * 0.5
		PadGlyphArt.draw_line(hud, baseline, hint, ts, GhostFormHud.INK)
	else:
		var font: Font = ThemeDB.fallback_font
		baseline.x -= font.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, ts).x * 0.5
		hud._text(font, baseline, hint)
