extends Scenario
## rivet-arsenal: pickups in the live arena's real fight (WeaponPickups on RivetCarry). Rivet
## carries a pistol and walks 3 m right over two guns: a rocket launcher (empty slot 3: taken and
## drawn), a machine pistol (slot 1 holds the pistol: it stays down, no interact), then he presses
## interact over it (swap: the pistol drops behind him, the machine pistol is drawn). Replays
## identical (SIM-05). TST-05: the planted fault (interact never pressed, so a walk-over alone
## would have to swap) must fail the judge.

const LIMIT_TICKS: int = 150
const INTERACT_TICK: int = 120
const EVIDENCE_FILE: String = "rivet-pickup-telemetry.json"


class WalkInput:
	extends InputSource
	var actions: PlayerActions
	var stage: ArenaStage
	var stop_x: float
	var interact_tick: int = INTERACT_TICK

	func _init(p_actions: PlayerActions, p_stage: ArenaStage) -> void:
		actions = p_actions
		stage = p_stage
		stop_x = p_stage.arena.rivet.pos.x + 3.0

	func sample(tick: int) -> TickInput:
		var b: int = PlayerCommand.pack_aim(Vector2.RIGHT, actions)
		if tick == interact_tick:
			b |= 1 << actions.bit(&"interact")
		var walk: int = TickInput.AXIS_MAX if stage.arena.rivet.pos.x < stop_x else 0
		return TickInput.new(b, walk, 0)


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = _open(Events, Data)
	s.world.loop().start_recording()
	var tel: Dictionary = _play(s)
	var log: ReplayLog = s.world.loop().finish_recording()
	s.world.free()
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, tel)
	var reason: String = _judge(tel)
	if reason != "":
		return reason
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var again: ArenaSession = _open(bus, data)
	var divergence: String = again.world.verify_replay(log)
	again.world.free()
	bus.free()
	data.free()
	if divergence != "":
		return "rivet pickup replay diverged: %s" % divergence
	return _planted()


func _planted() -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = _open(bus, data, -1)
	var tel: Dictionary = _play(s)
	s.world.free()
	bus.free()
	data.free()
	return "the planted no-interact run passed the judge: %s" % tel if _judge(tel) == "" else ""


static func _open(bus: EventBus, data: DataStore, interact: int = INTERACT_TICK) -> ArenaSession:
	var s: ArenaSession = ArenaSession.open(bus, data)
	for h: ArenaHook in s.stage.hooks:
		if h is ArenaArsenal:
			var c: RivetCarry = (h as ArenaArsenal).arm([&"pistol"] as Array[StringName], false)
			var r: Vector2 = s.stage.arena.rivet.pos
			c.ground.drop(&"rocket_launcher", r + Vector2(1.5, 0.0))
			c.ground.drop(&"machine_pistol", r + Vector2(3.0, 0.0))
	var input: WalkInput = WalkInput.new(s.actions, s.stage)
	input.interact_tick = interact
	s.world.loop().set_input(input)
	return s


static func _play(s: ArenaSession) -> Dictionary:
	var c: RivetCarry = s.stage.pilot.carry
	var after_walk: Dictionary = {}
	while s.tick() < LIMIT_TICKS:
		s.step()
		if s.tick() == INTERACT_TICK - 1:
			after_walk = {"slots": _names(c.slots), "ground": _ground(c)}
	return {
		"after_walk": after_walk,
		"slots": _names(c.slots),
		"weapon": String(c.weapon()),
		"ground": _ground(c),
		"picked": c.ground.picked,
		"swapped": c.ground.swapped,
	}


static func _judge(tel: Dictionary) -> String:
	var walk: Dictionary = tel["after_walk"]
	if walk.get("slots", []) != ["pistol", "", "rocket_launcher", ""]:
		return "walking over the guns did not take only the launcher: %s" % tel
	if walk.get("ground", []) != ["machine_pistol"]:
		return "the machine pistol should wait for interact: %s" % tel
	if tel["slots"][0] != "machine_pistol" or tel["ground"] != ["pistol"]:
		return "interact did not swap the pistol for the machine pistol: %s" % tel
	if tel["weapon"] != "machine_pistol" or tel["picked"] != 1 or tel["swapped"] != 1:
		return "the swapped gun is not in the claw: %s" % tel
	return ""


static func _names(ids: Array[StringName]) -> Array[String]:
	var out: Array[String] = []
	for id: StringName in ids:
		out.append(String(id))
	return out


static func _ground(c: RivetCarry) -> Array[String]:
	var out: Array[String] = []
	for it: WeaponPickups.Item in c.ground.items:
		out.append(String(it.id))
	return out
