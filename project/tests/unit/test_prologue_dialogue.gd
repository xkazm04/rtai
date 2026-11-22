extends GutTest


func test_natural_timing_and_skip_follow_spoken_rows_in_table_order() -> void:
	var rows: Array = DataTable.open(PrologueLines.TABLE, PrologueLines.SCHEMA).raw["rows"]
	var feed: PrologueLines = PrologueLines.new()
	var tick: int = 0
	assert_true(feed.begin(1, tick))
	for row: Dictionary in rows:
		if row["beat"] != 1 or row["k"] != "line":
			continue
		assert_eq(feed.current, str(row["id"]))
		var drafted: bool = feed.events.back()["draft"]
		var expected: bool = row.get("draft", false)
		var start: int = feed.events.back()["tick"]
		assert_eq(drafted, expected)
		assert_eq(start, tick)
		var line: QuestLine = QuestLine.new()
		line.text = row["t"]
		tick += line.duration_ticks(QuestRules.shipped())
		feed.advance(tick - 1, false)
		assert_eq(feed.current, str(row["id"]))
		feed.advance(tick, false)
	assert_eq(feed.current, "")
	assert_eq(feed.shown.size(), 12)
	assert_true(feed.begin(1, tick))
	feed.advance(tick + 1, true)
	assert_eq(feed.current, "draft_mulroney_radio")
	var skipped: bool = feed.events[-2]["skipped"]
	assert_true(skipped)


func test_interrupted_lines_record_what_was_seen_and_what_was_missed() -> void:
	var feed: PrologueLines = PrologueLines.new()
	assert_true(feed.begin(1, 0))
	feed.interrupt(17)
	assert_eq(feed.events.size(), 12)
	assert_eq(feed.shown.size(), 1)
	var start: int = feed.events[0]["tick"]
	var cut: int = feed.events[0]["skip_tick"]
	assert_eq(start, 0)
	assert_eq(cut, 17)
	for i: int in feed.events.size():
		var skipped: bool = feed.events[i]["skipped"]
		var shown: bool = feed.events[i]["shown"]
		assert_true(skipped)
		assert_eq(shown, i == 0)
	assert_eq(feed.subtitle.words, "")
