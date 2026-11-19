extends GutTest
## The ordinary city rig row continues through the instant seat cut when only cosmetics are on.
## Switching the renderer off leaves the sim walk, input and vehicle state bytes alone.

var svc: VehicleService
var car: VehicleBody
var view: VehicleDoorView
var positions: Array[Vector2] = []


class RigSlot:
	extends Node2D

	func rig_for(_actor: int) -> CanvasItem:
		return self


func before_each() -> void:
	svc = VehicleService.new()
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	svc.setup(World.build_context(bus, data, 31))
	svc.world = DoorTestLot.new()
	car = svc.spawn_parked(&"sedan", Vector2.ZERO, Vector2.LEFT)
	var host: Node = autofree(Node.new())
	view = VehicleDoorView.new()
	view.attach(host, svc)
	_pose(0)


func _put(row: int, id: int, kind: BodyPlan.Kind, pos: Vector2, _vel: Vector2) -> void:
	assert_eq(row, 0)
	assert_eq(id, RivetBody.RIVET_ACTOR_ID)
	assert_eq(kind, BodyPlan.Kind.RIVET)
	@warning_ignore("return_value_discarded")
	positions.append(pos)


func _pose(tick: int) -> void:
	positions.clear()
	var before: StreamPeerBuffer = StreamPeerBuffer.new()
	svc.write_state(before)
	view.pose(_put, 0, tick, Transform2D.IDENTITY)
	var after: StreamPeerBuffer = StreamPeerBuffer.new()
	svc.write_state(after)
	assert_eq(before.data_array, after.data_array)


func test_instant_swap_draws_a_walk_fade_and_one_pixel_car_nudge() -> void:
	svc.doors.enabled = false
	var start: Vector2 = svc.world.player_pos()
	assert_eq(svc.try_enter(start), car.id)
	_pose(1)
	assert_eq(positions.size(), 1)
	assert_eq(positions[0], start * SimConst.PX_PER_M)
	_pose(8)
	assert_almost_eq(view.car_position(car).distance_to(car.pos) * SimConst.PX_PER_M, 1.0, 0.001)
	assert_ne(positions[0], start * SimConst.PX_PER_M)
	_pose(13)
	assert_between(view.opacity, 0.01, 0.9)
	_pose(15)
	assert_eq(positions.size(), 0)
	assert_eq(view.car_position(car), car.pos)
	var foot: Vector2 = svc.exit()
	_pose(16)
	assert_eq(view.opacity, 0.0)
	_pose(18)
	assert_between(view.opacity, 0.01, 0.99)
	_pose(25)
	assert_eq(view.opacity, 1.0)
	_pose(26)
	assert_eq(view.drawn_foot, foot)
	assert_eq(positions.size(), 0)


func test_timed_sim_walk_can_run_with_the_view_switched_off() -> void:
	svc.doors.enabled = true
	svc.doors.view = false
	assert_eq(svc.try_enter(svc.world.player_pos()), car.id)
	for i: int in svc.doors.enter_ticks:
		svc.step(i, TickInput.new())
		_pose(i + 1)
		assert_eq(positions.size(), 0)
		assert_eq(view.opacity, 1.0)
		assert_eq(view.car_position(car), car.pos)
	assert_eq(svc.driving, car)


func test_rivet_goes_under_the_card_then_recovers_his_original_depth() -> void:
	var rig: Node2D = autofree(Node2D.new())
	view._rig_for = func(_actor: int) -> CanvasItem: return rig
	svc.doors.enabled = false
	assert_eq(svc.try_enter(svc.world.player_pos()), car.id)
	_pose(1)
	view.tint()
	assert_true(rig.z_as_relative)
	_pose(13)
	view.tint()
	assert_false(rig.z_as_relative, "inside the car, every rig part is below its card")
	_pose(15)
	view.tint()
	assert_true(rig.z_as_relative)
	assert_eq(rig.modulate.a, 1.0)
	@warning_ignore("return_value_discarded")
	svc.exit()
	_pose(16)
	view.tint()
	assert_false(rig.z_as_relative)
	_pose(21)
	view.tint()
	assert_true(rig.z_as_relative, "the emerging foot has cleared the door")


func test_city_foot_pass_replaces_the_standing_row_only_during_the_walk() -> void:
	var canvas: CanvasLayer = add_child_autofree(CanvasLayer.new())
	var slot: RigSlot = RigSlot.new()
	view.attach(slot, svc)
	canvas.add_child(slot)
	assert_true(VehicleDoorView.on_foot(slot.rig_for, _put, 0, 0, true))
	assert_true(positions.is_empty())
	svc.doors.enabled = false
	assert_eq(svc.try_enter(svc.world.player_pos()), car.id)
	assert_false(VehicleDoorView.on_foot(slot.rig_for, _put, 0, 1, true))
	assert_eq(positions.size(), 1)
	assert_true(view.walking())
	assert_false(VehicleDoorView.on_foot(slot.rig_for, _put, 0, 1 + svc.doors.enter_ticks, false))
	assert_false(view.walking())


func test_detaching_an_old_view_leaves_the_new_canvas_owner_attached() -> void:
	var canvas: CanvasLayer = add_child_autofree(CanvasLayer.new())
	var first: Node = Node.new()
	view.attach(first, svc)
	canvas.add_child(first)
	var replacement: VehicleDoorView = VehicleDoorView.new()
	var second: Node = Node.new()
	replacement.attach(second, svc)
	canvas.add_child(second)
	view.detach()
	var owner_view: VehicleDoorView = canvas.get_meta(VehicleDoorView.META, null)
	assert_same(owner_view, replacement)
	replacement.detach()
	assert_false(canvas.has_meta(VehicleDoorView.META))
