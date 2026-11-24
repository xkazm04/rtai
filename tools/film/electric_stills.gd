extends ArenaGame
## Record the real hit, prime, execution or short stun. Each capture starts a clean arena.
## GTAI_MELEE_TAKE is the existing output directory. --victim and --sig-gun select the contact.

const AGES: Array[int] = [0, 10, 30, 60]
const CONTACT: int = 110
const SECOND: int = 227

var source: StringName
var victim: Fighter
var enemy: StringName
var mark: Vector2
var output: String
var moments: Dictionary[StringName, int] = {}
var pending: Array[StringName] = []
var saved: int = 0
var last_frame: int = -1
var alive_saved: bool = false


func _ready() -> void:
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	super()
	process_priority = -1000
	session.world.set_process(false)
	session.live.viewport = null
	source = StringName(ArenaArgs.parse().text("--sig-gun"))
	enemy = StringName(ArenaArgs.parse().text("--victim"))
	output = OS.get_environment("GTAI_MELEE_TAKE")
	session.stage.arena.rivet.pos = session.plan.base + Vector2(5, -38)
	@warning_ignore("return_value_discarded")
	RenderingServer.frame_post_draw.connect(_capture)


func _place() -> void:
	var arena: CombatArena = session.stage.arena
	session.stage.pit.points.clear()
	session.stage.pit.standing.clear()
	arena.hostiles.clear()
	var reach: float = 3.35 if source == &"electro_gun" else 1.34
	mark = arena.rivet.pos + reach * Vector2.RIGHT
	victim = arena.squad_ai.spawn_member(arena, mark, enemy)
	victim.pos = mark
	session.stage.pit.standing.append(victim)
	if source == &"electro_gun" and session.pilot.wheel.selected() == RivetWheel.HANDS:
		OpeningFilmPad.scroll(session.live)
	@warning_ignore("return_value_discarded")
	arena.struck.connect(_struck)


func _struck(f: Fighter, _dir: Vector2, lethal: bool, weapon: StringName) -> void:
	if f != victim or weapon != source:
		return
	var tick: int = session.stage.arena.tick
	var event: StringName = &"execute" if lethal else &"stun"
	if not lethal and MeleeShutdown.primed(f, tick):
		event = &"prime"
	pending.append(event)


func _process(_delta: float) -> void:
	var tick: int = session.tick()
	if tick == 3:
		_place()
	if tick > SECOND + 75 or saved == AGES.size() * (2 if enemy == &"shield_robot" else 1):
		_finish()
		return
	if victim != null:
		var cue: int = SECOND if enemy == &"shield_robot" and tick > CONTACT + 21 else CONTACT
		var charge: bool = source == &"claw_shock" and tick >= cue - 80 and tick < cue
		if victim.alive():
			victim.pos = mark
			victim.facing = Vector2.LEFT
			var mind: SquadMind = session.stage.arena.squad_ai.mind_for(victim)
			mind.agent.pos = mark
			mind.agent.facing = victim.facing
			mind.agent.cooldown = 100
			victim.cooldown = 100
		# Aim the opening jab away. Only the charged release touches the staged robot.
		var aim: Vector2 = Vector2.LEFT if charge and tick < cue - 48 else Vector2.RIGHT
		OpeningFilmPad.sticks(Vector2.ZERO, aim)
		OpeningFilmPad.button(&"melee", float(charge))
		OpeningFilmPad.button(&"fire", float(source == &"electro_gun" and tick == cue))
	session.step()


func _capture() -> void:
	var tick: int = session.tick()
	if last_frame == tick:
		return
	last_frame = tick
	if victim != null and victim.alive() and tick == CONTACT - 1 and not alive_saved:
		alive_saved = _save("%s-alive.png" % enemy)
	for event: StringName in pending:
		moments[event] = tick
	pending.clear()
	for event: StringName in moments:
		var age: int = tick - moments[event]
		if age in AGES and _save("%s-%s-plus%02d.png" % [enemy, event, age]):
			saved += 1


## The crop of the victim (alive or wrecked) saved under `file`; false (and a quit) on failure.
func _save(file: String) -> bool:
	var center: Vector2 = view.fx_view.get_global_transform_with_canvas() * Ink.px(mark)
	var size: Vector2i = Vector2i(328, 200) if px_per_m < 48.0 else Vector2i(600, 326)
	center -= Vector2(px_per_m * 0.75, px_per_m * 0.75)
	var crop: Rect2i = Rect2i(Vector2i(center) - size / 2, size)
	var frame: Image = get_viewport().get_texture().get_image()
	if not Rect2i(Vector2i.ZERO, frame.get_size()).encloses(crop):
		Log.error("electric_stills", "capture outside viewport: %s" % crop)
		get_tree().quit(1)
		return false
	if frame.get_region(crop).save_png(output.path_join(file)) != OK:
		get_tree().quit(1)
		return false
	return true


func _finish() -> void:
	var expected: Array[StringName] = [&"execute"]
	if enemy == &"shield_robot":
		expected = [&"prime", &"execute"]
	elif enemy == &"war_machine":
		expected = [&"stun"]
	for event: StringName in expected:
		if not moments.has(event) or saved != expected.size() * AGES.size():
			Log.error(
				"electric_stills", "expected %s, got %s (%d frames)" % [expected, moments, saved]
			)
			get_tree().quit(1)
			return
	Log.info("electric_stills", "%s %s %s: %d frames" % [source, enemy, moments, saved])
	get_tree().quit()
