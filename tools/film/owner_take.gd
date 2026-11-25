extends ArenaGame
## A continuous fixed-input take. Waiting opponents hold their floor marks and face the
## approach. The arena owns contact, armour, stun, kill, and the movement of the struck body.

const HUMAN: Array[StringName] = [
	&"patrol_cop", &"riot_cop", &"swat", &"contractor", &"rocket_trooper"
]
const ROBOT: Array[StringName] = [
	&"robot_thug", &"robot_thug", &"robot_gunner", &"shield_robot", &"war_machine"
]
const FIRST: int = 105
const HUMAN_GAP: int = 182
const MACHINE_GAP: int = 212
## claw_shock: the charge (melee held) runs this long before the release at age 0, and the
## shield robot's second discharge (its overload is primed by the first) releases at CLAW_AGAIN.
const CLAW_GAP: int = 250
const CLAW_CHARGE: int = 80
const CLAW_AGAIN: int = 100

var opponents: Array[Fighter] = []
var marks: Array[Vector2] = []
var observations: Array[Dictionary] = []
var starts: Array[int] = []
var contacts: Array[int] = []
var weapon: StringName
var robots: bool
var charged: bool
var destination: String
var gap: int = HUMAN_GAP
var last_frame: int = 0
var stop_tick: int = 960
## GTAI_TAKE_HOP=1: a second thug stands HOP_M behind the first, inside the electro gun's chain
## radius, held on its mark until the bolt lands; hop_log is the proof (chain hits, its daze).
var hop_extra: Fighter = null
var hop_mark: Vector2 = Vector2.ZERO
var hop_log: Dictionary = {}
const HOP_M: float = 2.5


func _ready() -> void:
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	super()
	process_priority = -1000
	session.world.set_process(false)
	session.live.viewport = null
	var loadout: String = ArenaArgs.parse().text("--loadout", "hands")
	charged = loadout == "claw_shock"
	robots = loadout.contains(",") or charged
	weapon = RivetWheel.HANDS if charged else StringName(loadout.get_slice(",", 0))
	destination = OS.get_environment("GTAI_MELEE_TAKE")
	if robots:
		gap = CLAW_GAP if charged else MACHINE_GAP
		stop_tick += (gap - HUMAN_GAP) * (ROBOT.size() - 1)
	if OS.get_environment("GTAI_MELEE_CLOSE") == "1":
		stop_tick = FIRST + 75
	var hop: bool = OS.get_environment("GTAI_TAKE_HOP") == "1"
	session.stage.arena.rivet.pos = session.plan.base + Vector2(-1 if hop else 5, -38)
	if OS.get_environment("GTAI_MELEE_NATIVE") == "1":
		@warning_ignore("return_value_discarded")
		RenderingServer.frame_post_draw.connect(_capture)


func _place() -> void:
	var arena: CombatArena = session.stage.arena
	session.stage.pit.points.clear()
	session.stage.pit.standing.clear()
	arena.hostiles.clear()
	arena.rivet.hp = 10000.0
	arena.rivet.max_hp = arena.rivet.hp
	if robots:
		_spawn(ROBOT[0], 0)
	else:
		for i: int in HUMAN.size():
			_spawn(HUMAN[i], i)
	if weapon != RivetWheel.HANDS:
		OpeningFilmPad.scroll(session.live)


func _spawn(id: StringName, i: int) -> void:
	var arena: CombatArena = session.stage.arena
	var at: Vector2 = session.plan.base + Vector2(9.0 + 4.3 * i, -38.0)
	var foe: Fighter = arena.squad_ai.spawn_member(arena, at, id)
	foe.max_hp = arena.squad_ai.pit.roster.archetype(id).hp
	foe.hp = foe.max_hp
	opponents.append(foe)
	marks.append(at)
	observations.append(
		{"victim": id, "initial_hp": foe.hp, "cue": 0 if i == 0 else FIRST + i * gap - 96}
	)
	session.stage.pit.standing.append(foe)
	if i == 0 and OS.get_environment("GTAI_TAKE_HOP") == "1":
		_spawn_extra(at + Vector2(HOP_M, 0.0), id)


func _spawn_extra(at: Vector2, id: StringName) -> void:
	var arena: CombatArena = session.stage.arena
	hop_extra = arena.squad_ai.spawn_member(arena, at, id)
	hop_extra.max_hp = arena.squad_ai.pit.roster.archetype(id).hp
	hop_extra.hp = hop_extra.max_hp
	hop_mark = at
	session.stage.pit.standing.append(hop_extra)
	hop_log = {"chain_hits": 0, "hop_m": HOP_M, "extra_hp": hop_extra.hp}


## Holds the second thug on its mark until the first is struck, then logs what the hop did to it.
func _watch_hop() -> void:
	var arena: CombatArena = session.stage.arena
	var mind: SquadMind = arena.squad_ai.mind_for(hop_extra)
	if not observations[0].has("hit_tick"):
		hop_extra.pos = hop_mark
		mind.agent.pos = hop_mark
		mind.agent.cooldown = 100
		hop_extra.cooldown = 100
	var now: int = session.tick()
	var hits: int = arena.areas.chain_hits if arena.areas != null else -1
	hop_log["chain_hits"] = hits
	if hits > 0 and not hop_log.has("first_hop_tick"):
		hop_log["first_hop_tick"] = now
	if mind.stun_until > arena.tick and not hop_log.has("stun_tick"):
		hop_log["stun_tick"] = now
	if hop_extra.hp < hop_log["extra_hp"] and not hop_log.has("hurt_tick"):
		hop_log["hurt_tick"] = now


