extends GutTest
## The owner's note (2026-11-09): "Bodies often lag and move across the screen". The push memory
## fills in a long fight; a body already lying keeps the push it was given when the memory turns
## over, or it re-solves against the bodies that fell after it and jumps.

const PPM: float = 64.0
const FIRST: int = -2000001
const SECOND: int = -2000002
const THIRD: int = -2000003


func before_each() -> void:
	StreetDeadPlan.reset()


func after_each() -> void:
	StreetDeadPlan.reset()


func _lie(actor: int, at: Vector2) -> Vector2:
	assert_gte(StreetDeadPlan.pick(actor, &"", at), 0, "lying")
	return StreetQuestDeadPush.push_of(actor, at, PPM)


func test_a_full_memory_does_not_move_a_body_already_lying() -> void:
	var c: Vector2 = Vector2(400, 300)
	@warning_ignore("return_value_discarded")
	_lie(FIRST, c)
	var b: Vector2 = c + Vector2(0.5 * PPM, 0.0)
	var pushed: Vector2 = _lie(SECOND, b)
	assert_ne(pushed, Vector2.ZERO, "the second body was pushed off the first")
	# a later body lands where a re-solve of the second would have to answer it
	@warning_ignore("return_value_discarded")
	_lie(THIRD, b + pushed + Vector2(0.2 * PPM, 0.0))
	for i: int in StreetDeadPlan.MEMORY - 2:
		@warning_ignore("return_value_discarded")
		StreetQuestDeadPush.push_of(-2100000 - i, Vector2(9000.0, float(i) * 300.0), PPM)
	assert_eq(StreetQuestDeadPush.push_of(SECOND, b, PPM), pushed, "the push survives the turnover")
