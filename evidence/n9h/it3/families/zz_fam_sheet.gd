extends Node2D
## Scratch (n9 it3, not committed): the controls line and a quest prompt in the three pad families.

var out: String = ""


func _ready() -> void:
	out = OS.get_cmdline_user_args()[0]
	DeviceProfile.select("deck").apply(get_window())
	PlayerActions.shipped().install()
	RenderingServer.set_default_clear_color(Ink.CREAM)
	queue_redraw()
	_save.call_deferred()


func _fam(text: String, fam: StringName) -> String:
	var o: String = text
	for k: String in PadGlyphs.RELABEL[&"playstation"]:
		o = o.replace("[%s]" % k, "[@%s]" % k)
	for k: String in PadGlyphs.RELABEL[&"playstation"]:
		o = o.replace("[@%s]" % k, "[%s]" % PadGlyphs.relabel(k, fam))
	return o


func _draw() -> void:
	var line: String = ObjectiveHint.with_keys(Quest1Card.CONTROLS_PAD.split("\n")[0], true)
	var line2: String = ObjectiveHint.with_keys(Quest1Card.CONTROLS_PAD.split("\n")[1], true)
	var y: float = 70.0
	for fam: StringName in [&"xbox", &"playstation", &"nintendo"]:
		draw_string(ThemeDB.fallback_font, Vector2(40, y), String(fam), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Ink.INK)
		PadGlyphArt.draw_line(self, Vector2(40, y + 50), _fam(line, fam), 24, Ink.INK)
		PadGlyphArt.draw_line(self, Vector2(40, y + 100), _fam(line2, fam), 24, Ink.INK)
		y += 170.0


func _save() -> void:
	for i: int in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var err: Error = get_viewport().get_texture().get_image().save_png(out)
	Log.info("fam", "saved %d" % err)
	get_tree().quit(0)
