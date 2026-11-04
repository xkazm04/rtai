extends Scenario
## features/combat/weapons in the REAL fight (CombatArena + GunHand + FightAreas, the model the
## arena, the city block and the quest share): each core weapon fires at a knot of five
## contractors for 6 s, twice on the same seed, and the fight's state hash must be identical
## (replay-identical); a planted fault (one contractor 5 cm off) must move it. Each weapon must
## also show its own behaviour: the bullets drop humans, the rocket knocks the living down, the
## flame and the molotov set fires that kill, the electro bolt chains and stuns. The unique five
## drop a human per hit; the homing shards are aimed 2 m off the knot and must curve onto it; the
## mini-nuke clears the whole knot with one shell.

const CORE: Array[StringName] = [
	&"pistol",
	&"machine_pistol",
	&"rocket_launcher",
	&"flamethrower",
	&"electro_gun",
	&"molotov",
	&"hand_cannon",
	&"plasma_rifle",
	&"ray_gun",
	&"homing_shard",
	&"mini_nuke"
]
## The homing shard gun aims this far to the side of its target (the shard has to turn).
const HOMING_MISS: Vector2 = Vector2(0.0, 2.0)
const TICKS: int = 360
const SEED: int = 20261104
const KNOT: Array[Vector2] = [
	Vector2(0.0, 0.0), Vector2(1.0, 1.5), Vector2(1.0, -1.5), Vector2(2.5, 0.5), Vector2(-1.0, 2.5)
]


func run(_tree: SceneTree) -> String:
	var table: WeaponTable = WeaponTable.shipped()
	if not table.ok():
		return "weapons.json does not load"
	var out: Dictionary = {}
	var failure: String = ""
	for w: StringName in CORE:
		var a: Dictionary = _fight(table, w, 0.0)
		var b: Dictionary = _fight(table, w, 0.0)
		var c: Dictionary = _fight(table, w, 0.05)
		a["planted_hash"] = c["hash"]
		out[String(w)] = a
		if failure != "":
			continue
		if a["hash"] != b["hash"]:
			failure = "%s: same seed, different fight hash %d vs %d" % [w, a["hash"], b["hash"]]
		elif a["hash"] == c["hash"]:
			failure = "%s: planted fault (a contractor 5 cm off) not caught" % w
		else:
			failure = _judge(w, a)
	Log.info("scenario", "gunplay fight: %s" % JSON.stringify(out))
	var err: String = write_evidence("gunplay-fight.json", out)
	return failure if failure != "" else err


func _fight(table: WeaponTable, w: StringName, fault_m: float) -> Dictionary:
	var bus: EventBus = EventBus.new()
	var reg: RngRegistry = RngRegistry.new(SEED)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	arena.gun = GunHand.make(table, w, reg.stream(&"gunplay"))
	arena.gun.tap = true
	var centre: Vector2 = Vector2(minf(table.weapon(w).range_m * 0.6, 10.0), 0.0)
	for i: int in KNOT.size():
		var g: Fighter = arena.spawn_guard(centre)
		g.pos = centre + KNOT[i] + (Vector2(fault_m, 0.0) if i == 0 else Vector2.ZERO)
		g.cooldown = 1000000
	var peak: Dictionary[String, int] = {"patches": 0, "stunned": 0, "burning": 0}
	var digest: StreamPeerBuffer = StreamPeerBuffer.new()
	for t: int in TICKS:
		var foe: Fighter = _nearest(arena)
		if foe != null:
			@warning_ignore("return_value_discarded")
			arena.rivet_fire(foe.pos + (HOMING_MISS if w == &"homing_shard" else Vector2.ZERO))
		arena.step(t + 1)
		_peaks(arena, peak)
		if t % 30 == 29:
			arena.write_state(digest)
	bus.free()
	var a: FightAreas = arena.areas
	return {
		"hash": hash(digest.data_array),
		"kills": arena.kills,
		"shots": arena.gun.shots_fired,
		"knockdowns": a.knockdowns if a != null else 0,
		"ignitions": a.ignitions if a != null else 0,
		"chain_hits": a.chain_hits if a != null else 0,
		"peak": peak,
	}


func _peaks(arena: CombatArena, peak: Dictionary[String, int]) -> void:
	if arena.areas == null:
		return
	peak["patches"] = maxi(peak["patches"], arena.areas.patches.size())
	var stunned: int = 0
	var burning: int = 0
	for h: Fighter in arena.hostiles:
		var e: FighterFx = arena.areas.effect(h)
		if e != null and h.alive():
			stunned += 1 if e.stun_ticks > 0 else 0
			burning += 1 if e.burn_ticks > 0 else 0
	peak["stunned"] = maxi(peak["stunned"], stunned)
	peak["burning"] = maxi(peak["burning"], burning)


func _nearest(arena: CombatArena) -> Fighter:
	var best: Fighter = null
	for h: Fighter in arena.hostiles:
		var e: FighterFx = arena.areas.effect(h) if arena.areas != null else null
		if not h.alive() or (e != null and e.burn_ticks > 0):
			continue
		if best == null or h.pos.length() < best.pos.length():
			best = h
	return best


func _judge(w: StringName, r: Dictionary) -> String:
	var ok: bool = true
	match w:
		&"pistol", &"machine_pistol", &"hand_cannon", &"plasma_rifle", &"ray_gun", &"homing_shard":
			ok = r["kills"] >= 3
		&"mini_nuke":
			ok = r["kills"] == KNOT.size() and r["shots"] == 1
		&"rocket_launcher":
			ok = r["kills"] >= 2 and r["knockdowns"] >= 1
		&"flamethrower":
			ok = r["ignitions"] >= 2 and r["kills"] >= 1 and r["peak"]["burning"] >= 1
		&"molotov":
			ok = r["ignitions"] >= 2 and r["kills"] >= 1 and r["peak"]["patches"] >= 1
		&"electro_gun":
			ok = r["chain_hits"] >= 1 and r["peak"]["stunned"] >= 2
	return "" if ok else "%s: the weapon's behaviour did not show in the fight (%s)" % [w, r]
