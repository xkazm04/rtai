extends GutTest
## n8 vehicles: a stage's cars (the arena's powers pad, quest 1's ghost cars) stand as cards under a
## tilt with card art, a soul-seized one tinted SOUL; `top` draws none (the flat print stays).

var _saved: ViewMode = null
var _cars: Array[VehicleBody] = []


func before_each() -> void:
	_saved = ViewMode._shared
	var seized: VehicleBody = VehicleBody.new(1, VehicleProfile.new(), Vector2(3, -2), Vector2.UP)
	seized.state = VehicleBody.State.HIJACKED
	_cars = [seized, VehicleBody.new(2, VehicleProfile.new(), Vector2(0, 4), Vector2.RIGHT)]


func after_each() -> void:
	ViewMode._shared = _saved


func _list() -> Array[VehicleBody]:
	return _cars


func _stand(view: String) -> VehicleStageCards:
	ViewMode._shared = ViewMode.of(view)
	var host: Node2D = Node2D.new()
	add_child_autofree(host)
	var node: VehicleStageCards = VehicleStageCards.attach(host, _list)
	node._process(0.0)
	return node


func test_top_draws_no_cards_and_keeps_the_flat_print() -> void:
	var node: VehicleStageCards = _stand("top")
	assert_false(node.on())
	assert_eq(node.cards.count(), 0)


func test_a_tilt_stands_every_car_and_tints_the_seized_one() -> void:
	var node: VehicleStageCards = _stand("tilt70")
	assert_true(node.on())
	assert_eq(node.cards.count(), 2)
	var mm: MultiMesh = (node.cards.get_child(0) as MultiMeshInstance2D).multimesh
	assert_eq(mm.visible_instance_count, 2)
	assert_eq(VehicleStageCards.tint_of(VehicleBody.State.HIJACKED), VehicleStageCards.SOUL)
	for st: VehicleBody.State in [VehicleBody.State.INTACT, VehicleBody.State.WRECK]:
		assert_eq(VehicleStageCards.tint_of(st), Color.WHITE)


func test_ensure_stands_the_cards_the_frame_it_attaches_them() -> void:
	ViewMode._shared = ViewMode.of("tilt70")
	var host: Node2D = Node2D.new()
	add_child_autofree(host)
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped())
	var node: VehicleStageCards = VehicleStageCards.ensure(null, host, stage)
	assert_true(VehicleStageCards.standing(node), "no flat car body on the attach frame")
	ViewMode._shared = ViewMode.of("top")
	assert_null(VehicleStageCards.ensure(null, host, stage), "top adds no node")


func test_the_cards_place_in_sim_px_under_an_ink_px_view() -> void:
	var node: VehicleStageCards = _stand("tilt70")
	assert_almost_eq(node.scale.x * SimConst.PX_PER_M, Ink.PX_PER_M, 0.0001)


func _one_south() -> PackedVector2Array:
	return PackedVector2Array([Vector2(0, 5)])  # 1 m south of the car at (0, 4)


func test_on_a_print_a_car_with_a_fighter_in_front_drops_under_the_actors() -> void:
	var was: bool = VehicleStageCards.over
	var node: VehicleStageCards = _stand("tilt70")
	node._view = node.get_parent() as Node2D  # as if hosted on a print's actor layer
	node._banded = true
	node._people = _one_south
	VehicleStageCards.over = false
	node._process(0.0)
	assert_eq(node.cards.count_under(), 0, "over off: no front grid")
	VehicleStageCards.over = true
	node._process(0.0)
	VehicleStageCards.over = was
	assert_eq(node.cards.count(), 2)
	assert_eq(node.cards.count_under(), 1, "only the car at (0, 4)")
	assert_eq(VehicleStageCards.fighters(null).size(), 0)


func test_over_is_on_since_the_seize_cues_draw_over_the_vehicles_band() -> void:
	assert_true(VehicleStageCards.over)


func test_a_wide_fighter_gives_its_edges_to_the_front_grid() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(5)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	arena.rivet.pos = Vector2(1, 1)
	var base: int = VehicleStageCards.fighters(arena).size()
	var boss: Fighter = Fighter.new()
	boss.radius_m = 1.6
	boss.pos = Vector2(10, 0)
	arena.boss = boss
	var pts: PackedVector2Array = VehicleStageCards.fighters(arena)
	assert_eq(pts.size(), base + 3, "the boss's centre and both edges")
	assert_true(pts.has(Vector2(8.4, 0)) and pts.has(Vector2(11.6, 0)))
