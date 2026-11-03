extends GutTest
## SAV-05: the 256 KB per-slot budget against a real checkpoint body (quest + input tape).

var slots: SaveSlots


func before_each() -> void:
	slots = SaveKit.fresh_slots("budget")


func after_all() -> void:
	SaveKit.wipe(SaveKit.SCRATCH)


## A checkpoint whose tape changes every `every` ticks for `ticks` ticks.
func _checkpoint(ticks: int, every: int) -> Dictionary:
	var c: Checkpoint = Checkpoint.new()
	c.quest = "collect-call"
	c.beat = "b6-hot-walk"
	c.tick = ticks
	c.master_seed = 1234567890123
	c.state_hash = "ab".repeat(32)
	var t: int = 0
	while t < ticks:
		c.input_ticks.append(t)
		c.inputs.append(((t / every) % 2 + 1) * 0x10080 + 0x7F7F)
		t += every
	return c.to_dict()


func test_a_twenty_minute_human_tape_fits_with_room_to_spare() -> void:
	# 72,000 ticks, a change 4 times a second (every 15 ticks): far busier than real hands.
	var r: SaveWorker.Result = SaveKit.save(slots, _checkpoint(72000, 15))
	assert_eq(r.error, OK)
	assert_eq(r.notes.size(), 0, "no budget note")
	var size: int = SaveKit.bytes_of(slots.slot_path(r.slot)).size()
	assert_lt(size, SaveWorker.BUDGET_BYTES / 2, "uses under half the budget (%d bytes)" % size)


func test_a_pathological_tape_is_saved_with_a_budget_note_not_dropped() -> void:
	# A change on every tick for 20 minutes: 72,000 entries, over the budget. Never lose the
	# autosave over it: the write succeeds, the note says why, and the slot still loads.
	var r: SaveWorker.Result = SaveKit.save(slots, _checkpoint(72000, 1))
	assert_eq(r.error, OK)
	assert_eq(r.notes.size(), 1)
	assert_true(r.notes[0].contains("SAV-05"), r.notes[0])
	var out: SaveLoader.Outcome = SaveLoader.load_latest(slots, SaveKit.accept_all)
	assert_eq(out.status, SaveLoader.Status.LOADED)
