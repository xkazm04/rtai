extends Scenario
## Lane human-reactions: the arena's reaction line played by ReactLineBot on the real session.
## Rivet shoots each of the four dummies once from the west, north, east and south: 16 shots
## must land 16 hits, 4 per dummy, and the rounds must travel east, south, west, north in turn
## (the direction the reaction layer animates along, ReactLink reads CombatArena.struck), and
## the run must replay identical on a fresh world (SIM-05). TST-05 planted fault: every spot on
## the west side, so the direction check must fail.

const TICKS: int = 36 * SimClock.TICK_RATE
const WANT: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
const MIN_DOT: float = 0.95


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = ArenaSession.open(Events, Data)
	var bot: ReactLineBot = ReactLineBot.new(s.stage, s.actions)
	var dirs: Array[Vector2] = []
	@warning_ignore("return_value_discarded")
	s.stage.arena.struck.connect(
		func(_v: Fighter, d: Vector2, _l: bool, _w: StringName) -> void: dirs.append(d)
	)
	s.world.loop().set_input(bot)
	s.world.loop().start_recording()
	while s.tick() < TICKS:
		s.step()
	var log: ReplayLog = s.world.loop().finish_recording()
	var tel: ArenaTelemetry = s.stage.telemetry
	var dot: float = min_dot(dirs)
	@warning_ignore("return_value_discarded")
	write_evidence("react-line.json", {"shots": bot.shots, "hits": tel.hits, "dir_dot_min": dot})
	var verdict: String = _verdict(bot, s.stage, dirs, dot)
	s.world.free()
	if verdict != "":
		return verdict
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var again: ArenaSession = ArenaSession.open(bus, data)
	var divergence: String = again.world.verify_replay(log)
	again.world.free()
	bus.free()
	data.free()
	if divergence != "":
		return "react line replay diverged: %s" % divergence
	return _planted()


func _verdict(bot: ReactLineBot, stage: ArenaStage, dirs: Array[Vector2], dot: float) -> String:
	if not bot.done() or bot.shots != 16:
		return "the bot fired %d of 16 shots (done %s)" % [bot.shots, bot.done()]
	if dirs.size() != 16:
		return "%d rounds struck, want 16" % dirs.size()
	for id: String in ReactLineBot.SPAWNS:
		var got: Array = stage.targets.ttk_s.get(id, [])
		var n: int = got.size()
		if n != 4:
			return "%s was hit %d times, want 4" % [id, n]
	if dot < MIN_DOT:
		return "a round did not travel from the side it was shot from (dot %.2f)" % dot
	return ""


## The worst agreement between each struck round and the side order W, N, E, S (as travel).
static func min_dot(dirs: Array[Vector2]) -> float:
	var worst: float = 1.0
	for i: int in dirs.size():
		worst = minf(worst, dirs[i].normalized().dot(WANT[i % WANT.size()]))
	return worst


## Every spot on the west: the rounds all travel east, so the direction check must fail.
func _planted() -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = ArenaSession.open(bus, data)
	var bot: ReactLineBot = ReactLineBot.new(s.stage, s.actions)
	var west: Vector2 = ReactLineBot.SIDES[0]
	bot.sides = [west, west, west, west]
	var dirs: Array[Vector2] = []
	@warning_ignore("return_value_discarded")
	s.stage.arena.struck.connect(
		func(_v: Fighter, d: Vector2, _l: bool, _w: StringName) -> void: dirs.append(d)
	)
	s.world.loop().set_input(bot)
	while s.tick() < TICKS / 2:
		s.step()
	var dot: float = min_dot(dirs)
	s.world.free()
	bus.free()
	data.free()
	if dirs.is_empty():
		return "the planted run struck nothing"
	return "" if dot < MIN_DOT else "the planted west-only run passed the direction check"
