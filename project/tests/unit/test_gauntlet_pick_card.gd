extends GutTest

const Card = preload("res://dev/gauntlet/gauntlet_pick_card.gd")


func _card(kind: String, ref: StringName) -> Card:
	var card: Card = Card.new()
	card.row = {"id": &"x", "kind": kind, "ref": ref}
	add_child_autofree(card)
	return card


func test_a_mastery_card_has_a_picture_and_the_ring() -> void:
	var card: Card = _card("mastery", &"ohm")
	assert_not_null(card.picture())
	assert_true(card.is_mastery())


func test_a_mastery_card_shows_the_same_figure_as_the_ghost_card() -> void:
	var ghost: Card = _card("ghost", &"ohm")
	var mastery: Card = _card("mastery", &"ohm")
	assert_eq(mastery.picture(), ghost.picture())
	assert_eq(mastery.has_figure(), ghost.has_figure())
	assert_false(ghost.is_mastery())
