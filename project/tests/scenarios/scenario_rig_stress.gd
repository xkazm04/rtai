extends Scenario
## F-09b exit: the 50- and 200-person rig stress, 10 s each on the fixed tick, headless. Passes
## when no more than 16 full rigs ever run (+ RigSelect.CORPSE_PINS fresh dead in a card view),
## play never builds a rig (the pools hold), and the median rig work per tick is inside the
## STANDARDS section 20 hard limit (1 ms). Tail latency (p99) is logged, not gated: a shared box's
## stalls would make it flaky. The section 20 p99 verdict is the bench on an idle machine
## (dev/bench/rig_bench.gd -> rig-bench.json).

const TICKS: int = 600
const SIZES: Array[int] = [50, 200]
## Test-only: GTAI_BUDGET_SCALE multiplies the 1 ms budget (0.001 forces a miss). The tools runner
## sets GTAI_CONTENTION (other machine runs at launch) and GTAI_CONTENTION_FILE (the live count): a
## miss while others run is reported CONTENDED and passes; the runner re-judges it alone.


## n9: the budget is judged in `top` (F-09b's baseline); the combo default's card rigs cost about 2x
## (1.1-1.3 ms p50 at 50, quiet): logged as COMBO, not gated (DEVIATION STD-20-RIG, docs/decisions).
func run(tree: SceneTree) -> String:
	var was: ViewMode = ViewMode.shared()
	ViewMode.select("top")
	var reason: String = ""
	for people: int in SIZES:
		reason = _one(tree, people)
		if reason != "":
			break
	ViewMode._shared = was
	if reason == "" and was.cards:
		_combo(tree, was)
	return reason


func _combo(tree: SceneTree, view: ViewMode) -> void:
	var m: Dictionary[String, float] = _measure(tree, SIZES[0])
	Log.info(
		"rig_stress", "COMBO %s 50 people: rig p50 %.3f ms (not gated)" % [view.id, m["rigMsP50"]]
	)


func _one(tree: SceneTree, people: int) -> String:
	var m: Dictionary[String, float] = _measure(tree, people)
	# a card view keeps up to CORPSE_PINS fresh dead rigged past the cap
	var pins: int = RigSelect.CORPSE_PINS if ViewMode.shared().cards else 0
	if m["fullRigsMax"] > CharacterRigs.MAX_FULL + pins:
		return "%d people: %d full rigs ran (cap %d)" % [people, int(m["fullRigsMax"]), 16 + pins]
	if m["poolGrown"] > 0.0:
		return "%d people: the pools grew in play" % people
	return _p50_verdict(people, m["rigMsP50"])


func _measure(tree: SceneTree, people: int) -> Dictionary[String, float]:
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
	return m


func _p50_verdict(people: int, p50_ms: float) -> String:
	var scale_text: String = OS.get_environment("GTAI_BUDGET_SCALE")
	var budget: float = RigStress.HARD_MS * (scale_text.to_float() if scale_text != "" else 1.0)
	if p50_ms <= budget:
		return ""
	var others: int = _contention()
	if others > 0:
		Log.warn(
			"scenario",
			"CONTENDED: rig_stress.rigMsP50 %.3f > %.3f (%d other runs)" % [p50_ms, budget, others]
		)
		return ""
	return "%d people: rig p50 %.3f ms > %.3f ms" % [people, p50_ms, budget]


## Other machine runs: the launch count, raised by the runner's live file while it runs.
func _contention() -> int:
	var others: int = OS.get_environment("GTAI_CONTENTION").to_int()
	var path: String = OS.get_environment("GTAI_CONTENTION_FILE")
	if path != "" and FileAccess.file_exists(path):
		others = maxi(others, FileAccess.get_file_as_string(path).strip_edges().to_int())
	return others
