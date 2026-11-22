extends Node
## Each cell starts a new live arena. Read the fire edge back from its sampled tape and the
## accepted starts from StagePilot, including buffered starts after the button has gone up.

const WEAPONS: Array[StringName] = [
	&"hands", &"chainsaw", &"electro_baton", &"katana", &"plasma_sword"
]
const MODES: Array[String] = ["single", "mash", "held"]
const WAVE: Array[StringName] = [
	&"patrol_cop", &"riot_cop", &"swat", &"contractor", &"rocket_trooper"
]
const WARM: int = 60
const ACTIVE: int = 180
const TAIL: int = 60

var trials: Array[Dictionary] = []
var valid: bool = true
var driver: AnimationPlayer


func _ready() -> void:
	var scene_path: String = OS.get_environment("GTAI_MELEE_PLAYER")
	var player: PackedScene = load(scene_path) as PackedScene
	driver = player.instantiate() as AnimationPlayer
	add_child(driver)
	for weapon: StringName in WEAPONS:
		for single: bool in [false, true]:
			for mode: String in MODES:
				trials.append(_trial(weapon, single, mode))
	var path: String = OS.get_environment("GTAI_MELEE_OUT").path_join("swings.json")
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		Log.error("swing_measure", error_string(FileAccess.get_open_error()))
		get_tree().quit(1)
		return
	@warning_ignore("return_value_discarded")
	file.store_line(
		JSON.stringify({"tick_rate": SimClock.TICK_RATE, "ticks": ACTIVE, "trials": trials}, "\t")
	)
	file.close()
	get_tree().quit(0 if valid else 1)


func _trial(weapon: StringName, single: bool, mode: String) -> Dictionary:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var session: ArenaSession = ArenaSession.open(bus, data, 20261109)
	OpeningFilmPad.button(&"fire", 0.0)
	OpeningFilmPad.sticks(Vector2.ZERO, Vector2.RIGHT)
	session.live.viewport = null
	while session.tick() < 3:
		session.step()
	_equip(session, weapon)
	var arena: CombatArena = session.stage.arena
	arena.rivet.pos = session.plan.base + Vector2(7, -38)
	session.stage.pit.points.clear()
	arena.rivet.hp = 10000.0
	arena.rivet.max_hp = arena.rivet.hp
	while session.tick() < WARM:
		session.step()
	_spawn_wave(session, arena)
	var actual: StringName = MeleeTable.CLAW if weapon == &"hands" else weapon
	if session.pilot.wheel.selected() != weapon or session.pilot.melee.weapon_id != actual:
		valid = false
		Log.error("swing_measure", "wheel did not equip %s" % weapon)
	session.pilot.melee.combo.table.single_swing = single
	var result: Dictionary = _measure(session, mode)
	result.merge({"weapon": weapon, "single_swing": single, "cadence": mode})
	session.close()
	bus.free()
	data.free()
	return result


func _spawn_wave(session: ArenaSession, arena: CombatArena) -> void:
	arena.hostiles.clear()
	session.stage.pit.standing.clear()
	for i: int in WAVE.size():
		var at: Vector2 = arena.rivet.pos + Vector2(1.2 + i * 0.46, (i % 3 - 1) * 0.38)
		var foe: Fighter = arena.squad_ai.spawn_member(arena, at, WAVE[i])
		session.stage.pit.standing.append(foe)


func _equip(session: ArenaSession, weapon: StringName) -> void:
	if weapon == &"hands":
		return
	var ids: Array[StringName] = [weapon]
	for hook: ArenaHook in session.stage.hooks:
		if hook is ArenaArsenal:
			@warning_ignore("return_value_discarded")
			(hook as ArenaArsenal).arm(ids, false)
	session.step()
	OpeningFilmPad.scroll(session.live)


func _measure(s: ArenaSession, mode: String) -> Dictionary:
	var clicks: Array[int] = []
	var starts: Array[int] = []
	var active_starts: int = 0
	var mask: int = 1 << s.actions.bit(&"fire")
	var last_fire: bool = false
	var hit: MeleeHit = s.pilot.melee.combo.table.hits[0]
	var landed: int = s.pilot.melee.landed
	var cadence: Animation = driver.get_animation(StringName(mode))
	for age: int in ACTIVE + TAIL:
		var press: bool = age < ACTIVE and _down(cadence, age)
		OpeningFilmPad.button(&"fire", float(press))
		var before: int = s.pilot.melee_swings
		s.step()
		var sampled: bool = (TickInput.unpack(s.tape.change_inputs[-1]).buttons & mask) != 0
		if sampled and not last_fire:
			clicks.append(age)
		last_fire = sampled
		if s.pilot.melee_swings > before:
			starts.append(age)
			active_starts += int(age < ACTIVE)
	var counts: Dictionary = {
		"click_ticks": clicks,
		"start_ticks": starts,
		"clicks": clicks.size(),
		"starts": starts.size()
	}
	counts.merge(
		{
			"contacts": s.pilot.melee.landed - landed,
			"active_starts": active_starts,
			"row_ticks": hit.length()
		}
	)
	counts["swings_per_click"] = float(starts.size()) / maxi(1, clicks.size())
	counts["swings_per_second"] = float(active_starts) * SimClock.TICK_RATE / ACTIVE
	return counts


func _down(cadence: Animation, age: int) -> bool:
	var period: int = roundi(cadence.length * SimClock.TICK_RATE)
	var at: float = (float(age % period) + 0.5) * SimClock.TICK_DT
	for key: int in range(cadence.track_get_key_count(0) - 1, -1, -1):
		if cadence.track_get_key_time(0, key) <= at:
			return cadence.track_get_key_value(0, key) == true
	return false
