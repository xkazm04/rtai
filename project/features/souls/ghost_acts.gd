class_name GhostActs
extends RefCounted
## n11 hero: tells each ghost's drawn figure (GhostDrawn) when it strikes and when it is hurt, from
## what the sim already counts: Tonnage's stomp tick and wind-up, Dent's seizes and blasts (his own
## gestures: the car does the striking), Kerf's blinks, Ohm's bolts,
## Rivet's hurt tick (the forms take his hits). Render only.


## `drawn`: Tonnage, Dent, Kerf, Ohm.
static func feed(drawn: Array[GhostDrawn], pilot: StagePilot, hurt_tick: int, tick: int) -> void:
	var seqs: PackedInt32Array = [
		pilot.hauler.stomp_tick,
		pilot.dent.seizes + pilot.dent.blasts + maxi(pilot.dent.miss_tick, 0),
		pilot.kerf.blinks,
		pilot.ohm.bolts
	]
	var windup: bool = pilot.hauler.form.windup_k() > 0.0
	for i: int in drawn.size():
		drawn[i].feed(seqs[i], hurt_tick, tick, windup and i == 0)
