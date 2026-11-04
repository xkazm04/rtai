class_name HordeOverlay
extends Control
## Dev overlay for the arena's --horde (corpse decay evidence): bottom left, the bodies on the
## floor against the cap, the dead so far, the fight's list size and the real frame time; every
## WINDOW frames one log line (bodies, peak, died, frame ms mean and worst) so a run shows the
## frame time staying flat while the dead pile up. Reads the hook, never writes.

const FONT_PX: int = 20
const WINDOW: int = 300

var hook: CorpseDecayHook = null
var arena: CombatArena = null
var _last_us: int = 0
var _sum_us: int = 0
var _worst_us: int = 0
var _frames: int = 0
var _frame_ms: float = 0.0


## Puts the overlay on `layer` when the stage carries the corpse decay hook.
static func attach(layer: CanvasLayer, stage: ArenaStage) -> void:
	for h: ArenaHook in stage.hooks:
		if h is CorpseDecayHook:
			var o: HordeOverlay = HordeOverlay.new()
			o.hook = h as CorpseDecayHook
			o.arena = stage.arena
			o.set_anchors_preset(Control.PRESET_FULL_RECT)
			o.mouse_filter = Control.MOUSE_FILTER_IGNORE
			layer.add_child(o)


func _process(_delta: float) -> void:
	var now: int = Time.get_ticks_usec()
	if _last_us > 0:
		var us: int = now - _last_us
		_frame_ms = us / 1000.0
		_sum_us += us
		_worst_us = maxi(_worst_us, us)
		_frames += 1
	_last_us = now
	if _frames >= WINDOW:
		Log.info("horde", _line())
		_sum_us = 0
		_worst_us = 0
		_frames = 0
	queue_redraw()


func _draw() -> void:
	if hook == null:
		return
	var b: DecayLedger = hook.decay.bodies
	var text: String = (
		tr("bodies on the floor %d / %d   dead %d   frame %.1f ms")
		% [b.count(), b.cap, hook.died, _frame_ms]
	)
	var at: Vector2 = Vector2(16.0, size.y - 24.0)
	var box: Rect2 = Rect2(at - Vector2(8.0, FONT_PX + 6.0), Vector2(560.0, FONT_PX + 18.0))
	draw_rect(box, Color(Ink.CREAM, 0.9), true)
	draw_rect(box, Ink.INK, false, 2.0)
	draw_string(ThemeDB.fallback_font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_PX, Ink.INK)


func _line() -> String:
	var b: DecayLedger = hook.decay.bodies
	return (
		"bodies %d peak %d cap %d died %d pruned %d listed %d frame mean %.2f ms worst %.2f ms"
		% [
			b.count(),
			b.peak,
			b.cap,
			hook.died,
			hook.pruned,
			arena.hostiles.size(),
			_sum_us / 1000.0 / maxf(1.0, _frames),
			_worst_us / 1000.0
		]
	)
