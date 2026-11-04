class_name KillGround
extends Node2D
## One signature kill's print on the street (lane brutality, render only): its red spray, its
## scorch and its ash heap, and above them the drag smears of its sliding parts, each blot
## appended once to a child canvas item as the part slides (a per-frame redraw of every smear
## held the rocket's slide at 2-4 ms a frame on the city block, CONTENDED). One node per kill,
## so a new kill reprints only its own print, never every leftover (that full reprint was the
## kill-frame spike: 74 ms worst after 18 kills, CONTENDED). No RNG.

var view: KillView = null
var mark: KillMarks.Mark = null
var serial: int = -1
var _smears: RID = RID()


func _draw() -> void:
	var t0: int = Time.get_ticks_usec()
	if view.kills.tick - mark.tick >= mark.spray_from:
		KillMarkArt.spray(self, mark, view.ppm)
	KillMarkArt.scorch(self, mark, view.ppm)
	KillCharFx.pile(self, mark, view.kills.tick, view.ppm)
	view.add_us(Time.get_ticks_usec() - t0)


## Point `k` of a part's slide, `run_px` from where it landed (KillView._grow_trail).
func smear_blot(at: Vector2, k: int, run_px: float) -> void:
	if not _smears.is_valid():
		_smears = RenderingServer.canvas_item_create()
		RenderingServer.canvas_item_set_parent(_smears, get_canvas_item())
	KillMarkArt.smear_blot(_smears, at, k, run_px, view.ppm)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and _smears.is_valid():
		RenderingServer.free_rid(_smears)


## An ash heap still growing in (KillCharFx.pile's 45 ticks) is reprinted every frame; a burst's
## print once more on the tick its spray lands (the pop).
func needs_reprint(tick: int) -> bool:
	if mark.spray_from > 0 and tick - mark.tick == mark.spray_from:
		return true
	var age: int = tick - mark.tick - mark.ash_from
	return mark.ash_m > 0.0 and age >= 0 and age <= 46
