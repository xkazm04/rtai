class_name PrologueView
extends CollectCallView

var encounter: PrologueEncounter
var live: LiveInput
var _text: QuestText = QuestText.new()


func _process(_dt: float) -> void:
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
