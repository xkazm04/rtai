class_name GhostHudHints
extends RefCounted
## Draw the live binding under its chip: the solid chevron names the loaded form and
## the bent arrow points to the form that one cycle press would load.


static func binding(action: StringName) -> String:
	var key: String = ObjectiveHint.key_name(action)
	if key == String(action):
		key = ""
	return PadGlyphArt.action_hint(action, key) if PadGlyphArt.active() else key


static func cycle(hud: GhostFormHud, at: Vector2, hint: String) -> void:
	var points: PackedVector2Array = [at + Vector2(-7, -4), at + Vector2(-7, 1), at + Vector2(6, 1)]
	var tip: PackedVector2Array = [at + Vector2(2, -3), at + Vector2(6, 1), at + Vector2(2, 5)]
	for line: PackedVector2Array in [points, tip]:
		hud.draw_polyline(line, GhostFormHud.PAPER, 4.5, true)
		hud.draw_polyline(line, GhostFormHud.INK, 2.0, true)
	label(hud, at, hint)


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
