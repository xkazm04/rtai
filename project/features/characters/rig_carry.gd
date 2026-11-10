class_name RigCarry
extends RefCounted
## n11 (the owner: "Bodies often lag and move across the screen"): a death's slide lives in the rig
## node's position, added in HumanReact.pre on a pose step, and RigInput puts the rig back on its
## sim point on every tick. A rig past the full-rate ranks does not pose every tick, so its corpse
## (a child of the rig) hopped back by the whole slide and forward again. The host keeps the slide
## on a tick with no pose and replaces it on a second pose in one frame. View only.


## One pose step of `rig`; a second one in the same frame replaces the first's slide.
static func pose(rig: CutRig, posed: Dictionary[int, bool], every: int) -> void:
	if posed.has(rig.actor_id):
		undo(rig)
	rig.drive(SimClock.TICK_DT * every)
	posed[rig.actor_id] = true


## After the frame's pose steps. `new_rigs` (d9-rivet, a card view): a rig acquired on a frame that
## did not pose it (no tick due, a half-rate rank) drew its hidden parts, so it poses now. The rigs
## this frame did not pose keep their slide.
static func finish(
	rigs: Dictionary[int, CutRig], posed: Dictionary[int, bool], new_rigs: bool
) -> void:
	for actor: int in rigs:
		if new_rigs and rigs[actor].t_alive == 0.0:
			pose(rigs[actor], posed, 1)
		elif not posed.has(actor):
			keep(rigs[actor])


## Puts the last slide back on a rig that RigInput moved to its sim point and no pose step will.
static func keep(rig: CutRig) -> void:
	if rig.react != null:
		rig.position += rig.react.last_carry


## Takes the last slide off before a second pose step in one frame adds it again.
static func undo(rig: CutRig) -> void:
	if rig.react != null:
		rig.position -= rig.react.last_carry
