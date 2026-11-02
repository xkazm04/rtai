class_name QuestPackage
extends RefCounted
## A validated gtai.quest/1 package (PoF src/lib/games/gtai-quest/types.ts QuestPackage), holding
## only what the runtime plays. Built by QuestLoader, never half-built: a package that fails
## validation yields errors and no QuestPackage. Design-only fields (logline, goal, mechanics,
## fingerprint, provenance, overrides) are PoF's and stay in the file.

const SCHEMA: String = "gtai.quest/1"
const NO_TIME_LIMIT: int = -1

var id: StringName = &""
var title: String = ""
var act: String = ""
## Speaker id -> display name.
var characters: Dictionary[String, String] = {}
var beats: Array[QuestBeat] = []
var lines: Dictionary[String, QuestLine] = {}
## Lines in package order (bark arming order).
var line_order: Array[String] = []
var reward_cash: int = 0
var unlocks: Array[String] = []
var heat_peak: int = 0
## difficulty.timeLimitS in ticks, or NO_TIME_LIMIT for `null` (no timer).
var time_limit_ticks: int = NO_TIME_LIMIT
## Fail-state words the runtime can detect -> their code (QuestRules.fail_code).
var fail_codes: Dictionary[String, StringName] = {}
## Story writes (QuestStoryWrite.var -> value), applied by the campaign layer on success.
var story_writes: Dictionary[String, Variant] = {}


func has_fail(code: StringName) -> bool:
	return fail_codes.values().has(code)


## null when the package has no such line.
func line(line_id: String) -> QuestLine:
	if not lines.has(line_id):
		return null
	return lines[line_id]


func barks() -> Array[QuestLine]:
	var out: Array[QuestLine] = []
	for line_id: String in line_order:
		if lines[line_id].is_bark():
			out.append(lines[line_id])
	return out


func speaker_name(speaker: String) -> String:
	if not characters.has(speaker):
		return speaker
	return characters[speaker]
