class_name DeathPose
extends RefCounted
## The standard deaths by damage type (human_reactions.json death_*), each ending in the corpse
## pose it holds: bullet (falls back from the front, crumples forward from behind), melee (folds,
## then topples), blast (thrown along the blast, tumbling), burn (flails, collapses charred),
## shock (convulses, falls stiff). The brutality lane replaces these through DeathPipe.


static func pre(r: HumanReact, rig: CutRig) -> void:
	var k: float = r.progress()
	rig.dead = true
	rig.gun_out = false
	rig.aiming = false
	match r.kind:
		&"death_melee":
			_melee(r, rig, k)
		&"death_blast":
			_blast(r, rig, k)
		&"death_burn":
			_burn(r, rig, k)
		&"death_shock":
			_shock(r, rig, k)
		_:
			_bullet(r, rig, k)


static func _bullet(r: HumanReact, rig: CutRig, k: float) -> void:
	var e: float = ReactPose.ease_out(k)
	if r.dir.x < 0.0:  # hit from the front: thrown back
		rig.c_sprawl = smoothstep(0.0, 0.6, k)
		r.slide = r.dir * r.travel * e
	else:  # from behind: crumples forward on the spot
		rig.c_sprawl = 0.75 * smoothstep(0.1, 0.8, k)
		rig.c_tuck = 0.35 * smoothstep(0.0, 0.5, k)
		r.slide = r.dir * r.travel * 0.45 * e
	r.rot = r.side * 0.5 * absf(r.dir.y) * e
	r.head_rot = r.side * 0.4 * e


static func _melee(r: HumanReact, rig: CutRig, k: float) -> void:
	var fold: float = smoothstep(0.0, 0.35, k)
	var top: float = smoothstep(0.4, 1.0, k)
	rig.c_tuck = lerpf(0.6 * fold, 0.2, top)
	rig.c_sprawl = top
	r.slide = r.dir * r.travel * (0.3 * fold + 0.7 * top)
	r.head_off = Vector2(55.0 * fold * (1.0 - top), 0.0)
	r.rot = r.side * 0.6 * top


static func _blast(r: HumanReact, rig: CutRig, k: float) -> void:
	var e: float = ReactPose.ease_out(k)
	r.slide = r.dir * r.travel * e
	r.rot = r.side * TAU * 1.25 * e
	rig.c_sprawl = 1.25 * smoothstep(0.0, 0.5, k)
	rig.c_hands_up = 1.0 - smoothstep(0.3, 0.9, k)


static func _burn(r: HumanReact, rig: CutRig, k: float) -> void:
	var down: float = smoothstep(0.5, 0.85, k)
	ReactPose.flail(r, rig, 1.0 - down)
	rig.c_sprawl = 0.8 * down
	rig.c_tuck = 0.3 * down
	r.tint = smoothstep(0.0, 0.8, k)


static func _shock(r: HumanReact, rig: CutRig, k: float) -> void:
	var fall: float = smoothstep(0.5, 0.64, k)
	ReactPose.convulse(r, rig, 1.0 - fall)
	rig.c_sprawl = maxf(rig.c_sprawl, 1.05 * fall)
	r.scl = Vector2(1.0, 1.0 - 0.12 * fall)
	r.slide = r.dir * r.travel * fall
	if fall > 0.5:
		rig.c_hands_up = 0.0
