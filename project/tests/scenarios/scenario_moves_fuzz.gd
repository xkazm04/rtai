extends Scenario
## Hostile inputs through the real pilot and pit guards, with all checks after body resolution.
## Repeat the recorded input words and spawn schedule on a fresh stage in each arena.

const SEED: int = 1909
const TICKS: int = 6000


class Trace:
	extends RefCounted
	var positions: PackedVector2Array = []
	var digest: String
	var counts: Dictionary[String, int] = {
		"ticks": 0,
		"vault_starts": 0,
		"vault_refusals": 0,
		"landings": 0,
		"snaps": 0,
		"peeks": 0,
		"leaves": 0,
		"cover_refusals": 0,
		"roll_cancelled_covers": 0,
		"airborne_ticks": 0,
		"cover_ticks": 0,
		"overlaps": 0,
		"guard_ticks": 0
	}
	var failure: String


func run(_tree: SceneTree) -> String:
	for city: bool in [false, true]:
		var tape: MovesFuzzTape = MovesFuzzTape.new(SEED)
		var first: Trace = _run(tape, city, TICKS)
		if first.failure != "":
			return first.failure
		tape.playing = true
		var replay: Trace = _run(tape, city, TICKS, first)
		if replay.failure != "":
			return replay.failure
		if first.digest != replay.digest or first.counts != replay.counts:
			return _failure(tape, TICKS - 1, "final digest/counts differ", city)
		Log.info(
			"moves_fuzz", "%s %s replay identical %s" % [_map(city), first.counts, first.digest]
		)
		for key: String in [
			"guard_ticks",
			"vault_starts",
			"vault_refusals",
			"landings",
			"snaps",
			"peeks",
			"leaves",
			"roll_cancelled_covers",
			"cover_refusals",
			"airborne_ticks",
			"cover_ticks"
		]:
			if first.counts[key] == 0:
				return _failure(tape, TICKS - 1, "missing coverage: " + key, city)
	return _off_control()


func _off_control() -> String:
	var saved: PackedStringArray = LaunchArgs.unknown()
	for flag: String in LaunchArgs.KNOWN_FLAGS:
		if LaunchArgs.has(flag):
			@warning_ignore("return_value_discarded")
			saved.append("%s=%s" % [flag, LaunchArgs.value(flag)])
	LaunchArgs.parse(PackedStringArray(["--no-vault", "--no-cover"]))
	var tape: MovesFuzzTape = MovesFuzzTape.new(SEED)
	var raw: Trace = _run(tape, false, 360)
	var reason: String = raw.failure
	if reason == "":
		reason = _compare_off(tape, raw)
	LaunchArgs.parse(saved)
	return reason


## StagePilot serializes the previous raw buttons. Compare after a shared release tick:
## vault shares the roll bit, and live input already masks out the disabled cover bit.
func _compare_off(tape: MovesFuzzTape, raw: Trace) -> String:
	var pilot: StagePilot = tape.stage.pilot
	var bit: int = 1 << pilot.actions.bit(&"cover")
	if pilot.motion.vault.enabled or pilot.motion.cover.enabled or (pilot.actions.live_mask & bit):
		return "off flags left a move or its live cover input enabled"
	if (
		raw.counts["vault_starts"]
		or raw.counts["snaps"]
		or not pilot.motion.rolls
		or not raw.counts["cover_refusals"]
	):
		return _failure(tape, 359, "expected refused cover presses and only ordinary rolls", false)
	tape.playing = true
	@warning_ignore("return_value_discarded")
	tape.words.append(TickInput.new().pack())
	var released: Trace = _run(tape, false, tape.words.size())
	if released.failure != "":
		return released.failure
	for i: int in tape.words.size():
		tape.words[i] &= ~(bit << 16)
	var control: Trace = _run(tape, false, tape.words.size(), released)
	if control.failure != "":
		return control.failure
	if (
		control.digest != released.digest
		or control.counts["vault_starts"]
		or control.counts["snaps"]
	):
		return _failure(tape, tape.words.size() - 1, "off control diverged", false)
	Log.info("moves_fuzz", "off: zero starts/snaps, cover stripped, identical " + control.digest)
	return ""


