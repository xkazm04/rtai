extends Scenario
## Approach the east peg from the hub floor. Only an interact within reach takes the rifle.

const PEG_M: Vector2 = Vector2(14.5, -3.15)
const APPROACH_M: Vector2 = PEG_M + Vector2(0.35, 3.0)
const TAKE_TICK: int = 90
const FIRE_TICK: int = 150
const STOW_TICK: int = 160
const REDRAW_TICK: int = 210


class Approach:
	extends InputSource
	var stage: ArenaStage
	var take: bool

	func sample(tick: int) -> TickInput:
		var actions: PlayerActions = stage.pilot.actions
		var buttons: int = PlayerCommand.pack_aim(Vector2.RIGHT, actions)
		if tick == 1 or (take and (tick == TAKE_TICK or tick == TAKE_TICK + 2)):
			buttons |= 1 << actions.bit(&"interact")
		if take and tick == FIRE_TICK:
			buttons |= 1 << actions.bit(&"fire")
		if take and actions.wheel and tick == TAKE_TICK + 4:
			buttons |= 1 << actions.bit(&"weapon_slot_2")
		if take and tick == STOW_TICK:
			buttons |= 1 << actions.bit(&"weapon_slot_1")
		if take and tick == REDRAW_TICK:
			buttons |= 1 << actions.bit(&"weapon_slot_2")
		var north: bool = stage.arena.rivet.pos.y > stage.plan.base.y + PEG_M.y
		return TickInput.new(buttons, 0, -TickInput.AXIS_MAX if north else 0)


func run(_tree: SceneTree) -> String:
	for mode: String in ["legacy", "wheel"]:
		LaunchArgs.parse(["--controls=" + mode])
		var reason: String = _cases()
		LaunchArgs.parse()
		if reason != "":
			return "%s: %s" % [mode, reason]
	return ""


func _cases() -> String:
	for take: bool in [false, true]:
		var s: ArenaSession = ArenaSession.open(Events, Data)
		s.stage.arena.rivet.pos = s.plan.base + APPROACH_M
		s.world.loop().start_recording()
		var reason: String = _approach(s, take)
		var log: ReplayLog = s.world.loop().finish_recording()
		s.world.free()
		if reason != "":
			return reason
		if take:
			return _replay(log)
	return ""


func _approach(s: ArenaSession, take: bool) -> String:
	var input: Approach = Approach.new()
	input.stage = s.stage
	input.take = take
	s.world.loop().set_input(input)
	while s.tick() < REDRAW_TICK + 1:
		s.step()
		if s.tick() <= TAKE_TICK and s.stage.arena.rivet.weapon == &"assault-rifle":
			return "the rack gave Rivet the rifle before he used the peg"
		if take and s.actions.wheel and s.tick() == TAKE_TICK + 4:
			if (
				s.pilot.wheel.selected() != &"hands"
				or RivetCarry.RIFLE not in s.pilot.wheel.order()
			):
				return "the rifle must enter the wheel without drawing it"
		if take and s.tick() == STOW_TICK + 1 and s.stage.arena.rivet.weapon != &"gloria":
			return "Rivet could not switch back to Gloria"
	return _judge(s, take)


func _judge(s: ArenaSession, take: bool) -> String:
	var peg: Vector2 = s.plan.base + PEG_M
	if s.stage.arena.rivet.pos.distance_to(peg) > WeaponPickups.REACH_M:
		return (
			"Rivet could not reach the rifle peg from the hub floor: %s" % s.stage.arena.rivet.pos
		)
	var carry: RivetCarry = s.pilot.carry
	if not take:
		return _walk_past(s)
	if carry == null or carry.weapon() != &"assault-rifle" or carry.ground.picked != 1:
		return "interacting at the rack did not put its assault rifle in Rivet's carry"
	if s.stage.arena.rivet.weapon != carry.weapon() or not carry.slots.has(&"gloria"):
		return "the rack pickup did not equip the rifle alongside Gloria"
	var magazine: int = s.stage.arena.tuning.weapon(&"assault-rifle").magazine
	if s.stage.shots_fired != 1 or s.stage.arena.rifle_ammo != magazine - 1:
		return "the rack rifle did not keep its fired magazine through the switch"
	return ""


func _walk_past(s: ArenaSession) -> String:
	if not s.actions.wheel:
		return "" if s.pilot.carry == null else "walking past the peg changed Rivet's loadout"
	var wheel: RivetWheel = s.pilot.wheel
	if wheel.order() != [&"hands", &"gloria"] or wheel.selected() != &"hands":
		return "walking past the rack changed the starting wheel"
	return ""


func _replay(log: ReplayLog) -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = ArenaSession.open(bus, data)
	s.stage.arena.rivet.pos = s.plan.base + APPROACH_M
	var divergence: String = s.world.verify_replay(log)
	s.world.free()
	bus.free()
	data.free()
	return divergence
