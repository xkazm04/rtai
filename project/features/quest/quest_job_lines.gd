class_name QuestJobLines
extends RefCounted
## When a job beat's lines are spoken (quest 1 collect-call). A meet beat holds each listed
## actor's lines until Rivet meets them; a phone beat (answer, or evade "then answer the
## payphone") holds all of its lines until Patch connects the call. Either beat ends only once
## its conversation has been spoken, so the next beat never talks over it. Other beats play
## their lines at the start, as before.


static func begin(beat: QuestBeat, lines: QuestLinePlayer, places: QuestPlaces) -> void:
	if is_call(beat):
		return
	var held: Array[String] = []
	if beat.handler == QuestRules.Handler.MEET:
		for tag: String in beat.targets:
			held.append(places.actors[tag].speaker)
	lines.play_beat(beat, held)


## The objective's verdict after the conversation rule; plays the met actors' lines.
static func gate(
	o: QuestObjective, lines: QuestLinePlayer, places: QuestPlaces, result: StringName
) -> StringName:
	for tag: String in o.newly_met:
		lines.play_speaker(o.beat, places.actors[tag].speaker)
	o.newly_met.clear()
	if result != QuestObjective.DONE:
		return result
	if is_call(o.beat) and not o.call_played:
		o.call_played = true
		lines.play_beat(o.beat)
		return QuestObjective.RUNNING
	var talks: bool = is_call(o.beat) or o.beat.handler == QuestRules.Handler.MEET
	return QuestObjective.RUNNING if talks and lines.busy() else result


static func is_call(beat: QuestBeat) -> bool:
	return beat.handler == QuestRules.Handler.ANSWER or beat.then_answer
