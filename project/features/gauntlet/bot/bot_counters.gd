class_name BotCounters
extends RefCounted
## Shots and rolls are observed sim totals. Guard and physical-cover ticks count
## input decisions. Form ticks count intervals starting in a settled ghost.

var guard_ticks: int = 0
var rolls: int = 0
var cover_ticks: int = 0
var form_ticks: Dictionary[StringName, int] = {}
var shots: int = 0
var targets_switched: int = 0


func sample_form(me: BotView.Player) -> void:
	if me.hp > 0.0 and me.settled and me.form != &"base":
		form_ticks[me.form] = form_ticks.get(me.form, 0) + 1


func observe_totals(me: BotView.Player) -> void:
	shots = me.shots_fired
	rolls = me.rolls_started


func report() -> Dictionary:
	return {
		"guard_ticks": guard_ticks,
		"rolls": rolls,
		"cover_ticks": cover_ticks,
		"form_ticks": form_ticks.duplicate(),
		"shots": shots,
		"targets_switched": targets_switched
	}


func since(before: Dictionary) -> Dictionary:
	var now: Dictionary = report()
	var out: Dictionary = {}
	for key: String in now:
		if key == "form_ticks":
			var forms: Dictionary = {}
			var earlier: Dictionary = before[key]
			for id: StringName in now[key]:
				var count: int = now[key][id] - earlier.get(id, 0)
				if count > 0:
					forms[id] = count
			out[key] = forms
		else:
			out[key] = now[key] - before[key]
	return out


## Project a completed or interrupted attempt onto the common gauntlet wave schema.
static func wave_row(attempt: Dictionary, order: Array[StringName]) -> Dictionary:
	var counts: Dictionary = attempt.counters
	var measured: Dictionary = counts.form_ticks
	var forms: Dictionary[StringName, float] = {}
	for id: StringName in order:
		var ticks: int = measured.get(id, 0)
		forms[id] = ticks * SimClock.TICK_DT
	var row: Dictionary = {
		"n": attempt.n,
		"status": attempt.status,
		"enemies": attempt.enemies,
		"damage_taken": attempt.damage_taken,
		"shots": counts.shots,
		"rolls": counts.rolls,
		"form_seconds": forms,
		"guard_ticks": counts.guard_ticks,
		"cover_ticks": counts.cover_ticks
	}
	if attempt.status != "tick_limit":
		var duration: int = attempt.end_tick - attempt.start_tick
		row.seconds = duration * SimClock.TICK_DT
	return row
