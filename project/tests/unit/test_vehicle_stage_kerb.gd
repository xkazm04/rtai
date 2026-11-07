extends GutTest
## n8 vehicles: with no VehicleView (quest 1, the arena's city block) the stage view claims the
## kerb-car registry before the street is drawn, and its stage cards stand the kerb cars near the
## screen; `top`, a VehicleView holding the registry, or `kerb` off leave them flat props.

var _saved: ViewMode = null
var _live: bool = false
var _kerb: bool = true


func before_each() -> void:
	_saved = ViewMode._shared
	_live = VehicleParked.live
	_kerb = VehicleStageCards.kerb
	VehicleParked.live = false
	VehicleParked.clear()


func after_each() -> void:
	VehicleStageCards.release()
	ViewMode._shared = _saved
	VehicleParked.live = _live
	VehicleStageCards.kerb = _kerb
	VehicleParked.clear()


func _none() -> Array[VehicleBody]:
	return []


func _stand() -> VehicleStageCards:
	var host: Node2D = Node2D.new()
	add_child_autofree(host)
	return VehicleStageCards.attach(host, _none)


## One kerb sedan (city texture 44) parked at the middle of what `node`'s cards see.
func _park_on_screen(node: VehicleStageCards) -> void:
	var at: Vector2 = VehicleCull.screen_m(node.cards, 0.0).get_center()
	VehicleParked.park(Vector2i.ZERO, PackedVector4Array([Vector4(at.x, at.y, 0.0, 44.0)]))


func test_top_claims_nothing() -> void:
	ViewMode._shared = ViewMode.of("top")
	VehicleStageCards.claim()
	assert_false(VehicleParked.live, "top: no card atlas, the kerb cars stay flat")


func test_a_claimed_stage_stands_the_kerb_cars_on_screen() -> void:
	ViewMode._shared = ViewMode.of("tilt70")
	VehicleStageCards.claim()
	assert_true(VehicleParked.live, "claimed: ChunkLift hands the kerb cars over")
	var node: VehicleStageCards = _stand()
	assert_true(node.parked())
	_park_on_screen(node)
	node._process(0.0)
	assert_eq(node.cards.count(), 1, "the kerb sedan stands as a card")
	VehicleStageCards.release()
	assert_false(VehicleParked.live, "released: the kerb cars flat again")


func test_a_view_holding_the_registry_keeps_it() -> void:
	ViewMode._shared = ViewMode.of("tilt70")
	VehicleParked.live = true  # a VehicleView draws them (the city drive)
	VehicleStageCards.claim()
	var node: VehicleStageCards = _stand()
	assert_false(node.parked(), "no second drawer")
	_park_on_screen(node)
	node._process(0.0)
	assert_eq(node.cards.count(), 0)
	VehicleStageCards.release()
	assert_true(VehicleParked.live, "a release never drops the VehicleView's hold")


func test_kerb_off_claims_nothing() -> void:
	ViewMode._shared = ViewMode.of("tilt70")
	VehicleStageCards.kerb = false
	VehicleStageCards.claim()
	assert_false(VehicleParked.live)
