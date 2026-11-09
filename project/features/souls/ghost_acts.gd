class_name GhostActs
extends RefCounted
## n11 hero: tells each ghost's drawn figure (GhostDrawn) when it strikes and when it is hurt, from
## what the sim already counts: Tonnage's stomp tick, Dent's strikes, Kerf's blinks, Ohm's bolts,
## Rivet's hurt tick (the forms take his hits). Render only.


## `drawn`: Tonnage, Dent, Kerf, Ohm.
static func feed(drawn: Array[GhostDrawn], pilot: StagePilot, hurt_tick: int, tick: int) -> void:
	var seqs: PackedInt32Array = [
		pilot.hauler.stomp_tick, pilot.dent.strikes, pilot.kerf.blinks, pilot.ohm.bolts
	]
	for i: int in drawn.size():
		drawn[i].feed(seqs[i], hurt_tick, tick)
