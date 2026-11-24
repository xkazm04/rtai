class_name BondFilmLog
extends ArenaHook
## Read-only: logs each ghost's bond edges, each release's kills and each ghost entry with the
## sim tick and the drawn frame, so the cut of the film can be found without watching it.

var _ready_logged: Dictionary[StringName, bool] = {}
var _mastered_logged: Dictionary[StringName, bool] = {}
var _history: int = 0


func step(stage: ArenaStage, tick: int) -> void:
	var ghosts: GhostPilot = stage.pilot.ghosts
	var forms: GhostForms = ghosts.forms
	for id: StringName in forms.table.order:
		if forms.bond.ready(id) and not _ready_logged.has(id):
			_ready_logged[id] = true
			_log(tick, "bond full %s" % id)
		if forms.bond.mastered(id) and not _mastered_logged.has(id):
			_mastered_logged[id] = true
			_log(tick, "mastered %s" % id)
	if ghosts.deploy.strike.release_tick == tick:
		var strike: GhostDeployStrike = ghosts.deploy.strike
		var bond: float = forms.bond.value(strike.release_form)
		_log(
			tick,
			(
				"release %s kills=%d stuns=%d bond=%.0f"
				% [strike.release_form, strike.release_kills, strike.release_stuns, bond]
			)
		)
	for i: int in range(_history, forms.history.size()):
		var entry: Array = forms.history[i]
		_log(tick, "%s %s" % [entry[0], entry[2]])
	_history = forms.history.size()


func _log(tick: int, what: String) -> void:
	Log.info("bond-film", "tick=%d frame=%d %s" % [tick, Engine.get_frames_drawn(), what])
