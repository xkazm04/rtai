extends "res://dev/test_player/gauntlet_bot_film.gd"
## n31 ghost take (dev only): the gauntlet bot film with Tonnage granted from the start the way
## GhostN31Play does (its unlock id is the only GhostLocks.done entry, selected every tick), so the
## shipped bot drops it whenever it is ready. Every Tonnage release is logged (press, dump, wave,
## hits, kills, foes near, frame drawn) through GhostN31Strike, which runs the real strike.
## Flags: the gauntlet's own, plus --deploys=<abs.json> (the release rows) and --from=<tick>
## (windowed only: step the sim headless to that tick before the view opens, so a write-movie
## starts near the filmed deploys; bodies and stains of earlier kills are then not drawn).
## --form=<tonnage|ohm|dent|kerf> grants and logs that form instead (default tonnage);
## --fit=relaxed swaps the bot's spot scorer for GhostN31BotSpot (Ohm at 3+ bodies, Kerf at
## any target).

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
	"--from",
	"--deploys",
	"--form",
	"--fit"
]
const FORMS: Dictionary = {
	"tonnage": HaulerStage.GHOST,
	"ohm": OhmStage.GHOST,
	"dent": DentStage.GHOST,
	"kerf": KerfStage.GHOST
}

var _from: int = 0
var _deploys_path: String = ""
var _form: StringName = HaulerStage.GHOST
var _relaxed: bool = false
var _ghost: GhostDeploy
var _strike: GhostN31Strike
var _logged: int = 0
var _written: bool = false


func _invalid_arg(args: ArenaArgs) -> String:
	if args.has("--from"):
		var from: String = args.text("--from")
		if not from.is_valid_int() or from.to_int() < 0:
			return "--from=%s" % from
		_from = from.to_int()
	if args.has("--deploys"):
		_deploys_path = args.text("--deploys")
		if not _deploys_path.is_absolute_path():
			return "--deploys=%s" % _deploys_path
	_form = FORMS.get(args.text("--form", "tonnage"), &"")
	if _form == &"":
		return "--form=%s" % args.text("--form")
	_relaxed = args.text("--fit", "shipped") == "relaxed"
	if not _relaxed and args.text("--fit", "shipped") != "shipped":
		return "--fit=%s" % args.text("--fit")
	for own: String in ["--from", "--deploys", "--form", "--fit"]:
		@warning_ignore("return_value_discarded")
		args.values.erase(own)
	return super._invalid_arg(args)


func _open_street(args: ArenaArgs) -> GauntletSession:
	var opened: GauntletSession = super._open_street(args)
	if opened != null:
		_ghost = opened.stage.pilot.ghosts.deploy
		_strike = GhostN31Strike.new(_ghost.strike.attacks, _ghost.strike.press)
		_strike.form = _form
		_ghost.strike = _strike
	return opened


func _run_headless() -> void:
	_install_fit()
	while not waves.done and session.tick() < RUN_TICKS:
		_step_once()
	super._run_headless()


func _open_view(film: bool) -> void:
	_install_fit()
	while session.tick() < _from and not waves.done:
		_step_once()
	if _from > 0:
		Log.info("ghost-take", "stepped headless to tick %d before the view" % session.tick())
	super._open_view(film)


func _physics_process(_delta: float) -> void:
	if session == null or waves.done or not waves.pending.is_empty():
		super._physics_process(SimClock.TICK_DT)
		return
	_grant()
	var before: GhostDeploy.Phase = _ghost.phase
	super._physics_process(SimClock.TICK_DT)
	if session != null:
		_after_step(before)


func _finish() -> bool:
	_write_deploys()
	return super._finish()


func _step_once() -> void:
	_grant()
	var before: GhostDeploy.Phase = _ghost.phase
	session.step()
	_after_step(before)


## After the bot is bound (its brain exists): --fit=relaxed swaps in the dev spot scorer.
func _install_fit() -> void:
	if _relaxed and (pilot == null or not GhostN31BotSpot.install(pilot)):
		Log.error("ghost-take", "--fit=relaxed: cannot install GhostN31BotSpot")


func _grant() -> void:
	var forms: GhostForms = session.stage.pilot.ghosts.forms
	if forms.locks.done.size() != 1 or forms.locks.done[0] != _form:
		forms.locks.done.clear()
		forms.locks.done.append(_form)
	forms.selected = _form


func _after_step(before: GhostDeploy.Phase) -> void:
	# Key down: AIMING on main's hold flow, ACTIVE at once on a drop-mode press.
	if before == GhostDeploy.Phase.IDLE and _ghost.phase != GhostDeploy.Phase.IDLE:
		_strike.press_tick = session.stage.tick
		_strike.press_rivet = session.stage.arena.rivet.pos
	while _logged < _strike.deploys.size():
		var row: Dictionary = _strike.deploys[_logged]
		_logged += 1
		row.n = _logged
		row.wave = run.wave
		row.press_tick = _strike.press_tick
		row.frame = Engine.get_frames_drawn()
		Log.info(
			"ghost-take",
			(
				"deploy %d press=%d dump=%d wave=%d hits=%d kills=%d near=%d frame=%d"
				% [
					row.n,
					row.press_tick,
					row.tick,
					row.wave,
					row.hits,
					row.kills,
					row.near,
					row.frame
				]
			)
		)


func _write_deploys() -> void:
	if _written or _deploys_path.is_empty() or _strike == null:
		return
	_written = true
	var out: Dictionary = {
		"schema": "gtai.ghost-n31-take/1",
		"seed": run.seed,
		"profile": String(run.profile),
		"form": String(_form),
		"fit": "relaxed" if _relaxed else "shipped",
		"from": _from,
		"deploys": _strike.deploys,
	}
	var dir_error: Error = DirAccess.make_dir_recursive_absolute(_deploys_path.get_base_dir())
	var file: FileAccess = null
	if dir_error == OK:
		file = FileAccess.open(_deploys_path, FileAccess.WRITE)
	if file == null or not file.store_string(JSON.stringify(out, "  ") + "\n"):
		Log.error("ghost-take", "cannot write deploys to %s" % _deploys_path)
		return
	file.close()
