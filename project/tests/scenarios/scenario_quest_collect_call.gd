extends Scenario
## F-12b exit: the owner-approved first contract, collect-call (project/quests/, gtai.quest/1,
## copied verbatim from PoF), plays headless to completion on the real World + SimLoop through
## the quest runtime: all six beats (evade, answer, meet, fight, sabotage, evade at a payphone),
## every beat line and all ten barks, the heat clamp at heatPeak 3, $1500 and the five unlocks,
## one contract_started and one contract_completed. The places and every missing world system
## are STUBS, named one by one in the evidence's `stubbed` list (CollectCallScript.stubbed()):
## heat, payphones, madness whispers, the Dock 9 waves and Mertz, Gloria's handover, the torch,
## movement. A second play is bit-identical, and the planted fault (the crates never burn) is
## caught (TST-05). Leaves quest-collect-call.json in --evidence-dir for PoF.

const EVIDENCE_FILE: String = "quest-collect-call.json"


func run(_tree: SceneTree) -> String:
	var plays: Array[QuestPlay] = [
		QuestPlay.collect_call(true), QuestPlay.collect_call(true), QuestPlay.collect_call(false)
	]
	var verdict: QuestVerdict = QuestVerdict.judge(
		plays[0], plays[1], plays[2], "the crates are never torched"
	)
	var write_error: String = write_evidence(EVIDENCE_FILE, verdict.evidence(QuestFixture.CC_ID))
	Log.info("scenario", verdict.summary(QuestFixture.CC_ID))
	for p: QuestPlay in plays:
		p.release()
	return verdict.reason if verdict.reason != "" else write_error
