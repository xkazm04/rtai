extends Node
## n31 melee 03p2: the fatality proof. The play_baseline run (average bot, ONE melee weapon held,
## waves 1..N) with the signature-kill feed installed (as --kill-feed does); every kill is recorded:
## weapon, victim archetype, human (KillEvent), finishable human (MeleeLethal), shield at death and
## what plays (the signature row id, or `generic`). Measures only: no rule changes.
## --weapon=claw|chainsaw|electro_baton|katana|plasma_sword --seed=N --waves=N --result=<abs json>

const KNOWN_FLAGS: PackedStringArray = [
	"--weapon", "--seed", "--waves", "--result", "--bot", "--pick"
]
const RUN_TICKS: int = 216000
const WEAPONS: PackedStringArray = ["claw", "chainsaw", "electro_baton", "katana", "plasma_sword"]


## The play_baseline hook (weapon hold, counts) plus a per-kill record. It connects after the
## BrutalityHook (first step), so the hook's verdict on the kill is known when it runs.
class Recorder:
	extends PlayBaselineHook

	var feed: BrutalityHook = null
	var records: Array[Dictionary] = []
	var _stage: ArenaStage = null
	var _rows: Dictionary[int, SignatureKill] = {}
	var _tick: int = 0

	func step(stage: ArenaStage, tick: int) -> void:
		_tick = tick
		if _stage == null:
			_stage = stage
			@warning_ignore("return_value_discarded")
			feed.kills.killed.connect(_on_signature)
		super.step(stage, tick)

	func _on_signature(
		victim_id: int, _serial: int, row: SignatureKill, _at: Vector2, _dir: Vector2
	) -> void:
		_rows[victim_id] = row

	func _killed(
		victim: Fighter, by: StringName, dir: Vector2, at: Vector2, kind: StringName
	) -> void:
		super._killed(victim, by, dir, at, kind)
		var row: SignatureKill = _rows.get(victim.id)
		@warning_ignore("return_value_discarded")
		_rows.erase(victim.id)
		var plays: String = "generic"
		if row != null:
			plays = String(row.id) + ("" if row.victim.is_empty() else ":" + String(row.victim))
		var e: KillEvent = KillEvent.of_fighter(victim, dir, by)
		(
			records
			. append(
				{
					"tick": _tick,
					"weapon": String(by),
					"archetype": String(victim.archetype),
					"fighter_kind": str(Fighter.Kind.keys()[victim.kind]).to_lower(),
					"body_class": String(victim.body_class),
					"human": e.human,
					"finishable": MeleeLethal.human(victim),
					"named": victim.get_meta(MeleeLethal.NAMED, false) == true,
					"brain_owned": victim.brain_owned,
					"machine": victim.machine,
					"kill_kind": String(kind),
					"shield": _shield(victim, dir),
					"plays": plays,
				}
			)
		)

	## `none` (no shield in his roster row), `front` (the killing blow came into the shield's
	## face: the saw went through it) or `flank` (the blow came round it).
	func _shield(victim: Fighter, dir: Vector2) -> String:
		var squad: ArenaSquad = _stage.arena.squad_ai
		var arch: EnemyRoster.Archetype = (
			squad.pit.roster.archetype(victim.archetype) if squad != null else null
		)
		if arch == null or arch.shield_front_mult >= 1.0:
			return "none"
		var d: Vector2 = dir.normalized() if dir != Vector2.ZERO else Vector2.ZERO
		return "front" if victim.facing.dot(-d) > arch.shield_cos else "flank"


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	for flag: String in args.values:
		if not KNOWN_FLAGS.has(flag):
			Log.error("fatality_probe", "unknown flag %s" % flag)
			get_tree().quit(2)
			return
	var weapon: String = args.text("--weapon", "claw")
	if weapon not in WEAPONS:
		Log.error("fatality_probe", "unknown weapon %s" % weapon)
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
	if session.kills_hook == null:  # what --kill-feed installs, right after the street
		@warning_ignore("return_value_discarded")
		session.install_kills()
	pilot.configure(run.profile, StringName(args.text("--pick", "greedy")), run.seed)
	pilot.bind(run, session)
	var waves: GauntletWaves = GauntletWaves.attach(
		session, run, pilot, args.text("--waves", "4").to_int()
	)
	var hook: Recorder = Recorder.new()
	hook.weapon = weapon
	hook.feed = session.kills_hook
	session.stage.hooks.append(hook)
	while not waves.done and session.tick() < RUN_TICKS:
		session.step()
	var row: Dictionary = {
		"schema": "gtai.fatality-probe-run/1",
		"weapon": String(weapon),
		"seed": run.seed,
		"finished": waves.done,
		"alive": run.alive,
		"wave_reached": run.wave,
		"ticks": session.tick(),
		"kills_all": hook.kills,
		"telemetry": session.kills_hook.telemetry(),
		"records": hook.records,
	}
	session.close()
	return 0 if _write(args.text("--result"), row) else 1


func _write(path: String, row: Dictionary) -> bool:
	if path.is_empty():
		Log.info("fatality_probe", JSON.stringify(row))
		return true
	var dir_error: Error = DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE) if dir_error == OK else null
	if file == null:
		return false
	var ok: bool = file.store_string(JSON.stringify(row, "  ", true) + "\n")
	file.close()
	return ok
