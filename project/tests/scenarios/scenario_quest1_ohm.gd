extends Scenario
## Lane ghost-powers: Ohm on quest 1's street car (the generated city, collect_call_city.json
## `ghost_cars`; [] since d7-calls ghost-powers-5, so Quest1GhostStreet parks the fitted three).
## After the warm-up a spread group of dock guards stands east of Rivet; scripted input picks Ohm
## (two G taps: Dent is locked in quest 1, G skips him), takes him (Q) and presses melee every
## CADENCE ticks with the stick on the nearest guard, or, once none stands within the bolt's range,
## on the nearest live car: the guards fall, then the car bolt burns the car out (car_damage x
## machine_k). The same seed twice must give the same counts and world state hash (SIM-05).
## TST-05: the planted fault (Ohm's machine_k 0) must change the outcome: the car survives.

const EVIDENCE_FILE: String = "quest1-ohm.json"
const WARM: int = 420
const TICKS: int = 450
const PICKS: Array[int] = [10, 14]
const TAKE_AT: int = 30
const FIRST_PRESS: int = 70
const CADENCE: int = 20
const CAR_AIM_M: float = 11.0
const GROUP: Array[Vector2] = [
	Vector2(4.5, -1.2), Vector2(6.0, 1.4), Vector2(7.5, -0.4), Vector2(6.5, 3.0), Vector2(8.5, 1.0)
]
## The beat's floor: [key, minimum].
const NEEDS: Array[Array] = [["cars_hit", 3], ["wrecks", 1], ["kills", 4]]


func run(_tree: SceneTree) -> String:
	var clean: Dictionary = _run(false)
	var out: Dictionary = {"clean": clean["counts"]}
	for need: Array in NEEDS:
		var got: int = clean["counts"][need[0]]
		var floor_n: int = need[1]
		if got < floor_n:
			return "Ohm in quest 1 fell short (%s < %d): %s" % [need[0], floor_n, clean["counts"]]
	var again: Dictionary = _run(false)
	out["again"] = again["counts"]
	if again["hash"] != clean["hash"] or again["counts"] != clean["counts"]:
		return "Ohm in quest 1: the same seed gave a different outcome: %s" % JSON.stringify(out)
	var faulty: Dictionary = _run(true)
	out["planted_machine_k_0"] = faulty["counts"]
	if faulty["hash"] == clean["hash"] or faulty["counts"]["wrecks"] != 0:
		return "Ohm in quest 1: the planted machine_k 0 went unseen: %s" % JSON.stringify(out)
	out["hash"] = clean["hash"]
	return write_evidence(EVIDENCE_FILE, out)


func _run(fault: bool) -> Dictionary:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: Quest1Session = Quest1GhostStreet.open(bus, data, [])  # Dent locked, the cars back
	var counts: Dictionary = {}
	var hash: String = ""
	if s != null:
		if fault:
			s.pilot.ohm.attacks.block(OhmStage.GHOST)["machine_k"] = 0.0  # planted (TST-05)
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
	var wrecks: int = 0
	for b: VehicleBody in stage.cars():
		wrecks += 1 if b.state == VehicleBody.State.WRECK else 0
	var o: OhmStage = stage.pilot.ohm
	return {
		"bolts": o.bolts,
		"struck": o.struck,
		"cars_hit": o.cars_hit,
		"wrecks": wrecks,
		"kills": stage.arena.kills,
	}


## The scripted pad: three G taps pick Ohm, Q takes him, melee every CADENCE ticks; the right
## stick on the nearest standing guard, else (none within CAR_AIM_M) the nearest live car.
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
		if near > CAR_AIM_M:
			for b: VehicleBody in stage.cars():
				if b.state != VehicleBody.State.WRECK and rivet.distance_to(b.pos) < near:
					near = rivet.distance_to(b.pos)
					best = (b.pos - rivet).normalized()
		return best
