extends Scenario
## Corpse decay under a horde (the owner, 2026-11-04: "bring hoards of opponents without
## damaging visibility in longer fights"). The arena pit runs back-to-back horde waves
## (ArenaPit.horde) against Rivet's pistol (ArenaArsenalBot) until WANT_DEAD guards died. On every
## tick the bodies drawn (CorpseDecay) and the dead still in the fight stay at or under the
## table's cap; the fight's list stays bounded (released bodies leave CombatArena.hostiles); no
## body is popped out while still opaque; the sim step costs about the same at the end as early
## on; the run replays identical (SIM-05). TST-05 planted fault: a linger that never expires and
## no cap must overflow the cap.

const LIMIT_TICKS: int = 300 * SimClock.TICK_RATE
const WANT_DEAD: int = 60
const WINDOW: int = 600
const LOADOUT: Array[StringName] = [&"pistol"]
const EVIDENCE_FILE: String = "corpse-horde.json"
## The most opaque a body may be when the hard cap releases it (a pop) in a steady horde.
const MAX_FORCED_ALPHA: float = 0.35


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = _open(Events, Data)
	s.world.loop().set_input(ArenaArsenalBot.new(s.stage, s.actions))
	s.world.loop().start_recording()
	var r: Dictionary = _play(s, false)
	var log: ReplayLog = s.world.loop().finish_recording()
	s.world.free()
	var fault: Dictionary = _planted()
	r["planted_max_listed"] = fault["max_listed"]
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, r)
	var why: String = _judge(r)
	if why != "":
		return why
	if fault["max_listed"] <= r["cap"]:
		return (
			"planted fault not caught: %d dead stayed listed (cap %d)"
			% [fault["max_listed"], r["cap"]]
		)
	return _replay(log)


func _judge(r: Dictionary) -> String:
	if r["died"] < WANT_DEAD:
		return "the horde stalled: %s" % r
	if r["max_drawn"] > r["cap"] or r["max_listed"] > r["cap"]:
		return "more bodies on the floor than the cap: %s" % r
	if r["max_hostiles"] > r["hostiles_bound"]:
		return "the fight's list kept growing: %s" % r
	if r["forced_alpha"] > MAX_FORCED_ALPHA:
		return "a body popped out while still opaque: %s" % r
	if r["last_us"] > 2.0 * r["first_us"] + 500.0:
		return "the step grew with the dead (%d -> %d us): %s" % [r["first_us"], r["last_us"], r]
	return ""


static func _open(bus: EventBus, data: DataStore) -> ArenaSession:
	var s: ArenaSession = ArenaSession.open(bus, data)
	for h: ArenaHook in s.stage.hooks:
		if h is ArenaArsenal:
			@warning_ignore("return_value_discarded")
			(h as ArenaArsenal).arm(LOADOUT, true)
	s.stage.pit.horde()
	var rivet: Fighter = s.stage.arena.rivet
	rivet.max_hp *= ArenaPit.HORDE_RIVET_HP
	rivet.hp = rivet.max_hp
	return s


static func _hook(s: ArenaSession) -> CorpseDecayHook:
	for h: ArenaHook in s.stage.hooks:
		if h is CorpseDecayHook:
			return h as CorpseDecayHook
	return null


## Steps until WANT_DEAD died (or LIMIT_TICKS); `fault` plants a decay that never expires.
static func _play(s: ArenaSession, fault: bool) -> Dictionary:
	var hook: CorpseDecayHook = _hook(s)
	if fault:
		hook.decay.bodies = DecayLedger.make(1.0e6, 1.0, 100000, 0)
	var max_drawn: int = 0
	var max_hostiles: int = 0
	var windows: Array[int] = []
	var spent: int = 0
	while s.tick() < LIMIT_TICKS and hook.died < WANT_DEAD:
		var t0: int = Time.get_ticks_usec()
		s.step()
		spent += Time.get_ticks_usec() - t0
		if s.tick() % WINDOW == 0:
			windows.append(roundi(float(spent) / WINDOW))
			spent = 0
		max_drawn = maxi(max_drawn, hook.decay.bodies.count())
		max_hostiles = maxi(max_hostiles, s.stage.arena.hostiles.size())
	var b: DecayLedger = hook.decay.bodies
	var n: int = windows.size()
	return {
		"cap": b.cap,
		"died": hook.died,
		"pruned": hook.pruned,
		"max_drawn": max_drawn,
		"max_listed": hook.peak_dead_listed,
		"max_hostiles": max_hostiles,
		"hostiles_bound": hook.fixtures() + b.cap + s.stage.pit.max_wave + 2,
		"forced": b.forced,
		"forced_alpha": b.forced_alpha,
		"early_fades": b.early,
		"ticks": s.tick(),
		"window_us": windows,
		"first_us": windows[1] if n > 2 else 0,
		"last_us": windows[n - 1] if n > 2 else 0,
	}


static func _planted() -> Dictionary:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = _open(bus, data)
	s.world.loop().set_input(ArenaArsenalBot.new(s.stage, s.actions))
	var r: Dictionary = _play(s, true)
	s.world.free()
	bus.free()
	data.free()
	return r


func _replay(log: ReplayLog) -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var again: ArenaSession = _open(bus, data)
	var divergence: String = again.world.verify_replay(log)
	again.world.free()
	bus.free()
	data.free()
	return "" if divergence == "" else "horde replay diverged: %s" % divergence
