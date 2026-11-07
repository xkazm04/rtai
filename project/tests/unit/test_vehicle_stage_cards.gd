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


func test_the_cards_place_in_sim_px_under_an_ink_px_view() -> void:
	var node: VehicleStageCards = _stand("tilt70")
	assert_almost_eq(node.scale.x * SimConst.PX_PER_M, Ink.PX_PER_M, 0.0001)
