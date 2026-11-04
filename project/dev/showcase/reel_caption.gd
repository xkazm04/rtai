class_name ReelCaption
extends Control
## The director cut's title card (dev capture only): the running chapter's number and weapon in
## the top-left corner, ink on a cream plate, burned into the film. It reads ReelDirector only.

const FONT_PX: int = 26
const PAD: Vector2 = Vector2(14.0, 10.0)
const AT: Vector2 = Vector2(24.0, 24.0)

var director: ReelDirector = null


## Adds the caption to `layer` when the stage runs a director cut (else does nothing).
static func attach(layer: CanvasLayer, stage: ArenaStage) -> void:
	for hook: ArenaHook in stage.hooks:
		if hook is ReelDirector:
			var cap: ReelCaption = ReelCaption.new()
			cap.director = hook as ReelDirector
			cap.set_anchors_preset(Control.PRESET_FULL_RECT)
			cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
			layer.add_child(cap)
			return


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var c: ReelChapters.Chapter = director.chapter() if director != null else null
	if c == null:
		return
	var font: Font = ThemeDB.fallback_font
	var line: String = "%02d  %s" % [director.index + 1, c.title()]
	var size: Vector2 = font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_PX)
	var plate: Rect2 = Rect2(AT, size + PAD * 2.0)
	draw_rect(plate, Ink.CREAM)
	draw_rect(plate, Ink.INK, false, 3.0)
	var base: Vector2 = AT + PAD + Vector2(0.0, font.get_ascent(FONT_PX))
	draw_string(font, base, line, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_PX, Ink.INK)
