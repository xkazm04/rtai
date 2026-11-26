extends Node
## n31 melee 01b C: the before play take (gauntlet, wheel, average bot, ONE melee weapon, tilt 70)
## for tools/melee/play_take.mjs. --weapon --seed --ppm; 03p3: --frames=<json> [--frames-ticks=N].

const KNOWN_FLAGS: PackedStringArray = ["--weapon", "--seed", "--ppm", "--frames", "--frames-ticks"]

var session: GauntletSession
var waves: GauntletWaves
var run: GauntletRun = GauntletRun.new()


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var weapon: StringName = StringName(args.text("--weapon", "katana"))
	run.seed = args.text("--seed", "7").to_int()
	run.profile = &"average"
	run.controls = &"wheel"
	var pilot: PlayBaselinePilot = PlayBaselinePilot.new()
	pilot.blade = weapon != &"claw"
	session = GauntletSession.open_street(Events, Data, run, pilot)
	if session == null:
		get_tree().quit(1)
		return
	pilot.configure(run.profile, &"greedy", run.seed)
	pilot.bind(run, session)
	waves = GauntletWaves.attach(session, run, pilot, 0)
	var hook: PlayBaselineHook = PlayBaselineHook.new()
	hook.weapon = weapon
	session.stage.hooks.append(hook)
	_open_view(args.number("--ppm", 32.0))
	FightFrames.attach(self, args, session.world)


func _open_view(ppm: float) -> void:
	ViewMode.select("tilt70")
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_window().size = Vector2i(1920, 1080)
	add_child(session.world)
	var view: GauntletView = GauntletView.new(session.street)
	view.px_per_m = ppm
	view.bind(session.stage, CollectCallWorld.new(session.stage), null)
	add_child(view)
	view.hud_view.visible = false
	var hud: GauntletHud = GauntletHud.new()
	hud.session = session
	hud.run = run
	hud.waves = waves
	add_child(hud)
	var cast: ArenaRigs = ArenaRigs.new()
	add_child(cast)
	@warning_ignore("return_value_discarded")
	cast.attach(session.stage, view, session.world.context())
	session.live.viewport = get_viewport()
	session.live.origin_px = func() -> Vector2: return get_viewport().get_visible_rect().size * 0.5
	session.live.px_per_m = func() -> float: return view.px_per_m
