extends GutTest

var hints: ProloguePrompts


func before_each() -> void:
	hints = ProloguePrompts.new()
	PlayerActions.shipped(true).install()


func after_each() -> void:
	PlayerActions.shipped().install()


func test_busy_strip_and_gap_drop_offers_until_a_new_threat() -> void:
	hints.offer("strike", 0)
	var strike: String = hints.words(false)
	hints.step(500)
	hints.offer("claw", 500)
	assert_true(hints.active("strike"))
	assert_false(hints.active("claw"))
	assert_ne(strike, "")
	assert_eq(hints.words(false), strike)
	hints.clear(501)
	hints.offer("claw", 530)
	hints.step(531)
	assert_eq(hints.words(false), "")
	assert_eq(hints.history, [{"id": "strike", "tick": 0, "end_tick": 501}])
	hints.offer("claw", 531)
	assert_true(hints.active("claw"))
	assert_false(hints.words(false).contains("·"))


func test_hand_lessons_need_the_previous_card_and_a_real_catch() -> void:
	hints.offer("guard", 0)
	hints.offer("roll", 1, 0)
	assert_true(hints.history.is_empty())
	hints.offer("claw", 2)
	var claw: String = hints.words(true)
	hints.step(121)
	hints.offer("guard", 121)
	assert_eq(hints.words(true), claw)
	hints.step(122)
	assert_eq(hints.words(true), "")
	hints.offer("guard", 151)
	assert_false(hints.active("guard"))
	hints.offer("roll", 152, 0)
	assert_false(hints.active("roll"))
	hints.offer("guard", 152)
	assert_true(hints.active("guard"))
	hints.offer("roll", 153, 0)
	assert_false(hints.active("roll"))
	hints.step(272)
	hints.offer("roll", 302)
	hints.offer("roll", 303, 303)
	assert_false(hints.active("roll"))
	hints.offer("roll", 304, 303)
	assert_true(hints.active("roll"))
	hints.step(424)
	for id: String in ["claw", "guard", "roll"]:
		hints.offer(id, 500, 303)
	assert_eq(hints.words(false), "")
	assert_eq(
		hints.history,
		[
			{"id": "claw", "tick": 2, "end_tick": 122},
			{"id": "guard", "tick": 152, "end_tick": 272},
			{"id": "roll", "tick": 304, "end_tick": 424}
		]
	)


func test_checkpoint_clear_preserves_claw_reading_time_and_seen_lessons() -> void:
	hints.offer("claw", 0)
	hints.clear(10)
	hints.clear(90)
	hints.offer("guard", 91)
	assert_eq(hints.history, [{"id": "claw", "tick": 0, "end_tick": 10}])
	hints.offer("claw", 150)
	hints.offer("guard", 150)
	assert_true(hints.active("guard"))


func test_persistent_cards_and_pistol_handoff_record_actual_end_ticks_once() -> void:
	hints.offer("strike", 0)
	hints.clear(200)
	hints.offer("strike", 201)
	hints.offer("wheel", 202)
	hints.step(400)
	hints.dismiss("strike", 400)
	assert_true(hints.active("wheel"))
	hints.dismiss("wheel", 401)
	hints.offer("fire", 401)
	assert_true(hints.active("fire"))
	hints.step(521)
	hints.offer("wheel", 600)
	hints.offer("fire", 601)
	assert_eq(hints.words(true), "")
	assert_eq(
		hints.history,
		[
			{"id": "strike", "tick": 0, "end_tick": 200},
			{"id": "wheel", "tick": 202, "end_tick": 401},
			{"id": "fire", "tick": 401, "end_tick": 521}
		]
	)
