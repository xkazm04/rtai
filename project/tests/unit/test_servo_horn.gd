extends GutTest
## ServoHorn: rush hour (phase index 1) blows the depot horn once; other phases do not.


func test_the_horn_blows_at_rush_hour_only() -> void:
	var spec: BossSpec = BossSpec.shipped(&"servo")
	var f: BossFight = BossFight.new(spec, RngRegistry.new(3).stream(spec.rng), Vector2.ZERO)
	f.start()
	var host: Node = Node.new()
	add_child_autofree(host)
	var h: ServoHorn = ServoHorn.attach(host, f)
	f.phase_changed.emit(2, &"overtime")
	assert_eq(h.blown(), 0, "overtime blows no horn")
	f.phase_changed.emit(1, &"rush_hour")
	assert_eq(h.blown(), 1, "rush hour blows the horn")
	assert_not_null(h.service.tables.cue(&"servo_horn"), "the cue is in audio_cues.json")
