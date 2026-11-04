class_name ReelCaption
extends Control
## The director cut's camera (dev capture only; evidence/cut.sh burns each chapter's title card
## with ffmpeg, from ReelChapters' ids and the number() order): the view's
## focus sits FRAME_K of the way from Rivet to the chapter's victims, so Rivet and the kill share
## the frame (the nuke's 15 m lob too). It reads ReelDirector only; render side, not replay state.

const FRAME_K: float = 0.5
## The lean toward the victims is at least this (m): Rivet on the frame's left third.
const LEAN_MIN_M: float = 5.0

var director: ReelDirector = null
var view: CollectCallView = null
var stage: ArenaStage = null


## Adds the caption to `layer` when the stage runs a director cut (else does nothing).
static func attach(layer: CanvasLayer, p_stage: ArenaStage, p_view: CollectCallView) -> void:
	for hook: ArenaHook in p_stage.hooks:
		if hook is ReelDirector:
			var cap: ReelCaption = ReelCaption.new()
			cap.director = hook as ReelDirector
			cap.stage = p_stage
			cap.view = p_view
			cap.process_priority = -10  # before the view places its camera this frame
			cap.set_anchors_preset(Control.PRESET_FULL_RECT)
			cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
			layer.add_child(cap)
			return


func _process(_delta: float) -> void:
	if view == null or director == null or director.spots.is_empty():
		return
	var mid: Vector2 = Vector2.ZERO
	for p: Vector2 in director.spots:
		mid += p
	mid /= director.spots.size()
	var rivet: Vector2 = stage.arena.rivet.pos
	var lean: Vector2 = (mid - (stage.plan.base + ReelDirector.MARK)) * FRAME_K  # from the mark
	view.focus = rivet + lean.normalized() * maxf(lean.length(), LEAN_MIN_M)
