extends ArenaGame
## Film one primary click through the live wheel, pilot, melee and rig. The cop holds position
## so each take starts at the same distance and heading, regardless of weapon draw time.

const PRESS: int = 30
const RELEASE: int = PRESS + 6
const CHECK: int = 86

var selected: StringName
var cop: Fighter
var start_ticks: Array[int] = []


func _ready() -> void:
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	super()
	process_priority = -1000
	session.world.set_process(false)
	session.live.viewport = null
	selected = StringName(ArenaArgs.parse().text("--loadout", "hands"))
	var arena: CombatArena = session.stage.arena
	arena.rivet.pos = session.plan.base + Vector2(7, -38)
	var mark: Vector2 = arena.rivet.pos + Vector2.RIGHT * 1.55
	cop = arena.spawn_guard(mark)
	cop.pos = mark
	cop.cooldown = CHECK + 1
	cop.facing = Vector2.LEFT


func _process(_delta: float) -> void:
	var tick: int = session.tick()
	var pilot: StagePilot = session.pilot
	if tick == 2 and selected != RivetWheel.HANDS:
		OpeningFilmPad.scroll(session.live)
	OpeningFilmPad.sticks(Vector2.ZERO, Vector2.RIGHT)
	OpeningFilmPad.button(&"fire", float(tick >= PRESS and tick < RELEASE))
	var previous: int = pilot.melee_swings
	session.step()
	if tick == PRESS - 1 and cast.rigs.rig_for(cop.id) == null:
		Log.error("melee_click", "the cop has no drawn rig")
		get_tree().quit(1)
	if pilot.melee_swings != previous:
		start_ticks.append(session.tick())
	if tick == CHECK:
		Log.info(
			"melee_click",
			(
				"%s starts %s, lands %d, shocks %d"
				% [selected, start_ticks, pilot.melee.landed, pilot.shock.discharges]
			)
		)
		if pilot.wheel.selected() != selected or pilot.melee.landed == 0 or cop.hp >= cop.max_hp:
			Log.error("melee_click", "the selected weapon did not hit its cop")
			get_tree().quit(1)
