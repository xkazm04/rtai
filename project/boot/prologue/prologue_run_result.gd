class_name PrologueRunResult
extends RefCounted


static func collect(
	stage: ArenaStage, encounter: PrologueEncounter, seed_value: int, ticks: int
) -> Dictionary:
	var lines: PrologueLines = encounter.lines
	var street: PrologueStreet = encounter.street
	var result: Dictionary = {
		"schema": "gtai.prologue-run/1",
		"seed": seed_value,
		"lines_shown": lines.shown,
		"line_events": lines.events,
		"owner_calls": lines.owner_calls,
		"beats_reached": lines.beats,
		"beat_checkpoints": encounter.spans,
		"deaths": encounter.deaths + int(not stage.arena.rivet.alive()),
		"prompts": encounter.prompts.history,
		"wave_one":
		encounter.wave_one if encounter.done_tick >= 0 else encounter.wave_one_result(stage),
		"ticks": ticks,
		"call_answered": street.answered_tick >= 0,
		"channel_accepted": street.accepted_tick >= 0,
		"ended": street.end_tick >= 0,
	}
	if encounter.dale_died >= 0:
		result["dale_died_tick"] = encounter.dale_died
	if encounter.done_tick >= 0:
		_battle(result, encounter, stage)
	if street.answered_tick >= 0:
		result["call_answered_tick"] = street.answered_tick
	if street.accepted_tick >= 0:
		result["channel_accepted_tick"] = street.accepted_tick
	if street.end_tick >= 0:
		result["end_tick"] = street.end_tick
	return result


static func _battle(result: Dictionary, encounter: PrologueEncounter, stage: ArenaStage) -> void:
	result["wave_one_cleared_tick"] = encounter.done_tick
	var battle: PrologueBattle = encounter.battle
	var down: bool = (
		encounter.phase == PrologueEncounter.Phase.BEAT_TWO and not stage.arena.rivet.alive()
	)
	result["beat_two_deaths"] = battle.deaths + int(down)
	result["mulroney_orders"] = battle.orders
	result["shotgun_shot_ticks"] = battle.fire.shotgun.shot_ticks
	if battle.pistol.picked_tick >= 0:
		result["pistol_picked_tick"] = battle.pistol.picked_tick
	if battle.died_tick >= 0:
		result["pistol_left"] = battle.pistol.left
		result["mulroney_died_tick"] = battle.died_tick
		result["mulroney_fell_last"] = not battle.formation.men_standing()
		result["wave_two_cleared_tick"] = battle.died_tick
