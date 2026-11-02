extends Scenario
## Quest 1 (collect-call) end to end, headless, on the real World + SimLoop: the stage composed
## from the features, the quest runtime through CollectCallWorld, and CollectCallBot playing it
## from the dumpster to "paid". Every beat in order, all 23 lines, the barks on their cues,
## Patch refusing a hot caller, 49 enemies in 6 waves, the Robo-tazer, the fire, heat 3, and
## +$1,500 exactly once. A second play is bit-identical, and the planted fault (the bot never
## tries a phone while hot) is caught by the refusal check (TST-05). Leaves collect-call.json.

const EVIDENCE_FILE: String = "collect-call.json"
const EVIDENCE_SCHEMA: String = "gtai.collect-call-play/1"


func run(_tree: SceneTree) -> String:
	var first: CollectCallPlay = CollectCallPlay.play()
	var again: CollectCallPlay = CollectCallPlay.play()
	var planted: CollectCallPlay = CollectCallPlay.play(false)
	var caught: bool = not CollectCallChecks.of(planted)["patchRefusedHot"]
	var checks: Dictionary[String, bool] = CollectCallChecks.of(first)
	var reason: String = ""
	for name: String in checks:
		if not checks[name] and reason == "":
			reason = "check %s failed" % name
	var identical: bool = (
		first.final_hash == again.final_hash and first.events.lines() == again.events.lines()
	)
	if reason == "" and not identical:
		reason = "a second play diverged (hash or Events timeline)"
	if reason == "" and not caught:
		reason = "planted fault (no hot pick-up) was not caught"
	var data: Dictionary = CollectCallChecks.evidence(first, checks, reason)
	data["schema"] = EVIDENCE_SCHEMA
	data["secondPlayIdentical"] = identical
	data["planted"] = {"fault": "the bot never picks up a phone while hot", "caught": caught}
	var write_error: String = write_evidence(EVIDENCE_FILE, data)
	if reason == "":
		reason = write_error
	Log.info("scenario", CollectCallChecks.summary(first))
	for p: CollectCallPlay in [first, again, planted]:
		p.release()
	return reason
