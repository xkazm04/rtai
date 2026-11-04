extends Scenario
## rivet-arsenal: the weapon switch in the live arena's real fight (ArenaArsenal + RivetCarry +
## StagePilot's WeaponHold). Rivet carries pistol, plasma rifle, rocket launcher and molotov;
## the fire button is held all run. Key 3 at SWITCH_TICK: no rocket leaves until the pistol's
## stow plus the launcher's draw (rivet_arsenal.json) has passed, then one leaves at once. The
## wheel then cycles 3 -> 4 -> wrap to 1, and the run replays identical on a fresh world (SIM-05).
## TST-05: a planted fault (the shoulder draw cut to 1 tick) must fire the rocket too early.

const LIMIT_TICKS: int = 300
const SWITCH_TICK: int = 30
const NEXT_TICKS: PackedInt32Array = [150, 220]
const LOADOUT: Array[StringName] = [&"pistol", &"plasma_rifle", &"rocket_launcher", &"molotov"]
const EVIDENCE_FILE: String = "rivet-switch-telemetry.json"


class SwitchInput:
	extends InputSource
	var actions: PlayerActions

	func _init(p_actions: PlayerActions) -> void:
		actions = p_actions

	func sample(tick: int) -> TickInput:
		var b: int = PlayerCommand.pack_aim(Vector2.DOWN, actions)
		b |= 1 << actions.bit(&"fire")
		if tick == SWITCH_TICK:
			b |= 1 << actions.bit(&"weapon_slot_3")
		if NEXT_TICKS.has(tick):
			b |= 1 << actions.bit(&"weapon_next")
		return TickInput.new(b)


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = _open(Events, Data, null)
	s.world.loop().start_recording()
	var tel: Dictionary = _play(s)
	var log: ReplayLog = s.world.loop().finish_recording()
	s.world.free()
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, tel)
	var reason: String = _judge(tel)
	if reason != "":
		return reason
	var divergence: String = _replay(log)
	return divergence if divergence != "" else _planted()


static func _open(bus: EventBus, data: DataStore, hold: WeaponHold) -> ArenaSession:
	var s: ArenaSession = ArenaSession.open(bus, data)
	if hold != null:
		s.stage.pilot.hold = hold
	for h: ArenaHook in s.stage.hooks:
		if h is ArenaArsenal:
			@warning_ignore("return_value_discarded")
			(h as ArenaArsenal).arm(LOADOUT, true)
	s.world.loop().set_input(SwitchInput.new(s.actions))
	return s


## Steps the run; returns when the first rocket left, the expected tick and the slot order.
static func _play(s: ArenaSession) -> Dictionary:
	var a: ArsenalTable = ArsenalTable.shipped()
	var expect: int = (
		SWITCH_TICK + a.grip_of(&"pistol").stow_ticks + a.grip_of(&"rocket_launcher").draw_ticks
	)
	var first_rocket: int = -1
	var order: Array[int] = []
	while s.tick() < LIMIT_TICKS:
		s.step()
		var carry: RivetCarry = s.stage.pilot.carry
		if order.is_empty() or order[order.size() - 1] != carry.current:
			order.append(carry.current)
		var rocket: bool = carry.weapon() == &"rocket_launcher"
		if first_rocket < 0 and rocket and s.stage.arena.gun.shots_fired > 0:
			first_rocket = s.tick()
	var out: Dictionary = {"first_rocket_tick": first_rocket, "expected_tick": expect}
	out["slot_order"] = order
	out["switches"] = s.stage.pilot.carry.switches
	out["draw_ms"] = (first_rocket - SWITCH_TICK) * 1000.0 / SimClock.TICK_RATE
	return out


static func _judge(tel: Dictionary) -> String:
	var first: int = tel["first_rocket_tick"]
	var expect: int = tel["expected_tick"]
	if first < expect or first > expect + 2:
		return "rocket left at tick %d, the stow+draw ends at %d: %s" % [first, expect, tel]
	if tel["slot_order"] != [0, 2, 3, 0]:
		return "the switch order is not 1 -> 3 -> 4 -> 1: %s" % [tel["slot_order"]]
	return ""


func _replay(log: ReplayLog) -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var again: ArenaSession = _open(bus, data, null)
	var divergence: String = again.world.verify_replay(log)
	again.world.free()
	bus.free()
	data.free()
	return "" if divergence == "" else "rivet switch replay diverged: %s" % divergence


func _planted() -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var t: ArsenalTable = ArsenalTable.shipped()
	t.grips[&"shoulder"].draw_ticks = 1
	var s: ArenaSession = _open(bus, data, WeaponHold.new(t))
	var tel: Dictionary = _play(s)
	s.world.free()
	bus.free()
	data.free()
	if _judge(tel) == "":
		return "the planted 1-tick shoulder draw passed the judge: %s" % tel
	return ""
