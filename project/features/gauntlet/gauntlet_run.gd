class_name GauntletRun
extends RefCounted
## Run state shared with the pilot. A wave row contains only counters its observer measured.

const SCHEMA: String = "gtai.gauntlet-run/1"

var seed: int = 0
var wave: int = 0
var picks: Array[Dictionary] = []
var mods: StatMods = StatMods.new()
var alive: bool = true
var capped: bool = false
var death_wave: int = -1
var profile: StringName = &"human"
var controls: StringName = &"legacy"
var waves: Array[Dictionary] = []
var death_by: StringName = &"unknown"


func begin_wave(enemies: Dictionary) -> void:
	wave += 1
	waves.append({"n": wave, "enemies": enemies})


func to_result() -> Dictionary:
	var result: Dictionary = {
		"schema": SCHEMA,
		"seed": seed,
		"profile": String(profile),
		"controls": String(controls),
		"wave_reached": wave,
		"waves": waves.duplicate(true),
		"picks": picks.duplicate(true),
		"mods": mods.to_dict(),
	}
	if capped:
		result["capped"] = true
	if not alive:
		result["death"] = {
			"wave": death_wave if death_wave >= 0 else wave,
			"by": String(death_by) if death_by != &"" else "unknown"
		}
	return result
