extends Scenario
## F-09b exit: the 50- and 200-person rig stress, 10 s each on the fixed tick, headless. Passes
## when no more than 16 full rigs ever run, play never builds a rig (the pools hold), and the
## median rig work per tick is inside the STANDARDS section 20 hard limit (1 ms). Tail latency
## (p99) is logged, not gated: a shared box's stalls would make it flaky. The section 20 p99
## verdict is the bench on an idle machine (dev/bench/rig_bench.gd -> rig-bench.json).

const TICKS: int = 600
const SIZES: Array[int] = [50, 200]


func run(tree: SceneTree) -> String:
	for people: int in SIZES:
		var reason: String = _one(tree, people)
		if reason != "":
			return reason
	return ""


func _one(tree: SceneTree, people: int) -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var ctx: WorldContext = World.build_context(bus, data, 9)
	var rigs: CharacterRigs = CharacterRigs.new()
	tree.root.add_child(rigs)
	rigs.setup(ctx)
	var stress: RigStress = RigStress.new(rigs, people)
	stress.run(TICKS)
	var m: Dictionary[String, float] = stress.metrics()
	Log.info("rig_stress", "%d people: %s" % [people, JSON.stringify(m)])
	rigs.queue_free()
	bus.free()
	data.free()
	if m["fullRigsMax"] > CharacterRigs.MAX_FULL:
		return "%d people: %d full rigs ran (cap 16)" % [people, int(m["fullRigsMax"])]
	if m["poolGrown"] > 0.0:
		return "%d people: the pools grew in play" % people
	if m["rigMsP50"] > RigStress.HARD_MS:
		return "%d people: rig p50 %.3f ms > %.1f ms" % [people, m["rigMsP50"], RigStress.HARD_MS]
	return ""
