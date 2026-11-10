class_name GhostActs
extends RefCounted
## n11 hero: tells each ghost's drawn figure (GhostDrawn) when it strikes and when it is hurt, from
## what the sim already counts: Tonnage's stomp tick and wind-up, Dent's seizes and blasts (his own
## gestures: the car does the striking; n15 his arm jab with no car, its wind-up in the wind-up
## column), Kerf's blinks, Ohm's bolts,
## Rivet's hurt tick (the forms take his hits). Render only.


## `drawn`: Tonnage, Dent, Kerf, Ohm; `rivet` the body the forms wear (its last hit and blow).
static func feed(drawn: Array[GhostDrawn], pilot: StagePilot, rivet: Fighter, tick: int) -> void:
	var seqs: PackedInt32Array = [
		pilot.hauler.stomp_tick,
		(
			pilot.dent.seizes
			+ pilot.dent.blasts
			+ maxi(pilot.dent.miss_tick, 0)
			+ pilot.ghosts.jab.swings
		),
		pilot.kerf.blinks,
		pilot.ohm.bolts
	]
	var windups: Array[bool] = [
		pilot.hauler.form.windup_k() > 0.0, pilot.ghosts.jab.winding(), false, false
	]
	for i: int in drawn.size():
		drawn[i].feed(seqs[i], rivet.hurt_tick, tick, windups[i])
		drawn[i].blow = rivet.hurt_dir
