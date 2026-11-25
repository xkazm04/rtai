extends Node
## n31 melee 01b: the gauntlet's headless run with the bot holding ONE melee weapon. Writes one
## result json per (weapon, seed). Read-only over the game's rules: the before of the hit-rule item.
## --weapon=claw|chainsaw|electro_baton|katana|plasma_sword --seed=N --waves=N --result=<abs json>

const KNOWN_FLAGS: PackedStringArray = [
	"--weapon", "--seed", "--waves", "--result", "--bot", "--pick", "--melee-sweep"  # n31 02: MeleeHit
]
const RUN_TICKS: int = 216000
const WEAPONS: PackedStringArray = ["claw", "chainsaw", "electro_baton", "katana", "plasma_sword"]


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	for flag: String in args.values:
		if not KNOWN_FLAGS.has(flag):
			Log.error("play_baseline", "unknown flag %s" % flag)
			get_tree().quit(2)
			return
	var weapon: String = args.text("--weapon", "claw")
	if weapon not in WEAPONS:
		Log.error("play_baseline", "unknown weapon %s" % weapon)
		get_tree().quit(2)
		return
	get_tree().quit(_run(args, StringName(weapon)))


func _run(args: ArenaArgs, weapon: StringName) -> int:
	var run: GauntletRun = GauntletRun.new()
	run.seed = args.text("--seed", "1").to_int()
	run.profile = StringName(args.text("--bot", "average"))
	run.controls = &"wheel"
	var pilot: PlayBaselinePilot = PlayBaselinePilot.new()
	pilot.blade = weapon != &"claw"
	var session: GauntletSession = GauntletSession.open_street(Events, Data, run, pilot)
	if session == null:
		return 1
	pilot.configure(run.profile, StringName(args.text("--pick", "greedy")), run.seed)
	pilot.bind(run, session)
	var waves: GauntletWaves = GauntletWaves.attach(
		session, run, pilot, args.text("--waves", "4").to_int()
	)
	var hook: PlayBaselineHook = PlayBaselineHook.new()
	hook.weapon = weapon
	session.stage.hooks.append(hook)
	while not waves.done and session.tick() < RUN_TICKS:
		session.step()
	var row: Dictionary = _row(run, session, hook, weapon, waves.done)
	var tick: int = session.tick()
	row["ticks"] = tick
	session.close()
	return 0 if _write(args.text("--result"), row) and waves.done else 1


func _row(
	run: GauntletRun,
	session: GauntletSession,
	hook: PlayBaselineHook,
	weapon: StringName,
	done: bool
) -> Dictionary:
	var melee: Dictionary = hook.melee_totals(session.stage)
	var own: Dictionary = melee.get(String(weapon), {"swings": 0, "landed": 0, "whiffs": 0})
	var kills_own: int = hook.kills_by_weapon.get(weapon, 0)
	return {
		"schema": "gtai.play-baseline-run/1",
		"weapon": String(weapon),
		"seed": run.seed,
		"finished": done,
		"alive": run.alive,
		"wave_reached": run.wave,
		"death": String(run.death_by) if not run.alive else "",
		"swings": own.swings,
		"hits": own.landed,
		"whiffs": own.whiffs,
		"kills_own_weapon": kills_own,
		"kills_all": hook.kills,
		"kills_by_weapon": hook.kills_by_weapon,
		"damage_taken": snappedf(hook.damage_taken, 0.001),
		"melee_all": melee,
	}


func _write(path: String, row: Dictionary) -> bool:
	if path.is_empty():
		Log.info("play_baseline", JSON.stringify(row))
		return true
	var dir_error: Error = DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE) if dir_error == OK else null
	if file == null:
		return false
	var ok: bool = file.store_string(JSON.stringify(row, "  ", true) + "\n")
	file.close()
	return ok
