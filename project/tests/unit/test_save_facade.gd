extends GutTest
## The Save autoload as the game uses it: autosave, flush, Continue, load, notice, meta.

const ROOT: String = "user://test_save/facade"


func before_each() -> void:
	SaveKit.wipe(ROOT)
	Save.use_root(ROOT)


func after_all() -> void:
	Save.use_root(Save.DEFAULT_ROOT)
	SaveKit.wipe(SaveKit.SCRATCH)


func _body(n: int) -> Dictionary:
	return {"n": n}


func test_no_continue_before_the_first_autosave() -> void:
	assert_false(Save.has_continue())
	assert_eq(Save.load_latest(SaveKit.accept_all).status, SaveLoader.Status.FRESH)
	assert_eq(Save.take_notice(), "", "a first run is not an error")


func test_autosave_flush_continue_and_load() -> void:
	Save.autosave("as-b2", _body(1), {"quest": "collect-call", "beat": "b2", "playtime_s": 12})
	Save.flush()
	assert_true(Save.has_continue())
	var out: SaveLoader.Outcome = Save.load_latest(SaveKit.accept_all)
	assert_eq(out.point, "as-b2")
	assert_eq(SaveKit.n_of(out.body), 1)
	assert_eq(Save.active_slot(), out.slot)
	var meta: Dictionary = Save.read_meta()
	assert_eq(str(meta.get("quest")), "collect-call")
	assert_eq(str(meta.get("beat")), "b2")
	assert_eq(GtsvContainer.as_int(meta.get("playtime_s")), 12)


func test_fallback_raises_a_notice_once() -> void:
	Save.autosave("p1", _body(1))
	Save.flush()
	Save.autosave("p2", _body(2))
	Save.flush()
	var newest: int = Save.slots().read(0).seq() <= Save.slots().read(1).seq()
	SaveKit.truncate(Save.slots().slot_path(1 if newest else 0), 50)
	watch_signals(Save)
	var out: SaveLoader.Outcome = Save.load_latest(SaveKit.accept_all)
	assert_eq(SaveKit.n_of(out.body), 1)
	assert_signal_emitted(Save, "notice")
	assert_ne(Save.take_notice(), "")
	assert_eq(Save.take_notice(), "", "taken once")


func test_a_burst_of_autosaves_never_exceeds_two_slot_files() -> void:
	for n: int in 50:
		Save.autosave("p", _body(n))
	Save.flush()
	assert_eq(
		SaveKit.census(ROOT), ["auto_a/state.sav", "auto_b/state.sav", "meta.json"] as Array[String]
	)
	assert_eq(SaveKit.n_of(Save.load_latest(SaveKit.accept_all).body), 49, "the last one won")


func test_a_damaged_meta_json_never_blocks_a_load() -> void:
	Save.autosave("p", _body(7), {"quest": "q"})
	Save.flush()
	SaveKit.put(Save.slots().meta_path(), "{not json".to_utf8_buffer())
	SaveKit.put(SlotFile.tmp_path(Save.slots().meta_path()), "half".to_utf8_buffer())
	assert_eq(Save.read_meta(), {}, "unreadable meta is just absent")
	var out: SaveLoader.Outcome = Save.load_latest(SaveKit.accept_all)
	assert_eq(SaveKit.n_of(out.body), 7)
	assert_false(FileAccess.file_exists(SlotFile.tmp_path(Save.slots().meta_path())))
	Save.autosave("p", _body(8), {"quest": "q"})
	Save.flush()
	assert_eq(str(Save.read_meta().get("quest")), "q", "the next autosave rewrites it")
