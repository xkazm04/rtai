extends GutTest
## boot/collect_call StoryVoice: the voices on quest 1's shipped sprite cast. The table turns it on;
## a whisper on the stage's own bus raises the apparition beside Rivet; it ages on sim ticks only.


func _voice() -> Array:
	var stage: CollectCallStage = CollectCallPlay.begin().stage
	var view: CollectCallView = CollectCallView.new()
	add_child_autofree(view)
	var host: Node = Node.new()
	add_child_autofree(host)
	var v: StoryVoice = StoryVoice.attach(host, view, stage, false)
	return [v, stage]


func test_the_shipped_table_turns_the_story_voice_on() -> void:
	assert_true(GhostFormTable.load_default().story_voice, "ghost_forms.json story_voice")
	assert_null(StoryVoice.attach(Node.new(), null, null, false), "no view, no voice")


func test_a_whisper_raises_the_ghost_and_paused_ticks_hold_it() -> void:
	var pair: Array = _voice()
	var v: StoryVoice = pair[0]
	var stage: CollectCallStage = pair[1]
	assert_not_null(v, "attached")
	v._process(0.0)
	assert_false(v.app.visible, "silent before a whisper")
	stage.events().whispers_spiked.emit()
	stage.tick += 1
	v._process(0.0)
	assert_true(v.app.speaking(), "the whisper is the voice")
	assert_true(v.app.visible, "the apparition shows")
	var end: int = GhostApparition.FADE_IN + GhostApparition.HOLD + GhostApparition.FADE_OUT
	for i: int in end + 5:
		v._process(0.0)  # paused: no sim tick passes
	assert_true(v.app.speaking(), "a paused game holds the voice")
	stage.tick += end + 1
	v._process(0.0)
	assert_false(v.app.speaking(), "the ticks run it out")
