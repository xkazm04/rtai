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


## How far a reaction's slide (a death's carry) has moved actor `actor_id`'s drawn body off its sim
## point, in metres (zero without a full rig or a reaction). GunFxFollow's body_off.
static func metres(actor_id: int, rigs: CharacterRigs) -> Vector2:
	var rig: CutRig = rigs.rig_for(actor_id) if rigs != null else null
	if rig == null or rig.react == null:
		return Vector2.ZERO
	return rig.react.last_carry / SimConst.PX_PER_M


## metres() over `rigs` as a Callable(actor_id) -> Vector2 (GunFxFollow.body_off).
static func hook(rigs: CharacterRigs) -> Callable:
	return func(actor_id: int) -> Vector2: return metres(actor_id, rigs)
