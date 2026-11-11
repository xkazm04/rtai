class_name HideTuck
extends Node
## n15 hero: quest 1's hide spot under the cast rigs. While Rivet is tucked in a hide spot
## (`stage.hidden_in`), his rig and the weapon views riding on it are hidden, so CastView's peek
## card is all that shows of him; before, the rigs drew him standing on the bin. Runs after
## GhostFormView, which sets the same rig's visibility every frame. View only. TUCK false = before.

const TUCK: bool = true
const AFTER_GHOST_VIEW: int = 100

var stage: CollectCallStage = null
var cast: ArenaRigs = null
var _tucked: bool = false


## Logs the cast's attach (Quest1Game's line) and, when it attached, tucks Rivet in hide spots.
static func attach(p_cast: ArenaRigs, p_stage: CollectCallStage, ok: bool) -> void:
	Log.info("quest1", "cast rigs: %s" % ok)
	if not ok or not TUCK or p_stage == null:
		return
	var t: HideTuck = HideTuck.new()
	t.stage = p_stage
	t.cast = p_cast
	t.process_priority = AFTER_GHOST_VIEW
	p_cast.add_child(t)


## Hides `rig` and Rivet's held views while `tucked`; shows them again on the frame it ends
## (GhostFormView hides them again from the next frame if a form stands in).
static func apply(rig: CanvasItem, views: Array[CanvasItem], tucked: bool) -> void:
	if rig != null:
		rig.visible = not tucked
	for v: CanvasItem in views:
		v.visible = not tucked


func _process(_delta: float) -> void:
	if stage == null or cast == null or cast.rigs == null:
		return
	var tucked: bool = stage.hidden_in != ""
	if not tucked and not _tucked:
		return
	_tucked = tucked
	var views: Array[CanvasItem] = []
	for n: Node in cast.rigs.get_parent().get_children():  # the claw's weapon and magazine views
		if n is RivetHeldView or n is WeaponMagView:
			views.append(n as CanvasItem)
	apply(cast.rigs.rig_for(stage.arena.rivet.id), views, tucked)
