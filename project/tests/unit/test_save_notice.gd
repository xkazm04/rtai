extends GutTest


func test_shows_then_expires() -> void:
	var n: SaveNotice = SaveNotice.new()
	assert_eq(n.text(), "")
	n.show("fell back", 2.0)
	assert_eq(n.text(), "fell back")
	n.tick(1.5)
	assert_eq(n.text(), "fell back")
	n.tick(0.6)
	assert_eq(n.text(), "")


func test_empty_line_shows_nothing_and_a_new_line_restarts_the_clock() -> void:
	var n: SaveNotice = SaveNotice.new()
	n.show("", 5.0)
	assert_eq(n.text(), "")
	n.show("a", 1.0)
	n.tick(0.9)
	n.show("b", 1.0)
	n.tick(0.9)
	assert_eq(n.text(), "b")


func test_tick_on_an_idle_notice_is_harmless() -> void:
	var n: SaveNotice = SaveNotice.new()
	n.tick(10.0)
	assert_eq(n.text(), "")
