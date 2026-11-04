extends Scenario
## The showcase's director cut (ReelDirector, `--bot=reel --reel=director --loadout=pistol`): every
## chapter hands Rivet its weapon and its victims all go down (claw combo to mini-nuke), Rivet
## stays up, and the run replays identical on a fresh world armed the same way (SIM-05).
## TST-05: a planted fault (every button off) on the first three chapters kills nobody.

const EVIDENCE_FILE: String = "showcase-director-telemetry.json"
const PLANTED_CHAPTERS: int = 3


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = ArenaSession.open(Events, Data)
	var reel: CombatReel = _wire(s)
	s.world.loop().start_recording()
	while s.tick() < reel.length():
		s.step()
	var log: ReplayLog = s.world.loop().finish_recording()
	var d: ReelDirector = reel.director
	d.step(s.stage, s.tick())  # closes the last chapter's count
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, {"kills": d.kills, "deaths": s.stage.deaths})
	var problem: String = _judge(s, d)
	s.world.free()
	if problem != "":
		return problem
	var divergence: String = _replay(log)
	return divergence if divergence != "" else _planted()


## The reel in director mode on `s`, Rivet armed as --loadout=pistol arms him.
static func _wire(s: ArenaSession) -> CombatReel:
	var reel: CombatReel = CombatReel.new(s.stage, s.actions)
	reel.director = ReelDirector.new(s.actions)
	s.stage.hooks.append(reel.director)
	for hook: ArenaHook in s.stage.hooks:
		if hook is ArenaArsenal:
			@warning_ignore("return_value_discarded")
			(hook as ArenaArsenal).arm([&"pistol"], true)
	s.world.loop().set_input(reel)
	return reel


func _judge(s: ArenaSession, d: ReelDirector) -> String:
	for c: ReelChapters.Chapter in d.chapters:
		if d.kills.get(c.id, 0) < c.victims.size():
			return (
				"chapter %s: %d of %d down (%s)"
				% [c.id, d.kills.get(c.id, 0), c.victims.size(), d.kills]
			)
	if s.stage.deaths > 0:
		return "Rivet went down %d times in the director cut" % s.stage.deaths
	return ""


func _replay(log: ReplayLog) -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var again: ArenaSession = ArenaSession.open(bus, data)
	@warning_ignore("return_value_discarded")
	_wire(again)
	var divergence: String = again.world.verify_replay(log)
	again.world.free()
	bus.free()
	data.free()
	return "" if divergence == "" else "director cut replay diverged: %s" % divergence


func _planted() -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = ArenaSession.open(bus, data)
	var reel: CombatReel = _wire(s)
	reel.director.trigger = false
	reel.director.chapters = reel.director.chapters.slice(0, PLANTED_CHAPTERS)
	while s.tick() < reel.length():
		s.step()
	var down: int = 0
	for h: Fighter in s.stage.arena.hostiles:
		down += 0 if h.alive() else 1
	s.world.free()
	bus.free()
	data.free()
	return "a director cut with every button off still killed %d" % down if down > 0 else ""
