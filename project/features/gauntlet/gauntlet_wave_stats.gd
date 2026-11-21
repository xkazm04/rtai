class_name GauntletWaveStats
extends RefCounted
## The interval starts just after spawning and includes the tick of the last hit.

var _rolling: bool
var _rolls: int
var _forms: Dictionary[StringName, int] = {}
var _shots: int
var _damage: float


func begin(stage: ArenaStage) -> void:
	_rolling = stage.pilot.motion.roll_progress() > 0.0
	_rolls = 0
	_forms.clear()
	_shots = stage.shots_fired
	_damage = stage.telemetry.damage_taken


func sample(stage: ArenaStage) -> void:
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
	row["rolls"] = _rolls
	row["shots"] = stage.shots_fired - _shots
	row["damage_taken"] = stage.telemetry.damage_taken - _damage
	var seconds: Dictionary[String, float] = {}
	for form: StringName in _forms:
		seconds[String(form)] = roundf(_forms[form] * SimClock.TICK_DT * 100.0) / 100.0
	row["form_seconds"] = seconds
	append_guard_deflects(stage, row)


## Guard's cumulative deflect counter will supply the measured wave delta here.
func append_guard_deflects(_stage: ArenaStage, _row: Dictionary) -> void:
	pass
