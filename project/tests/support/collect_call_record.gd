class_name CollectCallRecord
extends QuestRecord
## Quest 1 (collect-call) played for real, as the quest scenario judges it: CollectCallPlay runs
## the stage (heat, Patch's payphone router, the wallet, Dock 9's waves, Mertz and the
## Robo-tazer, the torch) and the quest runtime through CollectCallWorld, with CollectCallBot
## playing Rivet. checks() is the shared contract verdict plus quest 1's own (CollectCallChecks).

var play: CollectCallPlay


## `honest` false: the bot never tries a phone while hot; `torches` false: never torches.
static func played(honest: bool = true, torches: bool = true) -> CollectCallRecord:
	var r: CollectCallRecord = CollectCallRecord.new()
	r.play = CollectCallPlay.play(honest, torches)
	r.system = r.play.system
	r.events = r.play.events
	r.report = r.play.report
	r.pkg = r.play.pkg
	r.ticks = r.play.ticks
	r.final_hash = r.play.final_hash
	return r


func checks() -> Dictionary[String, bool]:
	var out: Dictionary[String, bool] = contract_checks()
	out.merge(CollectCallChecks.of(play))
	return out


func cash() -> int:
	return play.stage.wallet.cash - play.cash_before


## What is still not the game: F-12b's stub play stood in for nine systems; the real stage
## replaced heat, the payphones, the combat, Mertz, Gloria, the torch and the payout.
func stubbed() -> Array[String]:
	return [
		(
			"places: an invented arena in metres (data/tables/collect_call_places.json,"
			+ " collect_call_stage.json), not the city; no collisions (Rivet walks through walls)"
		),
		(
			"madness: whisper bursts are cued by beats and story moments (the b1 hide cue, the"
			+ " tazer hit, the fire, Kilohm's line) and the band is fixed 'crowded'; there is no"
			+ " madness system yet"
		),
		(
			"input (bot scenario only): CollectCallBot sets StageIntent directly; the bound input"
			+ " path is scenario_quest1_input (StagePilot through LiveInput)"
		),
	]


func world_doc() -> String:
	return (
		"boot/collect_call (CollectCallStage + CollectCallWorld on the real features; the guards"
		+ " and Mertz are CombatArena data, not hero nodes: DEVIATION ARC-11)"
	)


func extra() -> Dictionary:
	return {
		"beats": play.beats,
		"cashBefore": play.cash_before,
		"cashAfter": play.stage.wallet.cash,
		"patchRefusals": play.stage.router.refusals,
		"kills": play.stage.arena.kills,
		"tazerHits": play.stage.arena.tazer_hits,
		"riflesGrabbed": play.stage.arena.rifles_grabbed,
		"deaths": play.stage.deaths,
	}


func release() -> void:
	play.release()
