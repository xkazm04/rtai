class_name QuestBeat
extends RefCounted
## One gtai.quest/1 beat (PoF types.ts QuestBeat + QuestObjective) as the runtime holds it: the
## objective verb resolved to its handler, the target and location tags, the timed length in
## ticks (timer verbs only) and the ids of the lines spoken when the beat starts.

var id: String = ""
var title: String = ""
var title_key: StringName = &""
var verb: String = ""
var handler: QuestRules.Handler = QuestRules.Handler.REACH
## Omitted in the package -> "" (the contract's "not applicable").
var target: String = ""
var location: String = ""
## Timer verbs: objective.durationS wins, then the legacy "<N>s" target, then the rules default.
var length_ticks: int = 0
var line_ids: Array[String] = []
