extends GutTest
## n17 npc-react: the World steps the sim before the cast rigs read it (RigTickOrder).


func test_world_steps_before_the_rig_feed() -> void:
	var game: Node = Node.new()
	var world: World = World.new()
	var host: Node = Node.new()
	game.add_child(world)
	game.add_child(host)
	RigTickOrder.place(host)
	assert_eq(host.process_priority, RigTickOrder.RIG_PRIORITY)
	assert_lt(world.process_priority, host.process_priority, "World ticks first")
	game.free()


func test_no_world_sibling_leaves_the_others_alone() -> void:
	var game: Node = Node.new()
	var other: Node = Node.new()
	var host: Node = Node.new()
	game.add_child(other)
	game.add_child(host)
	RigTickOrder.place(host)
	assert_eq(other.process_priority, 0)
	assert_eq(host.process_priority, RigTickOrder.RIG_PRIORITY)
	game.free()
