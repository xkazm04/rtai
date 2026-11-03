extends Scenario
## The city proving block (--arena=city): the same stations laid on the generated city at
## arena.json city.base, the city's buildings, props and parked cars colliding, its people on the
## streets. The range bot plays there: it must land hits, Rivet must stay out of every building,
## and the run must replay identical on a fresh world (SIM-05). TST-05: the planted fault (the
## city collision off) must leave Rivet inside a building he was dropped into.

const TICKS: int = 15 * SimClock.TICK_RATE
const EVIDENCE_FILE: String = "arena-city-telemetry.json"
## Just inside the building south-west of the junction (probed: solid from x -48 to -12 m, y 12
## to 48 m off the hub). The planted fault drops Rivet here: collision must push him out.
const IN_BUILDING: Vector2 = Vector2(-12.4, 20.0)


## The stick at rest every tick.
class Hold:
	extends InputSource

	func sample(_tick: int) -> TickInput:
		return TickInput.new()


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = ArenaSession.open(Events, Data, ArenaSession.MASTER_SEED, null, true)
	var bot: ArenaRangeBot = ArenaRangeBot.new(s.stage, s.actions)
	s.world.loop().set_input(bot)
	s.world.loop().start_recording()
	var inside: int = 0
	while s.tick() < TICKS:
		s.step()
		inside += 0 if s.stage.cells.clear(s.stage.arena.rivet.pos, 0.2) else 1
	var log: ReplayLog = s.world.loop().finish_recording()
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, s.stage.telemetry_dict())
	var hits: int = s.stage.telemetry.hits
	s.world.free()
	if hits < 2:
		return "the range bot landed %d hits on the city block" % hits
	if inside > 0:
		return "Rivet stood inside a building for %d ticks" % inside
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var again: ArenaSession = ArenaSession.open(bus, data, ArenaSession.MASTER_SEED, null, true)
	var divergence: String = again.world.verify_replay(log)
	again.world.free()
	bus.free()
	data.free()
	if divergence != "":
		return "arena city replay diverged: %s" % divergence
	return _planted()


## Rivet dropped inside the building: with the city's collision he is out after one tick; with
## it planted off (the stage's cells and the bodies' follow both cut) he stays in.
func _planted() -> String:
	if _dropped_in(true):
		return "with collision on, Rivet stayed inside the building"
	if not _dropped_in(false):
		return "with collision off he still left the building: the check would miss the fault"
	return ""


func _dropped_in(collide: bool) -> bool:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = ArenaSession.open(bus, data, ArenaSession.MASTER_SEED, null, true)
	var cells: StageCells = s.stage.cells
	s.world.loop().set_input(Hold.new())
	if not collide:
		s.stage.cells = null
		s.stage.follow = null
	s.stage.arena.rivet.pos = s.plan.base + IN_BUILDING
	s.step()
	var inside: bool = not cells.clear(s.stage.arena.rivet.pos, 0.2)
	s.world.free()
	bus.free()
	data.free()
	return inside
