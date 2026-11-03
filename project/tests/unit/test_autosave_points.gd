extends GutTest
## The quest package's autosavePoints: reader, validation against beats[], edge firing.


func _quest(points: Variant) -> Dictionary:
	return {"beats": [{"id": "b1"}, {"id": "b2"}, {"id": "b3"}], "autosavePoints": points}


func _pt(id: String, beat: String, at: String = "start") -> Dictionary:
	return {"id": id, "beat": beat, "at": at, "why": "saves the walk"}


func test_quest_1_declares_its_five_points_at_beat_starts() -> void:
	var r: AutosavePoints.Result = AutosavePoints.load_file("collect-call")
	assert_true(r.ok(), str(r.errors))
	var ids: Array[String] = []
	for p: AutosavePoints.Point in r.points:
		ids.append(p.id)
		assert_eq(p.at, "start")
		assert_ne(p.why, "")
	var want: Array[String] = [
		"as-b2-payphone", "as-b3-toner-room", "as-b4-dock", "as-b5-quartermaster", "as-b6-hot-walk"
	]
	assert_eq(ids, want)


func test_no_field_is_fine() -> void:
	var r: AutosavePoints.Result = AutosavePoints.read({"beats": [{"id": "b1"}]})
	assert_true(r.ok())
	assert_eq(r.points.size(), 0)


func test_unknown_beat_is_an_error_naming_the_point() -> void:
	var r: AutosavePoints.Result = AutosavePoints.read(_quest([_pt("as-ghost", "b9")]))
	assert_false(r.ok())
	assert_true(r.errors[0].contains("as-ghost") and r.errors[0].contains("b9"), r.errors[0])
	assert_eq(r.points.size(), 0, "a bad point is never kept")


func test_other_mistakes_name_the_point_too() -> void:
	var dup: AutosavePoints.Result = AutosavePoints.read(_quest([_pt("a", "b1"), _pt("a", "b2")]))
	assert_true(dup.errors[0].contains("duplicate"))
	var at: AutosavePoints.Result = AutosavePoints.read(_quest([_pt("a", "b1", "middle")]))
	assert_true(at.errors[0].contains("'a'") and at.errors[0].contains("middle"))
	var no_why: Dictionary = {"id": "w", "beat": "b1", "at": "end"}
	assert_true(AutosavePoints.read(_quest([no_why])).errors[0].contains("why"))
	assert_false(AutosavePoints.read(_quest("nope")).ok())
	assert_false(AutosavePoints.read(_quest([7])).ok())


func test_a_missing_package_is_an_error() -> void:
	assert_false(AutosavePoints.load_file("no-such-quest").ok())


func _edges(points: Array) -> AutosaveEdges:
	var beats: Array[String] = ["b1", "b2", "b3"]
	return AutosaveEdges.new(AutosavePoints.read(_quest(points)), beats)


func test_each_point_fires_once_at_its_edge() -> void:
	var e: AutosaveEdges = _edges([_pt("s2", "b2"), _pt("e1", "b1", "end"), _pt("s3", "b3")])
	assert_eq(e.poll(0, false), [] as Array[String], "arming: the opening beat is not an edge")
	assert_eq(e.poll(0, false), [] as Array[String])
	assert_eq(e.poll(1, false), ["e1", "s2"] as Array[String], "end of b1, start of b2")
	assert_eq(e.poll(1, false), [] as Array[String], "not twice")
	assert_eq(e.poll(2, false), ["s3"] as Array[String])


func test_the_quest_end_always_autosaves_declared_or_not() -> void:
	var e: AutosaveEdges = _edges([])
	@warning_ignore("return_value_discarded")
	e.poll(0, false)
	@warning_ignore("return_value_discarded")
	e.poll(2, false)
	assert_eq(e.poll(2, true), ["quest-end"] as Array[String])
	assert_eq(e.poll(2, true), [] as Array[String], "once")


func test_autosaver_sends_a_snapshot_per_fired_point() -> void:
	var sent: Array[String] = []
	var snap: Callable = func(p: String) -> Dictionary: return {"body": {"p": p}, "meta": {}}
	var sink: Callable = func(p: String, body: Dictionary, _m: Dictionary) -> void:
		sent.append("%s:%s" % [p, body.get("p")])
	var beats: Array[String] = ["b1", "b2", "b3"]
	var q: QuestAutosaver = QuestAutosaver.new(
		AutosavePoints.read(_quest([_pt("s2", "b2")])), beats, snap, sink
	)
	q.poll(0, false)
	q.poll(1, false)
	q.poll(2, true)
	assert_eq(sent, ["s2:s2", "quest-end:quest-end"] as Array[String])
