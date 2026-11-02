extends Scenario
## F-12 exit: a gtai.quest/1 fixture (the spike's `_selftest`) plays headless to completion on
## the real World + SimLoop through the quest runtime, against a stub world (no city yet). Every
## beat, every beat line and both barks, the heat clamp, the cash and unlocks, and exactly one
## contract_started / contract_completed. A second play is bit-identical (state hash and Events
## timeline), and the planted fault (the phone is never answered) is caught (TST-05).
## Leaves quest-selftest.json in --evidence-dir for PoF.

const EVIDENCE_FILE: String = "quest-selftest.json"


func run(_tree: SceneTree) -> String:
	var plays: Array[QuestPlay] = [
		QuestPlay.selftest(true), QuestPlay.selftest(true), QuestPlay.selftest(false)
	]
	var verdict: QuestVerdict = QuestVerdict.judge(
		plays[0], plays[1], plays[2], "phone never answered"
	)
	var write_error: String = write_evidence(EVIDENCE_FILE, verdict.evidence(QuestFixture.ID))
	Log.info("scenario", verdict.summary(QuestFixture.ID))
	for p: QuestPlay in plays:
		p.release()
	return verdict.reason if verdict.reason != "" else write_error
