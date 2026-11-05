class_name StoryVoice
extends Node
## ghost-forms: the voices in the shipped story. Quest 1's sprite cast has no GhostFormView (that
## comes only with the dev `--rigs` cast), so on a whisper (Events.whispers_spiked on the stage's
## bus) nothing showed the voice but the rings. This node draws one GhostApparition beside Rivet:
## the selected ghost (Rivet in base, the first in ghost_forms.json order) rises in teal, speaks
## for its hold and fades. View only: it reads the stage and never writes the sim; it is stepped by
## the sim ticks that passed since the last frame (none while paused). Off when ghost_forms.json
## story_voice is false.

var app: GhostApparition = GhostApparition.new()
var _stage: CollectCallStage = null
var _last_tick: int = -1


## Adds the voice to `host` drawing into `view`; null when the table turns it off.
static func attach(
	host: Node, view: CollectCallView, stage: CollectCallStage, reduced_motion: bool
) -> StoryVoice:
	var table: GhostFormTable = GhostFormTable.load_default()
	if view == null or stage == null or not table.story_voice:
		return null
	var v: StoryVoice = StoryVoice.new()
	v._stage = stage
	v.app.reduced_motion = reduced_motion
	var layer: CanvasLayer = (
		view.city_view.actor_layer()
		if view.city_view != null
		else (view.print_stage.actor_layer() if view.print_stage != null else null)
	)
	if layer != null:  # the printed actors' layer: on the city (quest 1 ships there) or the stage
		v.app.z_index = RenderLayers.z(&"actors") + GhostFormView.Z_OVER_RIGS
		layer.add_child(v.app)
	else:
		v.app.scale = Vector2.ONE * Ink.PX_PER_M / SimConst.PX_PER_M
		view.add_child(v.app)
	v.app.bind(GhostForms.new(table, SoulPowers.new(PowerTable.load_default())), stage.events())
	host.add_child(v)
	return v


func _process(_delta: float) -> void:
	var steps: int = 0 if _last_tick < 0 else maxi(0, _stage.tick - _last_tick)
	_last_tick = _stage.tick
	var r: Fighter = _stage.arena.rivet if _stage.arena != null else null
	if r == null:
		return
	app.step(r.pos * SimConst.PX_PER_M, r.facing.angle(), steps, _stage.tick)
