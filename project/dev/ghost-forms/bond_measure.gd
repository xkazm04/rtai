extends "res://dev/gauntlet/gauntlet.gd"
## The normal gauntlet runner writes its normal result. This last, read-only hook also
## logs distinct releases and entries, even when two wave intervals count the same tick.

const KNOWN: PackedStringArray = [
	"--seed", "--bot", "--pick", "--waves", "--result", "--controls", "--mastery-free"
]


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
					"stuns": strike.release_stuns,
					"boss_cuts": strike.release_boss_cuts
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
var _free_override: String = ""


## --mastery-free=0|1 overrides bond.mastery_free for this run; the parent's list does not know it.
func _invalid_arg(args: ArenaArgs) -> String:
	if args.has("--mastery-free"):
		_free_override = args.text("--mastery-free")
		@warning_ignore("return_value_discarded")
		args.values.erase("--mastery-free")
		if not _free_override in ["0", "1"]:
			return "--mastery-free=" + _free_override
	return super._invalid_arg(args)


func _run_headless() -> void:
	observer.player = pilot as GauntletTestPlayer
	if _free_override != "":
		session.pilot.ghosts.forms.table.mastery_free = _free_override == "1"
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
