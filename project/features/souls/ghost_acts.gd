class_name GhostActs
extends RefCounted
## n11 hero: tells each ghost's drawn figure (GhostDrawn) when it strikes and when it is hurt, from
## what the sim already counts: Tonnage's stomp tick and wind-up, Dent's seizes and blasts (his own
## gestures: the car does the striking; n15 his arm jab with no car, its wind-up in the wind-up
## column), Kerf's blinks and Rivet's hurt tick (the forms take his hits). Render only.


## Feed the delayed cast before the rig poses, so the releasing electrode and bolt agree.
static func prepare_ohm(rig: OhmRig, o: OhmStage, rivet: Fighter, tick: int) -> void:
	rig.ohm = o
	rig.bolts = o.bolts
	if o.cast.delay_ticks > 0:
		rig.drawn.blow = rivet.hurt_dir
		rig.drawn.feed(o.bolts, rivet.hurt_tick, tick, o.cast.due_tick >= 0, o.bolt_tick)


## `drawn`: Tonnage, Dent, Kerf, Ohm. The instant cast retains its original pose timing.
static func feed(drawn: Array[GhostDrawn], pilot: StagePilot, rivet: Fighter, tick: int) -> void:
	var seqs: PackedInt32Array = [
		pilot.hauler.stomp_tick,
		(
			pilot.dent.seizes
			+ pilot.dent.blasts
			+ maxi(pilot.dent.miss_tick, 0)
			+ pilot.ghosts.jab.swings
		),
		pilot.kerf.blinks
	]
	var windups: Array[bool] = [
		pilot.hauler.form.windup_k() > 0.0, pilot.ghosts.jab.winding(), false
	]
	for i: int in seqs.size():
		drawn[i].feed(seqs[i], rivet.hurt_tick, tick, windups[i])
		drawn[i].blow = rivet.hurt_dir
	drawn[1].jab = jabbing(pilot.ghosts.jab)
	if pilot.ohm.cast.delay_ticks == 0:
		drawn[3].feed(pilot.ohm.bolts, rivet.hurt_tick, tick)
		drawn[3].blow = rivet.hurt_dir


## True while Dent's arm jab winds up or plays its strike and recoil (the act phases' length).
static func jabbing(jab: DentJab) -> bool:
	var since: int = jab.steps - jab.swung_step
	var shown: int = GhostDrawn.CUT_TICKS + GhostDrawn.FOLLOW_TICKS
	return jab.winding() or (jab.swung_step >= 0 and since < shown)