func _map(city: bool) -> String:
	return "city" if city else "pit"


func _world(city: bool, tape: MovesFuzzTape) -> World:
	var w: World = World.new()
	w.start(Events, Data, SEED)
	var plan: ArenaPlan = ArenaPlan.shipped()
	if city:
		plan = ArenaPlan.shipped(plan.city_base)
	var stations: ArenaStations = ArenaStations.new()
	stations.add_file(ArenaStations.DIR + "/arena.json")
	var stage: ArenaStage = ArenaStage.new(plan, stations)
	stage.cells = StageCells.shipped() if city else null
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	w.add_system(stage)
	stage.pilot.motion.vault.bind_solids(stage)
	tape.bind(stage)
	w.loop().set_input(tape)
	return w


func _run(tape: MovesFuzzTape, city: bool, ticks: int, expected: Trace = null) -> Trace:
	var w: World = _world(city, tape)
	var stage: ArenaStage = tape.stage
	var trace: Trace = Trace.new()
	var body: Fighter = stage.arena.rivet
	var motion: PlayerMotion = stage.pilot.motion
	for tick: int in ticks:
		var spawn: bool = tick % 600 == 0 or not body.alive()
		if tape.playing and spawn != tape.spawns.has(tick):
			trace.failure = _failure(tape, tick, "respawn schedule diverged", city)
			break
		if spawn and not tape.respawn(tick):
			trace.failure = _failure(tape, tick, "no clear respawn", city)
			break
		var before: PlayerCover.Phase = motion.cover.phase
		var last_hit: VaultProbe.Hit = motion.vault.hit
		w.loop().step()
		if motion.vault.hit != null and motion.vault.hit != last_hit and motion.vault.frame != 0:
			trace.counts["vault_refusals"] += 1
		_observe(tape, trace, before, tick)
		var contact: String = VaultTrial.forbidden_contact(stage)
		if contact != "":
			trace.counts["overlaps"] += 1
			trace.failure = _failure(tape, tick, contact, city)
			break
		if expected != null and expected.positions[tick] != body.pos:
			trace.failure = _failure(tape, tick, "position diverged at %s" % body.pos, city)
			break
		@warning_ignore("return_value_discarded")
		trace.positions.append(body.pos)
	trace.digest = w.loop().state_hash()
	w.free()
	return trace


func _observe(tape: MovesFuzzTape, trace: Trace, before: PlayerCover.Phase, tick: int) -> void:
	var stage: ArenaStage = tape.stage
	var m: PlayerMotion = stage.pilot.motion
	var phase: PlayerCover.Phase = m.cover.phase
	var bits: int = tape.words[tick] >> 16
	var prev: int = tape.words[tick - 1] >> 16 if tick > 0 else 0
	var cover_edge: bool = ((bits & ~prev) & (1 << stage.pilot.actions.bit(&"cover"))) != 0
	var c: Dictionary[String, int] = trace.counts
	c["ticks"] += 1
	c["vault_starts"] += int(m.vault.frame == 0)
	c["landings"] += int(m.vault.frame == m.vault.ticks - 1)
	c["airborne_ticks"] += int(m.vault.airborne())
	c["snaps"] += int(before == PlayerCover.Phase.OFF and phase != PlayerCover.Phase.OFF)
	c["cover_ticks"] += int(phase != PlayerCover.Phase.OFF)
	c["peeks"] += int(phase == PlayerCover.Phase.PEEK and before != phase)
	c["cover_refusals"] += int(cover_edge and before == phase and phase == PlayerCover.Phase.OFF)
	if before != PlayerCover.Phase.OFF and phase == PlayerCover.Phase.OFF:
		c["leaves"] += 1
		c["roll_cancelled_covers"] += int(m.phase == PlayerMotion.Phase.ROLL)
	c["guard_ticks"] += int(not stage.pit.standing.is_empty())


func _failure(tape: MovesFuzzTape, tick: int, why: String, city: bool) -> String:
	return (
		"%s tick %d seed %d %s; last inputs (tick:buttons/x/y) %s"
		% [_map(city), tick, SEED, why, tape.history(tick)]
	)
