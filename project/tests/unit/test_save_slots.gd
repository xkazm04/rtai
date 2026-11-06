extends GutTest
## The two rotating slots and the loader's cold paths (SAV-03, SAV-04, SAV-09).

var slots: SaveSlots


func before_each() -> void:
	slots = SaveKit.fresh_slots("slots")


func after_all() -> void:
	SaveKit.wipe(SaveKit.scratch())


func _body(n: int) -> Dictionary:
	return {"n": n, "quest": "collect-call"}


func _load() -> SaveLoader.Outcome:
	return SaveLoader.load_latest(slots, SaveKit.accept_all)


func _two_saves() -> void:
	assert_eq(SaveKit.save(slots, _body(1)).error, OK)
	assert_eq(SaveKit.save(slots, _body(2)).error, OK)


func test_saves_alternate_and_the_newer_slot_is_never_touched_by_a_write() -> void:
	assert_eq(SaveKit.save(slots, _body(1)).slot, 0)
	assert_eq(SaveKit.save(slots, _body(2)).slot, 1)
	var newer: PackedByteArray = SaveKit.bytes_of(slots.slot_path(1))
	assert_eq(SaveKit.save(slots, _body(3)).slot, 0, "the older slot is overwritten")
	assert_eq(SaveKit.bytes_of(slots.slot_path(1)), newer, "the newer slot is byte-identical")
	assert_eq(SaveKit.n_of(_load().body), 3)


func test_sequence_numbers_climb_by_one() -> void:
	_two_saves()
	assert_eq(slots.read(0).seq(), 1)
	assert_eq(slots.read(1).seq(), 2)
	assert_eq(SaveKit.save(slots, _body(3)).seq, 3)


func test_truncated_newer_slot_falls_back_and_is_quarantined() -> void:
	_two_saves()
	SaveKit.truncate(slots.slot_path(1), 60)
	var out: SaveLoader.Outcome = _load()
	assert_eq(out.status, SaveLoader.Status.LOADED)
	assert_eq(SaveKit.n_of(out.body), 1, "the older slot")
	assert_true(FileAccess.file_exists(slots.slot_path(1) + ".corrupt"))
	assert_false(FileAccess.file_exists(slots.slot_path(1)))
	assert_ne(out.notice, "", "the player is told")


func test_flipped_byte_falls_back() -> void:
	_two_saves()
	SaveKit.flip(slots.slot_path(1), 50)
	assert_eq(SaveKit.n_of(_load().body), 1)
	assert_true(FileAccess.file_exists(slots.slot_path(1) + ".corrupt"))


func test_zero_length_slot_falls_back() -> void:
	_two_saves()
	SaveKit.put(slots.slot_path(1), PackedByteArray())
	assert_eq(SaveKit.n_of(_load().body), 1)


func test_missing_slot_is_not_an_error() -> void:
	assert_eq(SaveKit.save(slots, _body(1)).error, OK)
	var out: SaveLoader.Outcome = _load()
	assert_eq(out.status, SaveLoader.Status.LOADED)
	assert_eq(out.notice, "", "one slot is normal after the first autosave")
	var empty: SaveSlots = SaveKit.fresh_slots("empty")
	assert_eq(SaveLoader.load_latest(empty, SaveKit.accept_all).status, SaveLoader.Status.FRESH)


func test_newer_version_is_refused_untouched_and_never_overwritten() -> void:
	_two_saves()
	var future: Dictionary = {"save_version": 99, "seq": 9, "point": "x", "body": {"n": 9}}
	SaveKit.put(slots.slot_path(1), GtsvContainer.encode(future))
	var kept: PackedByteArray = SaveKit.bytes_of(slots.slot_path(1))
	assert_eq(SaveKit.n_of(_load().body), 1, "loads the older slot the reader understands")
	assert_eq(SaveKit.bytes_of(slots.slot_path(1)), kept, "not renamed, not quarantined")
	assert_false(FileAccess.file_exists(slots.slot_path(1) + ".corrupt"))
	for i: int in 4:
		assert_eq(SaveKit.save(slots, _body(10 + i)).slot, 0, "writes only ever use the other slot")
	assert_eq(SaveKit.bytes_of(slots.slot_path(1)), kept, "still byte-identical")


func test_both_slots_newer_refuses_to_write() -> void:
	var future: Dictionary = {"save_version": 99, "seq": 9, "point": "x", "body": {}}
	for i: int in 2:
		SaveKit.put(slots.slot_path(i), GtsvContainer.encode(future))
	assert_eq(SaveKit.save(slots, _body(1)).error, ERR_UNAUTHORIZED)
	assert_eq(_load().status, SaveLoader.Status.FRESH)
	assert_eq(SaveKit.census(slots.root).size(), 2, "nothing was created or renamed")


