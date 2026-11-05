extends Scenario
## Lane ghost-powers: Kerf on quest 1 (the generated city). After the warm-up a spread group of
## dock guards stands east of Rivet; scripted input picks Kerf (two G taps), takes him (Q) and
## presses melee every CADENCE ticks with the stick on the nearest standing guard: each press
## blinks Rivet behind a guard and the beam slices it (the one-shot cauterised split). The same
## seed twice must give the same counts and world state hash (SIM-05).
## TST-05: the planted fault (Kerf's human_damage 0) must change the outcome: no guard falls.

const EVIDENCE_FILE: String = "quest1-kerf.json"
const WARM: int = 420
const TICKS: int = 300
const PICKS: Array[int] = [10, 14]
const TAKE_AT: int = 30
const FIRST_PRESS: int = 70
const CADENCE: int = 20
const GROUP: Array[Vector2] = [
	Vector2(4.5, -1.2), Vector2(6.0, 1.4), Vector2(7.5, -0.4), Vector2(6.5, 3.0), Vector2(8.5, 1.0)
]
## The beat's floor: [key, minimum].
const NEEDS: Array[Array] = [["blinks", 4], ["slices", 4], ["kills", 4]]


func run(_tree: SceneTree) -> String:
	var clean: Dictionary = _run(false)
	var out: Dictionary = {"clean": clean["counts"]}
	for need: Array in NEEDS:
		var got: int = clean["counts"][need[0]]
		var floor_n: int = need[1]
		if got < floor_n:
			return "Kerf in quest 1 fell short (%s < %d): %s" % [need[0], floor_n, clean["counts"]]
	var again: Dictionary = _run(false)
	out["again"] = again["counts"]
	if again["hash"] != clean["hash"] or again["counts"] != clean["counts"]:
		return "Kerf in quest 1: the same seed gave a different outcome: %s" % JSON.stringify(out)
	var faulty: Dictionary = _run(true)
	out["planted_human_damage_0"] = faulty["counts"]
	if faulty["hash"] == clean["hash"] or faulty["counts"]["kills"] >= clean["counts"]["kills"]:
		return "Kerf in quest 1: the planted human_damage 0 went unseen: %s" % JSON.stringify(out)
	out["hash"] = clean["hash"]
	return write_evidence(EVIDENCE_FILE, out)


func _run(fault: bool) -> Dictionary:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	Quest1Session.on_city = true
	var s: Quest1Session = Quest1Session.open(bus, data)
	var counts: Dictionary = {}
	var hash: String = ""
	if s != null:
		if fault:
			s.pilot.kerf.attacks.block(KerfStage.GHOST)["human_damage"] = 0.0  # planted (TST-05)
		for i: int in WARM:
			s.step()
		var stage: CollectCallStage = s.stage
		var at: Vector2 = stage.arena.rivet.pos
		for off: Vector2 in GROUP:
			var g: Fighter = stage.arena.spawn_guard(at + off)
			g.pos = at + off
		s.world.loop().set_input(Press.new(stage, s.actions, s.tick()))
		for t: int in TICKS:
			s.step()
		counts = _counts(stage)
		hash = s.world.loop().state_hash()
		s.world.free()
	bus.free()
	data.free()
	return {"counts": counts, "hash": hash}


func _counts(stage: CollectCallStage) -> Dictionary:
	var k: KerfStage = stage.pilot.kerf
	return {"blinks": k.blinks, "slices": k.slices, "kills": stage.arena.kills}


## The scripted pad: two G taps pick Kerf, Q takes him, melee every CADENCE ticks; the right
## stick on the nearest standing guard.
class Press:
	extends InputSource

	var stage: CollectCallStage
	var actions: PlayerActions
	var start: int

	func _init(p_stage: CollectCallStage, p_actions: PlayerActions, p_start: int) -> void:
		stage = p_stage
		actions = p_actions
		start = p_start

	func sample(tick: int) -> TickInput:
		var t: int = tick - start
		var buttons: int = PlayerCommand.pack_aim(_aim(), actions)
		buttons |= _bit(&"power_gearbox", t in PICKS)
		buttons |= _bit(&"power_hauler", t == TAKE_AT)
		buttons |= _bit(&"melee", t >= FIRST_PRESS and (t - FIRST_PRESS) % CADENCE == 0)
		return TickInput.new(buttons)

	func _bit(action: StringName, on: bool) -> int:
		return 1 << actions.bit(action) if on else 0

	func _aim() -> Vector2:
		var rivet: Vector2 = stage.arena.rivet.pos
		var best: Vector2 = Vector2.RIGHT
		var near: float = INF
		for h: Fighter in stage.arena.hostiles:
			if h.alive() and rivet.distance_to(h.pos) < near:
				near = rivet.distance_to(h.pos)
				best = (h.pos - rivet).normalized()
		return best