func _process(_delta: float) -> void:
	var tick: int = session.tick()
	if tick >= stop_tick:
		_finish()
		return
	if tick == 3:
		_place()
	if tick < 4:
		session.step()
		return
	var idx: int = clampi(floori(float(tick - FIRST + 96) / gap), 0, HUMAN.size() - 1)
	if robots and idx == opponents.size():
		_spawn(ROBOT[idx], idx)
	var age: int = tick - FIRST - idx * gap
	_waiting(tick)
	if robots and idx == 1 and age == -65 and weapon != &"electro_gun":
		OpeningFilmPad.scroll(session.live)
	var again: int = _followup(idx)
	var engage: bool = age < 0 or (again > 0 and age > 8 and age < again)
	_approach(idx, engage and age >= -83 and hop_extra == null)
	_press(age, again)
	var pilot: StagePilot = session.pilot
	var count: int = pilot.melee_swings
	var landed: int = pilot.melee.landed
	var wielded: PlayerMelee = pilot.melee
	session.step()
	if count < pilot.melee_swings:
		starts.append(session.tick())
	if wielded == pilot.melee and landed < pilot.melee.landed:
		contacts.append(session.tick())
	_observe(idx, age)
	if hop_extra != null:
		_watch_hop()


func _press(age: int, again: int) -> void:
	if not charged:
		OpeningFilmPad.button(&"fire", float(age == 0 or (again > 0 and age == again)))
		return
	# The melee press jabs, then the held button charges; the release at age 0 is the discharge.
	var first: bool = age >= -CLAW_CHARGE and age < 0
	var second: bool = again > 0 and age >= again - CLAW_CHARGE and age < again
	OpeningFilmPad.button(&"melee", float(first or second))


func _followup(i: int) -> int:
	if charged:
		return CLAW_AGAIN if i == 3 else -1
	if robots and i == 3:
		return 56
	if not robots and weapon == &"katana" and i == 1:
		return 32
	return -1


func _waiting(tick: int) -> void:
	var squad: ArenaSquad = session.stage.arena.squad_ai
	for i: int in opponents.size():
		var foe: Fighter = opponents[i]
		if not foe.alive():
			continue
		var age: int = tick - FIRST - i * gap
		var mind: SquadMind = squad.mind_for(foe)
		if age < 0 or (age < 16 and not observations[i].has("hit_tick")):
			foe.pos = marks[i]
			foe.facing = Vector2.LEFT
			mind.agent.pos = foe.pos
			mind.agent.facing = foe.facing
		if age < 16 or (age > 60 and foe.alive()):
			mind.agent.cooldown = 100
			foe.cooldown = 100


func _approach(i: int, walk: bool) -> void:
	var foe: Fighter = opponents[i]
	var offset: Vector2 = foe.pos - session.stage.arena.rivet.pos
	var aim: Vector2 = offset.normalized() if foe.alive() else Vector2.RIGHT
	var move: Vector2 = Vector2.ZERO
	if walk and offset.length() > 1.17:
		move = offset.normalized()
	OpeningFilmPad.sticks(move, aim)


func _observe(i: int, age: int) -> void:
	var foe: Fighter = opponents[i]
	var arena: CombatArena = session.stage.arena
	var row: Dictionary = observations[i]
	if age == 0 or age == _followup(i) and age > 0:
		row["selected"] = &"claw_shock" if charged else session.pilot.wheel.selected()
		row["distance_m"] = snappedf(foe.pos.distance_to(arena.rivet.pos), 0.01)
	var initial: float = row["initial_hp"]
	var opened: bool = foe.has_meta(MeleeLethal.OPEN_UNTIL)
	var overloaded: bool = MeleeShutdown.primed(foe, arena.tick)
	if not row.has("hit_tick") and (foe.hp != initial or opened or overloaded):
		row["hit_tick"] = session.tick()
	if opened and not row.has("shield_break"):
		row["shield_break"] = session.tick()
	if overloaded and not row.has("overloaded"):
		row["overloaded"] = session.tick()
	if foe.archetype == &"war_machine" and foe.alive():
		var until: int = arena.squad_ai.mind_for(foe).stun_until
		if until > arena.tick and not row.has("heavy_stun"):
			row["heavy_stun"] = until - arena.tick
	if not foe.alive() and not row.has("kill_tick"):
		row["kill_tick"] = session.tick()
	row["final_hp"] = foe.hp


func _capture() -> void:
	var tick: int = session.tick()
	if tick <= last_frame or tick > stop_tick:
		return
	var im: Image = get_viewport().get_texture().get_image()
	if im.get_size() != Vector2i(1920, 1080) or tick != last_frame + 1:
		Log.error("owner_take", "native frame gap or bad size at %d, after %d" % [tick, last_frame])
		get_tree().quit(1)
		return
	if im.save_jpg(destination.path_join("%04d.jpg" % tick), 0.95) != OK:
		Log.error("owner_take", "could not record native image")
		get_tree().quit(1)
		return
	last_frame = tick


func _finish() -> void:
	set_process(false)
	var f: FileAccess = FileAccess.open(destination.path_join("take.json"), FileAccess.WRITE)
	if f == null:
		get_tree().quit(1)
		return
	var result: Dictionary = {"starts": starts, "contacts": contacts, "opponents": observations}
	result.merge({"weapon": weapon, "frames": last_frame, "hop": hop_log})
	@warning_ignore("return_value_discarded")
	f.store_line(JSON.stringify(result, "\t"))
	f.close()
	get_tree().quit()