func test_leftover_tmp_from_a_crash_is_ignored_then_removed() -> void:
	_two_saves()
	SaveKit.put(SlotFile.tmp_path(slots.slot_path(0)), "GTSVhalf a wri".to_utf8_buffer())
	var out: SaveLoader.Outcome = _load()
	assert_eq(SaveKit.n_of(out.body), 2, "a tmp never counts as a save")
	assert_false(FileAccess.file_exists(SlotFile.tmp_path(slots.slot_path(0))))
	SaveKit.put(SlotFile.tmp_path(slots.slot_path(0)), "junk".to_utf8_buffer())
	assert_eq(SaveKit.save(slots, _body(3)).error, OK, "the next write replaces the stale tmp")
	assert_eq(SaveKit.n_of(_load().body), 3)


func test_unwritable_profile_reports_and_does_not_throw() -> void:
	var blocker: String = SaveKit.scratch().path_join("blocker")
	SaveKit.put(blocker, "a file where the profile dir should be".to_utf8_buffer())
	var bad: SaveSlots = SaveSlots.new(blocker)
	var r: SaveWorker.Result = SaveKit.save(bad, _body(1))
	assert_engine_error_count(1, "the engine logs the mkdir it could not do")
	assert_ne(r.error, OK, "the write fails")
	assert_false(r.notes.is_empty())
	assert_eq(SaveLoader.load_latest(bad, SaveKit.accept_all).status, SaveLoader.Status.FRESH)
	assert_eq(SaveKit.save(slots, _body(1)).error, OK, "a good profile still saves")


func test_both_slots_corrupt_starts_fresh_and_keeps_the_evidence() -> void:
	_two_saves()
	SaveKit.truncate(slots.slot_path(0), 40)
	SaveKit.flip(slots.slot_path(1), 60)
	var out: SaveLoader.Outcome = _load()
	assert_eq(out.status, SaveLoader.Status.FRESH)
	assert_eq(out.notice_key, &"SAVE__NOTICE_NONE_READABLE")
	assert_true(FileAccess.file_exists(slots.slot_path(0) + ".corrupt"))
	assert_true(FileAccess.file_exists(slots.slot_path(1) + ".corrupt"))
	assert_eq(SaveKit.save(slots, _body(5)).error, OK, "the game can save again afterwards")
	assert_eq(SaveKit.n_of(_load().body), 5)


func test_a_failed_replay_check_quarantines_that_slot_and_falls_back() -> void:
	_two_saves()
	var accept: Callable = func(b: Dictionary) -> Variant:
		return null if SaveKit.n_of(b) == 2 else b
	var out: SaveLoader.Outcome = SaveLoader.load_latest(slots, accept)
	assert_eq(SaveKit.n_of(out.body), 1)
	assert_true(FileAccess.file_exists(slots.slot_path(1) + ".corrupt"))


func test_only_the_latest_quarantined_file_is_kept_per_slot() -> void:
	for round: int in 3:
		_two_saves()
		SaveKit.flip(slots.slot_path(1), 50)
		@warning_ignore("return_value_discarded")
		_load()
	var corrupt: int = 0
	for f: String in SaveKit.census(slots.root):
		corrupt += int(f.ends_with(".corrupt"))
	assert_eq(corrupt, 1)


func test_a_tmp_that_fails_verification_leaves_the_slot_alone() -> void:
	_two_saves()
	var before: PackedByteArray = SaveKit.bytes_of(slots.slot_path(0))
	SlotFile.after_tmp = func(tmp: String) -> void: SaveKit.flip(tmp, 40)
	var r: SaveWorker.Result = SaveKit.save(slots, _body(3))
	SlotFile.after_tmp = Callable()
	assert_eq(r.error, ERR_FILE_CORRUPT)
	assert_eq(SaveKit.bytes_of(slots.slot_path(0)), before, "the target is exactly as it was")
	assert_false(FileAccess.file_exists(SlotFile.tmp_path(slots.slot_path(0))), "tmp removed")
	assert_eq(SaveKit.n_of(_load().body), 2)


func test_requests_during_a_write_coalesce_into_one_pending() -> void:
	var worker: SaveWorker = SaveWorker.new(slots)
	for n: int in 6:
		worker.submit({"point": "p%d" % n, "body": _body(n), "meta": {}})
	worker.flush()
	assert_lte(worker.completed, 2, "the first in flight plus at most one pending")
	assert_eq(SaveKit.n_of(_load().body), 5, "the last request wins")


func test_a_thousand_alternating_autosaves_leave_exactly_two_slot_files() -> void:
	var worker: SaveWorker = SaveWorker.new(slots)
	for n: int in 1000:
		var r: SaveWorker.Result = worker.write_now(
			{"point": "p", "body": _body(n), "meta": {"quest": "q"}}
		)
		assert_eq(r.error, OK)
	var files: Array[String] = SaveKit.census(slots.root)
	assert_eq(files, ["auto_a/state.sav", "auto_b/state.sav", "meta.json"] as Array[String])
	var out: SaveLoader.Outcome = _load()
	assert_eq(SaveKit.n_of(out.body), 999)
	assert_eq(out.seq, 1000)
