extends Scenario
## Lane ghost-powers: Tonnage on quest 1's street car (the generated city, collect_call_city.json
## `ghost_cars`, the start-side one). After the warm-up dock guards stand round the car; scripted
## input takes Tonnage (Q), the left stick walks the press toward the car until its centre is
## STOP_M off, then melee every CADENCE ticks: the slam flattens the car and the guards round it.
## The same seed twice must give the same counts and world state hash (SIM-05).
## TST-05: the planted fault (Tonnage's car_crush_m 0) must change the outcome: the car stands.

const EVIDENCE_FILE: String = "quest1-tonnage.json"
const WARM: int = 420
const TICKS: int = 300
const TAKE_AT: int = 10
## The form settles before the press walks (as quest_crush_rec).
const WALK_FROM: int = 40
## The head lands press_ahead_m 0.9 ahead, so a car centre within car_crush_m 3.4 + 0.9 is in reach.
const STOP_M: float = 3.4
const CADENCE: int = 20
const GUARDS: Array[Vector2] = [
	Vector2(-1.6, 1.4), Vector2(1.8, 1.5), Vector2(0.0, 2.2), Vector2(-3.0, 0.4), Vector2(2.9, -0.2)
]
## The beat's floor: [key, minimum].
const NEEDS: Array[Array] = [["stomps", 1], ["cars_crushed", 1], ["wrecks", 1], ["kills", 3]]


func run(_tree: SceneTree) -> String:
	var clean: Dictionary = _run(false)
	var out: Dictionary = {"clean": clean["counts"]}
	for need: Array in NEEDS:
		var got: int = clean["counts"][need[0]]
		var floor_n: int = need[1]
		if got < floor_n:
			return (
				"Tonnage in quest 1 fell short (%s < %d): %s" % [need[0], floor_n, clean["counts"]]
			)
	var again: Dictionary = _run(false)
	out["again"] = again["counts"]
	if again["hash"] != clean["hash"] or again["counts"] != clean["counts"]:
		return (
			"Tonnage in quest 1: the same seed gave a different outcome: %s" % JSON.stringify(out)
		)
	var faulty: Dictionary = _run(true)
	out["planted_car_crush_m_0"] = faulty["counts"]
	if faulty["hash"] == clean["hash"] or faulty["counts"]["wrecks"] != 0:
		return "Tonnage in quest 1: the planted car_crush_m 0 went unseen: %s" % JSON.stringify(out)
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
			var block: Dictionary = s.pilot.hauler.attacks.block(HaulerStage.GHOST)
			block["car_crush_m"] = 0.0  # planted (TST-05)
		for i: int in WARM:
			s.step()
		var stage: CollectCallStage = s.stage
		var car: VehicleBody = _near_car(stage)
		for off: Vector2 in GUARDS:
			var g: Fighter = stage.arena.spawn_guard(car.pos + off)
			g.pos = car.pos + off
		s.world.loop().set_input(Press.new(stage, s.actions, s.tick(), car))
		for t: int in TICKS:
			s.step()
		counts = _counts(stage, car)
		hash = s.world.loop().state_hash()
		s.world.free()
	bus.free()
	data.free()
	return {"counts": counts, "hash": hash}


func _near_car(stage: CollectCallStage) -> VehicleBody:
	var rivet: Vector2 = stage.arena.rivet.pos
	var best: VehicleBody = null
	for b: VehicleBody in stage.cars():
		if best == null or rivet.distance_to(b.pos) < rivet.distance_to(best.pos):
			best = b
	return best


func _counts(stage: CollectCallStage, car: VehicleBody) -> Dictionary:
	var h: HaulerStage = stage.pilot.hauler
	return {
		"stomps": h.form.stomps,
		"stomp_hits": h.stomp_hits,
		"cars_crushed": h.cars_crushed,
		"wrecks": 1 if car.state == VehicleBody.State.WRECK else 0,
		"kills": stage.arena.kills,
	}


## The scripted pad: Q takes Tonnage; from WALK_FROM the left stick walks toward the car until it
## is STOP_M off, then melee every CADENCE ticks while in reach (stateless: a pure function of
## the tick and the stage, so the recorded stream replays).
class Press:
	extends InputSource

	var stage: CollectCallStage
	var actions: PlayerActions
	var start: int
	var car: VehicleBody

	func _init(
		p_stage: CollectCallStage, p_actions: PlayerActions, p_start: int, p_car: VehicleBody
	) -> void:
		stage = p_stage
		actions = p_actions
		start = p_start
		car = p_car

	func sample(tick: int) -> TickInput:
		var t: int = tick - start
		var gap: Vector2 = car.pos - stage.arena.rivet.pos
		var walk: bool = t >= WALK_FROM and gap.length() > STOP_M
		var slam: bool = t >= WALK_FROM and not walk and t % CADENCE == 0
		var buttons: int = PlayerCommand.pack_aim(gap.normalized(), actions)
		buttons |= _bit(&"power_hauler", t == TAKE_AT)
		buttons |= _bit(&"melee", slam)
		var move: Vector2 = gap.normalized() * 0.9 * TickInput.AXIS_MAX if walk else Vector2.ZERO
		return TickInput.new(buttons, roundi(move.x), roundi(move.y))

	func _bit(action: StringName, on: bool) -> int:
		return 1 << actions.bit(action) if on else 0
