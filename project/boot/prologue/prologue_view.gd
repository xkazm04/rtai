class_name PrologueView
extends CollectCallView

var encounter: PrologueEncounter
var live: LiveInput
var _text: QuestText = QuestText.new()


func _process(_dt: float) -> void:
	# The gate is south of Rivet. Reserve the subtitle's part of the view for the ground
	# behind the arriving patrol. Release the lean over half a second as the fight begins.
	var weight: float = 1.0
	if encounter.dale_died >= 0:
		weight = clampf(1.0 - float(_stage.tick - encounter.dale_died) / 30.0, 0.0, 1.0)
	var k: float = px_per_m * ViewMode.shared().ground_k()
	var lean_m: float = get_viewport_rect().size.y * 0.18 / k
	focus = _stage.arena.rivet.pos + Vector2.DOWN * lean_m * weight
	super._process(SimClock.TICK_DT)
	var hint: String = encounter.prompts.words(live.pad_last)
	if (
		hint == ""
		and encounter.phase == PrologueEncounter.Phase.TALK
		and encounter.lines.current != ""
	):
		hint = ObjectiveHint.with_keys(
			_text.resolve(&"PROLOGUE__SKIP", "Skip line [use]"), live.pad_last
		)
	hud_view.state.notice = hint


func rivet_screen() -> Vector2:
	return get_viewport().get_canvas_transform() * (_stage.arena.rivet.pos * SimConst.PX_PER_M)
