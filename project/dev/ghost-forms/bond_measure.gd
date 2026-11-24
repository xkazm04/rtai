extends "res://dev/gauntlet/gauntlet.gd"
## The normal gauntlet runner writes its normal result. This last, read-only hook also
## logs distinct releases and entries, even when two wave intervals count the same tick.

const KNOWN: PackedStringArray = ["--seed", "--bot", "--pick", "--waves", "--result"]


class Observer:
	extends ArenaHook

	var player: GauntletTestPlayer
	var history_size: int
	var entries: Array[Dictionary] = []
	var releases: Array[Dictionary] = []
	var planned_ticks: Dictionary[StringName, int] = {}
	var owned_plan_ticks: Dictionary[StringName, int] = {}

	func step(stage: ArenaStage, tick: int) -> void:
		var pilot_ghosts: GhostPilot = stage.pilot.ghosts
		var forms: GhostForms = pilot_ghosts.forms
		var strike: GhostDeployStrike = pilot_ghosts.deploy.strike
		if strike.release_tick == tick:
			releases.append(
				{
					"tick": tick,
					"form": strike.release_form,
					"kills": strike.release_kills,
					"stuns": strike.release_stuns
				}
			)
		for i: int in range(history_size, forms.history.size()):
			var entry: Array = forms.history[i]
			if entry[0] == GhostForms.ENTERING or entry[0] == GhostForms.SWITCHING:
				entries.append({"tick": tick, "form": entry[2]})
		history_size = forms.history.size()
		if (stage.arena as GauntletCombat).wave_live and pilot_ghosts.settled_in(GhostForms.BASE):
			var id: StringName = player._brain._deploy._plan.target
			if id == &"":
				id = forms.selected
			planned_ticks[id] = planned_ticks.get(id, 0) + 1
			if forms.locks.allows(forms.table, id):
				owned_plan_ticks[id] = owned_plan_ticks.get(id, 0) + 1


var observer: Observer = Observer.new()


func _run_headless() -> void:
	observer.player = pilot as GauntletTestPlayer
	session.stage.hooks.append(observer)
	super._run_headless()


func _finish() -> bool:
	observer.player = null
	var sample: Dictionary = {
		"entries": observer.entries,
		"releases": observer.releases,
		"planned": observer.planned_ticks,
		"owned_plan_ticks": observer.owned_plan_ticks
	}
	Log.info("bond-observer", JSON.stringify(sample))
	return super._finish()
