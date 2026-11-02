extends Scenario
## F-12b exit and quest 1, one scenario: the owner-approved first contract, collect-call
## (project/quests/, gtai.quest/1, copied verbatim from PoF), plays headless from the dumpster to
## "paid" on the real World + SimLoop: the stage composed from the features (heat, Patch's
## payphone router, the wallet, Dock 9's waves, Mertz and the Robo-tazer, the torch) through
## CollectCallWorld, CollectCallBot playing Rivet. All six beats in order, every line and all
## ten barks on their Events, Patch refusing a hot caller, 49 enemies in 6 waves, the heat peak,
## +$1,500 once and the five unlocks, one contract_started and one contract_completed. What is
## still not the game is named in the evidence's `stubbed` list (CollectCallRecord.stubbed()).
## A second play is bit-identical, and both planted faults are caught (TST-05): the crates are
## never torched, and the bot never tries a phone while hot. Leaves quest-collect-call.json.

const EVIDENCE_FILE: String = "quest-collect-call.json"


func run(_tree: SceneTree) -> String:
	var first: CollectCallRecord = CollectCallRecord.played()
	var again: CollectCallRecord = CollectCallRecord.played()
	var planted: Array[QuestRecord] = [
		CollectCallRecord.played(true, false), CollectCallRecord.played(false, true)
	]
	var faults: Array[String] = [
		"the crates are never torched", "the bot never picks up a phone while hot"
	]
	var verdict: QuestVerdict = QuestVerdict.judge(first, again, planted, faults)
	var write_error: String = write_evidence(EVIDENCE_FILE, verdict.evidence(QuestFixture.CC_ID))
	Log.info("scenario", verdict.summary(QuestFixture.CC_ID))
	for r: QuestRecord in [first, again] + planted:
		r.release()
	return verdict.reason if verdict.reason != "" else write_error
