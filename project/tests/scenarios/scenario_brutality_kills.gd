extends Scenario
## Lane brutality: the signature kills in the arena's real fight (CombatArena + GunHand +
## FightAreas) with the KillLab line, for the finished kills (rocket gib, hand cannon blowback,
## fire char, electro X-ray, katana, plasma sword and chainsaw split (the lab lunges and
## slashes; the chainsaw holds through its grind), plasma hole). Each weapon must land signature
## kills of its own style, replay identically on a fresh
## world (SIM-05: the gibs and marks are in the world hash), and give the same gib state on the
## same seed. TST-05: a planted fault (one gib 1 % faster) must change the gib state.

const TICKS: int = 700
const EVIDENCE_FILE: String = "brutality-kills.json"
## weapon -> the style its kills must take.
const KILLS: Dictionary[StringName, StringName] = {
	&"rocket_launcher": &"gib",
	&"hand_cannon": &"blowback",
	&"flamethrower": &"burn",
	&"electro_gun": &"shock",
	&"katana": &"split",
	&"plasma_rifle": &"hole",
	&"plasma_sword": &"split",
	&"chainsaw": &"split",
}


func run(_tree: SceneTree) -> String:
	var out: Dictionary = {}
	for weapon: StringName in KILLS:
		var reason: String = _weapon(weapon, out)
		if reason != "":
			return reason
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, out)
	return _planted()


func _weapon(weapon: StringName, out: Dictionary) -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = _open(bus, data, weapon)
	s.world.loop().start_recording()
	var state: PackedByteArray = _play(s, -1)
	var log: ReplayLog = s.world.loop().finish_recording()
	var hook: BrutalityHook = _hook(s)
	var n: int = hook.kills.by_style.get(KILLS[weapon], 0)
	out[String(weapon)] = {"kills": hook.kills.consumed.size(), "style_kills": n}
	_close(s, bus, data)
	if n < 2:
		return "%s landed %d %s kills in %d ticks" % [weapon, n, KILLS[weapon], TICKS]
	var again: PackedByteArray = _state_of(weapon, -1)
	if again != state:
		return "%s: the same seed gave different gibs" % weapon
	return _replay(weapon, log)


func _replay(weapon: StringName, log: ReplayLog) -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = _open(bus, data, weapon)
	var divergence: String = s.world.verify_replay(log)
	_close(s, bus, data)
	return "" if divergence == "" else "%s replay diverged: %s" % [weapon, divergence]


func _planted() -> String:
	var clean: PackedByteArray = _state_of(&"rocket_launcher", -1)
	var faulty: PackedByteArray = _state_of(&"rocket_launcher", 0)
	return "a planted 1 % gib speed fault went unseen" if clean == faulty else ""


## The brutality state after TICKS; `fault_slot` >= 0 speeds that gib slot up 1 % once.
func _state_of(weapon: StringName, fault_slot: int) -> PackedByteArray:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = _open(bus, data, weapon)
	var state: PackedByteArray = _play(s, fault_slot)
	_close(s, bus, data)
	return state


func _play(s: ArenaSession, fault_slot: int) -> PackedByteArray:
	var hook: BrutalityHook = _hook(s)
	var planted: int = -1
	var buf: StreamPeerBuffer = StreamPeerBuffer.new()
	while s.tick() < TICKS:
		s.step()
		if planted < 0 and hook.kills.gibs.live(maxi(fault_slot, 0)):
			planted = s.tick()
			if fault_slot >= 0:
				hook.kills.gibs.vel[fault_slot] *= 1.01
		elif planted >= 0 and s.tick() == planted + 30:  # showcase r4: before the slot recycles
			hook.write_state(buf)
	hook.write_state(buf)
	return buf.data_array


func _open(bus: EventBus, data: DataStore, weapon: StringName) -> ArenaSession:
	var s: ArenaSession = ArenaSession.open(bus, data)
	var hook: BrutalityHook = _hook(s)
	hook.arm(s.stage, s.world.context(), weapon)
	hook.open_lab(s.stage, weapon)
	return s


func _close(s: ArenaSession, bus: EventBus, data: DataStore) -> void:
	s.world.free()
	bus.free()
	data.free()


func _hook(s: ArenaSession) -> BrutalityHook:
	for h: ArenaHook in s.stage.hooks:
		if h is BrutalityHook:
			return h as BrutalityHook
	return null
