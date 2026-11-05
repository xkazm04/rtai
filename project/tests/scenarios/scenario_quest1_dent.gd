extends Scenario
## Lane ghost-powers: Dent in quest 1 (the generated city, the street's ghost cars; since
## d7-calls ghost-powers-5 quest 1 locks Dent and parks none, so Quest1GhostStreet unlocks him
## and parks the fitted three). After the warm-up a spread group of dock guards stands
## east of Rivet; scripted input takes Tonnage, switches to Dent, aims at the nearest guard and
## presses fire every CADENCE ticks (the seize, then the strikes), then melee once (the overload
## command). Dent must seize a street car, strike guards with it and blow it up; the same seed
## twice must give the same counts and the same world state hash (SIM-05).
## TST-05: the planted fault (the layout's ghost_cars emptied) must change the outcome: no car
## to seize, so every press misses.

const EVIDENCE_FILE: String = "quest1-dent.json"
const WARM: int = 420
const TICKS: int = 300
const TAKE_AT: int = 30
const SWITCH_AT: int = 10
const FIRST_PRESS: int = 70
const CADENCE: int = 20
const BLOW_AT: int = 200
const GROUP: Array[Vector2] = [
	Vector2(4.5, -1.2), Vector2(6.0, 1.4), Vector2(7.5, -0.4), Vector2(6.5, 3.0), Vector2(8.5, 1.0)
]
## The beat's floor: [key, minimum].
const NEEDS: Array[Array] = [["seizes", 1], ["strikes", 2], ["blasts", 1], ["kills", 2]]


func run(_tree: SceneTree) -> String:
	var clean: Dictionary = _run(false)
	var out: Dictionary = {"clean": clean["counts"]}
	for need: Array in NEEDS:
		var got: int = clean["counts"][need[0]]
		var floor_n: int = need[1]
		if got < floor_n:
			return "Dent in quest 1 fell short (%s < %d): %s" % [need[0], floor_n, clean["counts"]]
	var again: Dictionary = _run(false)
	out["again"] = again["counts"]
	if again["hash"] != clean["hash"] or again["counts"] != clean["counts"]:
		return "Dent in quest 1: the same seed gave a different outcome: %s" % JSON.stringify(out)
	var faulty: Dictionary = _run(true)
	out["planted_no_ghost_cars"] = faulty["counts"]
	if faulty["hash"] == clean["hash"] or faulty["counts"]["seizes"] != 0:
		return "Dent in quest 1: the planted empty ghost_cars went unseen: %s" % JSON.stringify(out)
	out["hash"] = clean["hash"]
	return write_evidence(EVIDENCE_FILE, out)


func _run(fault: bool) -> Dictionary:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	# Dent's act done and the street's cars back (quest 1 itself locks him and parks none)
	var s: Quest1Session = Quest1GhostStreet.open(bus, data, [Quest1GhostStreet.ACT_DENT])
	var counts: Dictionary = {}
	var hash: String = ""
	if s != null:
		if fault:
			s.stage.vehicles.cars.clear()  # planted: the street's ghost cars gone before tick 0
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
	var d: DentStage = stage.pilot.ghosts.dent
	return {
		"seizes": d.seizes,
		"strikes": d.strikes,
		"blasts": d.blasts,
		"misses": d.misses,
		"rides": d.rides,
		"kills": stage.arena.kills,
		"transforms": stage.pilot.ghosts.transforms,
	}


## The scripted pad: G taps pick Dent (one switch past Tonnage), Q takes the form, the right
## stick on the nearest standing guard, fire every CADENCE ticks, melee once at BLOW_AT.
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
		var to: Vector2 = _aim()  # the cursor on the nearest guard (direction and reach)
		var buttons: int = PlayerCommand.pack_aim(to.normalized(), actions, to.length())
		buttons |= _bit(&"power_gearbox", t == SWITCH_AT)
		buttons |= _bit(&"power_hauler", t == TAKE_AT)
		buttons |= _bit(&"fire", t >= FIRST_PRESS and (t - FIRST_PRESS) % CADENCE == 0)
		buttons |= _bit(&"melee", t == BLOW_AT)
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
				best = h.pos - rivet
		return best
