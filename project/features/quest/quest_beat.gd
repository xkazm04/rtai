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
## Meet verbs: the actor tags the target lists ("Juno, Brass, Dr. Kilohm, Don Fax").
var targets: Array[String] = []
## Evade verbs whose target ends at a payphone ("heat 3 to 0, then answer the payphone").
var then_answer: bool = false


## "A, B and C" -> ["A", "B", "C"].
static func split_targets(text: String) -> Array[String]:
	var out: Array[String] = []
	for part: String in text.replace(" and ", ",").split(","):
		var tag: String = part.strip_edges()
		if tag != "":
			out.append(tag)
	return out


## True when any word of `text` is one of `words` (whole words, QuestFailRule.words_of).
static func names_answer(text: String, words: Array[String]) -> bool:
	for word: String in QuestFailRule.words_of(text):
		if words.has(word):
			return true
	return false
