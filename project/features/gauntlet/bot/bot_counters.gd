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
