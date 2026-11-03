extends GutTest

var _now: int = 1000


func _notice() -> SaveNotice:
	var n: SaveNotice = SaveNotice.new()
	n.now_ms = func() -> int: return _now
	return n


func before_each() -> void:
	_now = 1000


func test_shows_then_expires() -> void:
	var n: SaveNotice = _notice()
	assert_eq(n.text(), "")
	n.show("fell back", 2.0)
	assert_eq(n.text(), "fell back")
	_now += 1900
	assert_eq(n.text(), "fell back")
	_now += 200
	assert_eq(n.text(), "")


func test_empty_line_shows_nothing_and_a_new_line_restarts_the_clock() -> void:
	var n: SaveNotice = _notice()
	n.show("", 5.0)
	assert_eq(n.text(), "")
	n.show("a", 1.0)
	_now += 900
	n.show("b", 1.0)
	_now += 900
	assert_eq(n.text(), "b")


func test_the_default_clock_is_real_time() -> void:
	var n: SaveNotice = SaveNotice.new()
	n.show("now")
	assert_eq(n.text(), "now")
