extends GutTest

const ART: String = "res://features/city/art/view/<art>/prop_payphone.png"


func _cards() -> PropCards:
	var names: Array[String] = ["road", "payphone", "barricade"]
	var props: Dictionary = {
		"payphone": {"art": ART, "cell_w_m": 1.2},
		"barricade": {"art": ART, "cell_w_m": 2.0, "turn": 1},
	}
	return PropCards.make(props, names, "p70", {"p70": "p55"})


func test_only_named_props_stand() -> void:
	var cards: PropCards = _cards()
	assert_eq(cards.size(), 2)
	assert_false(cards.has(0), "a texture not in the table stays flat")
	assert_true(cards.has(1))


func test_facing_from_the_turn() -> void:
	var cards: PropCards = _cards()
	assert_eq(cards.facing(1, 0.0), Vector2i(0, 0), "front toward the camera")
	assert_eq(cards.facing(1, PI * 0.25), Vector2i(1, 0), "three-quarter, as drawn")
	assert_eq(cards.facing(1, -PI * 0.25), Vector2i(1, 1), "three-quarter, mirrored")
	assert_eq(cards.facing(1, PI * 0.5), Vector2i(2, 0), "side")
	assert_eq(cards.facing(1, PI), Vector2i(4, 0), "back, never mirrored")
	assert_eq(cards.facing(2, 0.0), Vector2i(2, 0), "a row's turn adds a quarter")


func test_cards_move_to_the_roofs_band() -> void:
	var bands: PackedByteArray = _cards().bands(PackedByteArray([0, 3, 3]))
	assert_eq(bands, PackedByteArray([0, 4, 4]))


func test_missing_art_falls_back_to_the_named_key() -> void:
	var tex: Texture2D = PropCards.art_texture(ART, "p99", {"p99": "p55"})
	assert_not_null(tex, "p99 has no strip: the p55 one draws")


func test_named_is_null_under_the_flat_view() -> void:
	if ViewMode.shared().is_flat():
		assert_null(PropCards.named(), "top keeps every drawer's own props")
	else:
		assert_not_null(PropCards.named())


func test_draw_named_skips_an_unknown_prop() -> void:
	var ci: Node2D = autofree(Node2D.new())
	assert_false(_cards().draw_named(ci, "lamp_post", Vector2.ZERO, 48.0))
	assert_true(_cards().draw_named(ci, "payphone", Vector2.ZERO, 48.0))


func test_a_lamp_stands_on_its_post_base_with_the_arm_turned() -> void:
	var names: Array[String] = ["lamp_post"]
	var row: Dictionary = {
		"art": ART, "cell_w_m": 1.0, "foot_m": [-1.0, 0.0], "mirror": true, "turn": 3
	}
	var cards: PropCards = PropCards.make({"lamp_post": row}, names, "p70", {"p70": "p55"})
	var px: float = SimConst.PX_PER_M
	var foot: Vector2 = cards.foot_at(0, PI * 0.5, Vector2(100, 100), Vector2.ZERO)
	assert_almost_eq(foot, Vector2(100, 100 - px), Vector2(0.01, 0.01), "arm south: post north")
	assert_eq(cards.foot_at(0, 0.0, Vector2.ZERO, Vector2(0, 50)), Vector2(-px, 0), "not the edge")
	assert_eq(cards.facing(0, PI * 0.5), Vector2i(0, 0), "arm south: toward the camera")
	assert_eq(cards.facing(0, 0.0), Vector2i(2, 0), "arm east: the side view as drawn (right)")
	assert_eq(cards.facing(0, PI), Vector2i(2, 1), "arm west: mirrored")
	assert_eq(cards.facing(0, -PI * 0.5), Vector2i(4, 0), "arm north: the back")


func test_arena_cover_kinds_draw_as_the_street_cards() -> void:
	var names: Array[String] = ["crate_stack"]
	var row: Dictionary = {"art": ART, "cell_w_m": 3.2}
	var cards: PropCards = PropCards.make({"crate_stack": row}, names, "p70", {"p70": "p55"})
	var ci: Node2D = autofree(Node2D.new())
	assert_true(
		cards.draw_on(ci, "cover_low", Rect2(0, 0, 96, 32)), "a crate row is the crate card"
	)
	assert_false(cards.draw_on(ci, "wall_high", Rect2(0, 0, 96, 32)), "walls stay architecture")
	assert_false(cards.draw_on(ci, "cover_high", Rect2(0, 0, 64, 64)), "no dumpster row here")
	assert_eq(PropCards.ARENA_KIND["cover_low"], "crate_stack")
	assert_eq(PropCards.ARENA_KIND["cone"], "traffic_cone")


func test_quest_stage_props_stand_by_their_own_names() -> void:
	var ci: Node2D = autofree(Node2D.new())
	var cards: PropCards = _cards()
	assert_true(cards.draw_on(ci, "payphone", Rect2(0, 0, 62, 24)), "quest 1's payphone stands")
	assert_false(cards.draw_on(ci, "cash_taped", Rect2(0, 0, 64, 40)), "the cash stays flat")
	assert_eq(PropCards.ARENA_KIND["dumpster"], "dumpster", "the hide spot is the dumpster card")


func test_stand_rect_is_the_card_over_the_south_edge() -> void:
	var saved: ViewMode = ViewMode._shared
	var r: Rect2 = Rect2(0, 0, 144, 48)
	ViewMode._shared = ViewMode.of("top")
	assert_false(PropCards.stand_rect("cover_low", r).has_area(), "top: the box's own area")
	ViewMode._shared = ViewMode.of("tilt70")
	var got: Rect2 = PropCards.stand_rect("cover_low", r)
	var wall: Rect2 = PropCards.stand_rect("wall_high", r)
	ViewMode._shared = saved
	assert_eq(got.end.y, r.end.y, "the card stands on the footprint's south edge")
	assert_eq(got.size.x, 144.0, "as wide as the long side")
	assert_lt(got.position.y, r.position.y - 48.0, "the crate card rises well over its box")
	assert_false(wall.has_area(), "walls keep their box")


func test_item_print_draws_the_world_printed_twin() -> void:
	var names: Array[String] = ["crate_stack"]
	var crate: String = "res://features/city/art/view/<art>/prop_crate_stack"
	var props: Dictionary = {
		"crate_stack": {"art": crate + ".png", "cell_w_m": 3.2, "print_art": crate + "_print.png"}
	}
	var cards: PropCards = PropCards.make(props, names, "p70", {"p70": "p55"})
	assert_not_null(cards._print[0], "the twin loads by the same art key")
	var floor_ci: Node2D = autofree(Node2D.new())
	var actor_ci: Node2D = autofree(Node2D.new())
	var item_print: ShaderMaterial = ShaderMaterial.new()
	item_print.shader = load(PrintStage.ITEM_SHADER)
	actor_ci.material = item_print
	assert_false(PropCards.item_printed(floor_ci), "the floor goes through the world print")
	assert_true(PropCards.item_printed(actor_ci), "PropOcclusion's redraw: the item print")
	item_print.shader = null
	assert_false(PropCards.item_printed(actor_ci), "--look=off: the raw art everywhere")
	assert_true(cards.draw_on(actor_ci, "cover_low", Rect2(0, 0, 144, 48)))
	assert_false(cards._use_print, "the twin is only for that one draw")
