class_name GauntletWaveStats
extends RefCounted
## The interval starts just after spawning and includes the tick of the last hit.

var _rolling: bool
var _rolls: int
var _dash_start: int
var _forms: Dictionary[StringName, int] = {}
var _shots: int
var _damage: float
var _deflects: int
var _deploys: GhostDeployTally = GhostDeployTally.new()


func begin(stage: ArenaStage) -> void:
	PlayerMotionDashStats.begin(stage)
	_dash_start = stage.get_meta(PlayerMotionDashStats.BASELINE)
	stage.arena.move_tally.begin_wave()
	_deploys.begin(stage.tick)
	_rolling = stage.pilot.motion.roll_progress() > 0.0
	_rolls = 0
	_forms.clear()
	_shots = stage.shots_fired
	_damage = stage.telemetry.damage_taken
	if stage.pilot.guard != null:
		_deflects = stage.pilot.guard.deflects


func sample(stage: ArenaStage) -> void:
	_deploys.sample(stage)
	var rolling: bool = stage.pilot.motion.roll_progress() > 0.0
	if rolling and not _rolling:
		_rolls += 1
	_rolling = rolling
	var form: StringName = stage.pilot.ghosts.forms.form_id()
	if form == GhostForms.BASE:
		form = &"rivet"
	var ticks: int = _forms.get(form, 0)
	_forms[form] = ticks + 1


func finish(stage: ArenaStage, row: Dictionary) -> void:
	# A later wave may have opened before this one closed.
	stage.set_meta(PlayerMotionDashStats.BASELINE, _dash_start)
	PlayerMotionDashStats.finish(stage, row)
	row["rolls"] = _rolls
	row["shots"] = stage.shots_fired - _shots
	row["damage_taken"] = stage.telemetry.damage_taken - _damage
	row["self_damage"] = RivetSelfBlast.finish_wave(stage.arena)
	var seconds: Dictionary[String, float] = {}
	for form: StringName in _forms:
		seconds[String(form)] = roundf(_forms[form] * SimClock.TICK_DT * 100.0) / 100.0
	row["form_seconds"] = seconds
	append_guard_deflects(stage, row)
	stage.arena.move_tally.append_wave(row)
	_deploys.append_wave(row)


func append_guard_deflects(stage: ArenaStage, row: Dictionary) -> void:
	if stage.pilot.guard != null:
		row["guard_deflects"] = stage.pilot.guard.deflects - _deflects


func collect_pilot(pilot: GauntletPilot, row: Dictionary) -> void:
	var counters: Dictionary = pilot.wave_counters()
	if not row.has("rolls") and counters.has("rolls"):
		var count: Variant = counters["rolls"]
		if count is int or count is float:
			var value: float = count
			if is_finite(value) and value >= 0.0 and value == floorf(value):
				row["rolls"] = int(value)
	if not row.has("form_seconds") and counters.get("form_seconds") is Dictionary:
		var form_times: Dictionary = counters["form_seconds"]
		var seconds: Dictionary[String, float] = {}
		for form: Variant in form_times:
			var elapsed: Variant = form_times[form]
			if (form is String or form is StringName) and (elapsed is int or elapsed is float):
				var value: float = elapsed
				var id: String = form
				if (
					is_finite(value)
					and value >= 0.0
					and id.is_valid_ascii_identifier()
					and id.to_lower() == id
					and not id.begins_with("_")
				):
					seconds[id] = value
		row["form_seconds"] = seconds
	pilot.reset_wave_counters()
