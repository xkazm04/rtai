class_name KillSprawlCut
extends RefCounted
## The electro corpse (lane brutality, showcase REQUEST 29): a whole-body cut of the victim's rig
## posed in human-reactions' shock death (DeathPose._shock's end: c_sprawl 1.05, hands down, dead),
## so the stiff drop lands in the same plank as every other corpse instead of a stretched standing
## copy. The rig is posed only for the copy: every node transform it touches is put back after.
## Render only: never sim state, no RNG.

## DeathPose._shock's end pose (1.05 sprawl at fall = 1).
const SPRAWL: float = 1.05


## The BODY group of the rig cut in the death sprawl (centred on its parts, in the rig parent's px).
static func cut(rig: CutRig) -> Node2D:
	var saved: Dictionary[Node2D, Transform2D] = {}
	_save(rig, saved)
	var keep: Array = [
		rig.c_sprawl, rig.c_hands_up, rig.c_tuck, rig.dead, rig.aiming, rig.speed_now
	]
	rig.c_sprawl = SPRAWL
	rig.c_hands_up = 0.0
	rig.c_tuck = 0.0
	rig.dead = true
	rig.aiming = false
	rig.speed_now = 0.0
	RigPose.step(rig)
	var groups: Array[Node2D] = GibCut.cut(rig, true)
	var out: Node2D = groups[SignatureKill.BODY]
	for g: Node2D in groups:
		if g != out:
			g.free()  # only the body is kept (the cap rides on it already)
	rig.c_sprawl = keep[0]
	rig.c_hands_up = keep[1]
	rig.c_tuck = keep[2]
	rig.dead = keep[3]
	rig.aiming = keep[4]
	rig.speed_now = keep[5]
	for n: Node2D in saved:
		n.transform = saved[n]
	return out


static func _save(n: Node, saved: Dictionary[Node2D, Transform2D]) -> void:
	for ch: Node in n.get_children():
		if ch is Node2D:
			saved[ch as Node2D] = (ch as Node2D).transform
		_save(ch, saved)
