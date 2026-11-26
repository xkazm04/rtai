extends "res://dev/gauntlet/gauntlet.gd"
## n31 foes: a gauntlet take for before|after films (no caption box). Headless: print the tick wave
## --take-wave first spawns. Windowed: step undrawn to --take-tick, then write --take-s seconds of
## 1920x1080 frames to --frames-out/%04d.jpg; --follow=<archetype> centres on the nearest such foe.

## KNOWN[OWN_FIRST..] are this scene's own flags; the rest pass through to the gauntlet.
const OWN_FIRST: int = 10
const KNOWN: PackedStringArray = [
	"--seed",
	"--bot",
	"--pick",
	"--waves",
	"--result",
	"--controls",
	"--pick-view",
	"--bot-salt",
	"--pick-filter",
	"--wave-timeout",
	"--take-wave",
	"--take-tick",
	"--take-s",
	"--frames-out",
	"--zoom-ppm",
	"--follow",
	"--foe-moves",
	"--stalk"
]
const FRAME: Vector2i = Vector2i(1920, 1080)
const HZ: int = 60

var _wave: int = 1
var _take_tick: int = -1
var _frames_total: int = 0
var _frames_out: String = ""
var _follow: StringName = &""
var _spawn_tick: int = -1
var _first_tick: int = -1
var _written: int = 0
var _last_tick: int = -1
var _capturing: bool = false
var _alive_peak: int = 0
var _fired_ids: Dictionary[int, bool] = {}
var _per_s: Array[Dictionary] = []
var _stalk: bool = false
var _track: StalkTrack = StalkTrack.new()


func _invalid_arg(args: ArenaArgs) -> String:
	var rest: ArenaArgs = ArenaArgs.new()
	for flag: String in args.values:
		if KNOWN.find(flag) < OWN_FIRST:
			rest.values[flag] = args.values[flag]
	for flag: String in KNOWN.slice(OWN_FIRST):
		if args.has(flag) and not TakeArgs.valid(flag, args.text(flag)):
			return "%s=%s" % [flag, args.text(flag)]
	_wave = args.text("--take-wave", "1").to_int()
	_take_tick = args.text("--take-tick", "-1").to_int()
	_frames_total = roundi(args.text("--take-s", "30").to_float() * HZ)
	_frames_out = args.text("--frames-out")
	_follow = StringName(args.text("--follow"))
	_stalk = args.has("--stalk")
	camera_ppm = args.text("--zoom-ppm", "32").to_float()
	return super._invalid_arg(rest)


func _run_headless() -> void:
	# The scout: the parent's loop, stopped on the tick the wave's first member spawns.
	while not waves.done and session.tick() < RUN_TICKS and run.wave < _wave:
		session.step()
	_note_spawn()
	_result_path = ""
	_summary("scout")
	var ok: bool = _spawn_tick >= 0
	@warning_ignore("return_value_discarded")
	_finish()
	get_tree().quit(0 if ok else 1)


func _open_view(film: bool) -> void:
	if _frames_out.is_empty() or DirAccess.make_dir_recursive_absolute(_frames_out) != OK:
		Log.error("play-take", "windowed takes need a writable --frames-out=<abs dir>")
		get_tree().quit(2)
		return
	# Stepped before the world joins the tree and with auto picks, exactly as the headless scout.
	var target: int = mini(_take_tick, RUN_TICKS) if _take_tick >= 0 else RUN_TICKS
	while not waves.done and session.tick() < target and (_take_tick >= 0 or run.wave < _wave):
		session.step()
		_note_spawn()
	super._open_view(film)
	get_window().size = FRAME
	_last_tick = session.tick()
	@warning_ignore("return_value_discarded")
	RenderingServer.frame_post_draw.connect(_on_drawn)


func _process(_delta: float) -> void:
	# A fall inside the take keeps drawing the street until the take has all its frames.
	if _frames_out.is_empty() or _written >= _frames_total:
		super._process(_delta)


func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)
	if session == null or session.tick() == _last_tick:
		return
	_last_tick = session.tick()
	_capturing = true
	_note_spawn()
	_observe()
	_aim()


func _note_spawn() -> void:
	if _spawn_tick < 0 and run.wave >= _wave:
		_spawn_tick = session.tick()


func _observe() -> void:
	var arena: CombatArena = session.stage.arena
	var squad: ArenaSquad = arena.squad_ai
	if squad == null:
		return
	var alive: int = 0
	for h: Fighter in arena.hostiles:
		if not squad.owns(h) or not h.alive():
			continue
		alive += 1
		var mind: SquadMind = squad.minds[h.id] if squad.minds.has(h.id) else null
		var shot: int = mind.agent.shot_tick if mind != null else -1
		var melee: bool = squad.pit.roster.archetype(h.archetype).weapon.melee
		if (h.swing_tick if melee else shot) == arena.tick:
			_fired_ids[h.id] = true
	_alive_peak = maxi(_alive_peak, alive)


func _bot() -> GauntletPilot:
	return StalkPilot.new() if _stalk else super._bot()


func _aim() -> void:
	if _follow == &"" or view == null:
		return
	var foe: Fighter = _track.follow(
		session.stage.arena, _follow, _capturing and _written < _frames_total
	)
	view.focus = foe.pos if foe != null else Vector2.INF
	if pilot is StalkPilot:
		(pilot as StalkPilot).target = view.focus


func _on_drawn() -> void:
	if not _capturing or _written >= _frames_total:
		return
	if _first_tick < 0:
		_first_tick = session.tick()
	var frame: Image = get_viewport().get_texture().get_image()
	var path: String = _frames_out.path_join("%04d.jpg" % (_written + 1))
	if frame == null or frame.get_size() != FRAME or frame.save_jpg(path, 0.95) != OK:
		Log.error("play-take", "frame %d failed the size or write check" % (_written + 1))
		_written = _frames_total
		get_tree().quit(1)
		return
	_written += 1
	if _written % HZ == 0 or _written == _frames_total:
		var row: Dictionary = {"alive": _alive_peak, "fired": _fired_ids.size()}
		if _follow != &"":
			row["followed"] = _track.flush(HZ)
		_per_s.append(row)
		_alive_peak = 0
		_fired_ids.clear()
	if _written == _frames_total:
		_summary("take")
		get_tree().quit(0)


func _summary(mode: String) -> void:
	var row: Dictionary = {
		"seed": run.seed,
		"wave": _wave,
		"spawn_tick": _spawn_tick,
		"first_tick": _first_tick,
		"frames": _written,
		"mode": mode,
		"wave_reached": run.wave,
		"per_s": _per_s,
	}
	Log.info("play-take", JSON.stringify(row))
