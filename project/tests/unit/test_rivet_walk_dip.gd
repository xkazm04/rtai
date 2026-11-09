extends GutTest
## n10 rivet: a reversal's speed dip keeps the walk grid (RivetWalk.moving).


func test_a_reversal_keeps_the_walk_grid_through_its_speed_dip() -> void:
	# n10: reversing carries his speed through zero for one tick, and that tick drew the standing
	# (or reload) cell in the middle of the walk (trans tour: pistol t408, gatling reload t734)
	var rig: CutRig = add_child_autofree(CutRig.new())
	var want: String = RivetStrips.DIR + "p70/" + RivetWalk.ARMED + "pistol.png"
	rig.speed_now = RivetFrames.MOVING + 10.0
	assert_eq(RivetWalk.path_of(rig, "p70", &"pistol"), want, "walking")
	rig.t_alive += SimClock.TICK_DT
	rig.speed_now = 1.0
	assert_eq(RivetWalk.path_of(rig, "p70", &"pistol"), want, "the dip's own tick stays walking")
	rig.t_alive += SimClock.TICK_DT
	rig.speed_now = RivetFrames.MOVING + 10.0
	assert_eq(RivetWalk.path_of(rig, "p70", &"pistol"), want, "and out the other side")
	rig.speed_now = 0.0
	rig.t_alive += SimClock.TICK_DT * (RivetWalk.DIP_TICKS + 1)
	assert_eq(RivetWalk.path_of(rig, "p70", &"pistol"), "", "a real stop stands")


func test_a_rig_back_from_the_pool_does_not_inherit_the_dip() -> void:
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.speed_now = RivetFrames.MOVING + 10.0
	rig.t_alive = 100.0
	assert_true(RivetWalk.moving(rig), "walking")
	rig.t_alive = 0.0  # CutRig.reset: t_alive restarts while the meta survives
	rig.speed_now = 0.0
	assert_false(RivetWalk.moving(rig), "a later time than now is no recent walk")


func test_the_unaimed_rest_cell_waits_out_the_dip() -> void:
	# the second reader of the gate: gun out but not aiming, the dip's tick drew the REST cell
	var rig: CutRig = add_child_autofree(CutRig.new())
	var head: Node2D = Node2D.new()
	rig.add_child(head)
	rig.head = head
	rig.head.rotation = PI * 0.25  # octant 1, one of the three the rest cell draws
	rig.gun_out = true
	rig.set_meta(RivetFrames.WEAPON, &"pistol")
	rig.speed_now = RivetFrames.MOVING + 10.0
	var facing: Vector2i = Vector2i(RivetFrames.EQ_OCT[1], RivetFrames.LEFT[1])
	assert_eq(RivetFrames.cell_of(rig, RivetFrames.EQ_CELLS), facing, "walking: the facing")
	rig.t_alive += SimClock.TICK_DT
	rig.speed_now = 1.0
	assert_eq(RivetFrames.cell_of(rig, RivetFrames.EQ_CELLS), facing, "the dip keeps the facing")
	rig.t_alive += SimClock.TICK_DT * (RivetWalk.DIP_TICKS + 1)
	var rest: Vector2i = Vector2i(RivetFrames.Eq.REST, 0)
	assert_eq(RivetFrames.cell_of(rig, RivetFrames.EQ_CELLS), rest, "a real stop rests the gun")
