class_name StoryForms
extends Node
## ghost-forms: the ghost forms on quest 1's shipped sprite cast. The cast rigs (dev `--rigs`) bring
## GhostFormView; without them the sim still ran GhostPilot (Q / LB transformed Rivet) but nothing
## drew the form, the teal morph or the HUD card. This attaches one GhostFormView with no rigs in
## the printed actors' layer (the city's, else the print stage's) on that view's camera, and tells
## CastView to leave Rivet's sprite out while a ghost body stands in for him. The view's own
## apparition is the story voice (the selected ghost, silent in a form); ghost_forms.json
## story_voice false unbinds it. ghost_forms.json story_forms false = the voice alone (StoryVoice).
## View only: headless runs have no view, so scenarios and replay are untouched.

## Rivet's health bar above his spot (m), as CastView drew it before the forms.
const BAR_LIFT_M: float = 1.2

var form_view: GhostFormView = null
var voice: StoryVoice = null
var _hud: HudView = null


## Adds the forms (or, with story_forms off or no pilot, the voice alone) to `host` for `view`.
static func attach(
	host: Node, view: CollectCallView, stage: CollectCallStage, reduced_motion: bool
) -> StoryForms:
	var table: GhostFormTable = GhostFormTable.load_default()
	if view == null or stage == null:
		return null
	var s: StoryForms = StoryForms.new()
	var layer: CanvasLayer = _actor_layer(view)
	var v: GhostFormView = _make(stage, view) if table.story_forms and layer != null else null
	if v == null:
		s.voice = StoryVoice.attach(host, view, stage, reduced_motion)
	else:
		v.reduced_motion = reduced_motion
		if not table.story_voice:
			v.events = null
		layer.add_child(v)
		view.cast_view.forms_drawn = true
		s.form_view = v
		s._hud = view.hud_view
	host.add_child(s)
	return s


## The form card folds to one chip while the story's subtitle box is up (it takes the bottom
## centre).
func _process(_delta: float) -> void:
	if form_view != null and _hud != null:
		form_view.hud.compact = _hud.state.speaker != ""


## True while any ghost body stands in for Rivet (settled in a form, or past its in-between pose).
static func stands_in(forms: GhostForms) -> bool:
	if forms == null or (forms.settled() and forms.current() == GhostForms.BASE):
		return false
	for id: StringName in forms.table.order:
		if GhostFormView.big(forms, id):
			return true
	return false


## How far above Rivet's spot (m) his health bar rides: clear of the body that stands in for him
## (ghost_forms.json bar_m: Kerf's front blades reach past the old 1.2 m, Tonnage's press past
## its radius). Through a transformation it eases from the leaving body's height to the coming
## one's around the in-between pose (k 0.3 -> 0.7), so it no longer snaps at the midpoint.
static func bar_lift_m(forms: GhostForms) -> float:
	if forms == null:
		return BAR_LIFT_M
	var from_m: float = _bar_of(forms, forms.from_id)
	if forms.settled():
		return from_m
	return lerpf(from_m, _bar_of(forms, forms.to_id), smoothstep(0.3, 0.7, forms.k()))


static func _bar_of(forms: GhostForms, id: StringName) -> float:
	var d: GhostFormDef = forms.table.form(id) if id != GhostForms.BASE else null
	return maxf(BAR_LIFT_M, d.bar_m) if d != null else BAR_LIFT_M


static func _make(stage: CollectCallStage, view: CollectCallView) -> GhostFormView:
	var cam: CameraRig = (
		view.city_view.rig
		if view.city_view != null
		else (view.print_stage.rig if view.print_stage != null else null)
	)
	return GhostFormView.make(stage, null, cam)


static func _actor_layer(view: CollectCallView) -> CanvasLayer:
	if view.city_view != null:
		return view.city_view.actor_layer()
	return view.print_stage.actor_layer() if view.print_stage != null else null
