class_name ReactPose
extends RefCounted
## The wound families on a cutout rig (human_reactions.json): flinch, stagger, knockdown, shield,
## spin, fold, stun, burn, cover, cower. pre() writes the rig's clip envelopes for this step and the
## drawn offsets HumanReact.post() applies. Directions are rig space: r.dir is the way the blow
## travels, so the body moves along it and the head snaps with it.


static func pre(r: HumanReact, rig: CutRig) -> void:
	var k: float = r.progress()
	match r.kind:
		&"flinch":
			_flinch(r, rig, snap(k, 0.15), 1.0)
		&"cover":
			_flinch(r, rig, snap(k, 0.15), 0.5)
			r.scl = Vector2.ONE * lerpf(1.0, 0.84, snap(k, 0.1))
		&"cower":
			_cower(r, rig, k)
		&"stagger":
			_stagger(r, rig, k)
		&"knockdown":
			_knockdown(r, rig, k)
		&"shield":
			_shield(r, rig, snap(k, 0.2))
		&"spin":
			r.rot = r.side * TAU * ease_out(k)
			r.off = r.dir * r.travel * snap(k, 0.2)
			rig.c_hands_up = maxf(rig.c_hands_up, 0.5 * sin(PI * k))
			rig.gun_out = false
		&"fold":
			_fold(r, rig, snap(k, 0.25))
		&"stun":
			convulse(r, rig, 1.0 - smoothstep(0.85, 1.0, k))
		&"burn":
			flail(r, rig, 1.0 - smoothstep(0.9, 1.0, k))


## Head and torso snap away from the hit, an arm comes up; `amt` scales it (cover = half).
static func _flinch(r: HumanReact, rig: CutRig, e: float, amt: float) -> void:
	r.off = r.dir * r.travel * e * amt
	rig.twist = r.side * 0.45 * e * amt
	rig.c_hands_up = maxf(rig.c_hands_up, 0.75 * e * amt)
	r.head_rot = r.side * 0.55 * e * amt
	r.head_off = r.dir * 40.0 * e * amt


## Startled by a bang: a glance back at it, then crouches (drawn smaller from above), both
## hands over the head, the head tucked, a hop away from the shot (r.dir points away from it).
static func _cower(r: HumanReact, rig: CutRig, k: float) -> void:
	var e: float = smoothstep(0.0, 0.18, k) * (1.0 - smoothstep(0.6, 1.0, k))
	var glance: float = smoothstep(0.0, 0.08, k) * (1.0 - smoothstep(0.12, 0.3, k))
	r.off = r.dir * r.travel * e
	r.scl = Vector2.ONE * lerpf(1.0, 0.72, e)
	rig.c_hands_up = maxf(rig.c_hands_up, e)
	rig.c_tuck = maxf(rig.c_tuck, 0.45 * e)
	rig.twist = r.side * 0.3 * e
	r.head_rot = -r.side * 0.7 * glance
	r.head_off = r.dir * 30.0 * e
	r.head_s = 1.0 - 0.14 * e


## Steps back along the hit, the torso tips with it, the weapon arm drops.
static func _stagger(r: HumanReact, rig: CutRig, k: float) -> void:
	var e: float = smoothstep(0.0, 0.2, k) * (1.0 - smoothstep(0.55, 1.0, k))
	r.slide = r.dir * r.travel * smoothstep(0.0, 0.35, k) * (1.0 - smoothstep(0.7, 1.0, k))
	r.off = r.dir * 40.0 * e
	r.rot = r.side * 0.35 * e
	rig.twist = r.side * 0.3 * e
	r.head_rot = r.side * 0.45 * e
	r.head_off = r.dir * 50.0 * e
	if k < 0.8:
		rig.gun_out = false
		rig.aiming = false


## Falls along the hit, slides, lies, gets up (lie 1.4 s of the 2.2 s family).
static func _knockdown(r: HumanReact, rig: CutRig, k: float) -> void:
	var amt: float = smoothstep(0.0, 0.12, k) * (1.0 - smoothstep(0.78, 1.0, k))
	rig.dead = amt > 0.05
	rig.c_sprawl = maxf(rig.c_sprawl, 0.9 * amt)
	var carry: float = ease_out(clampf(k / 0.3, 0.0, 1.0)) * (1.0 - smoothstep(0.8, 1.0, k))
	r.slide = r.dir * r.travel * carry
	r.rot = r.side * 0.7 * amt * absf(r.dir.y)
	rig.gun_out = rig.gun_out and amt < 0.05


## Recoils behind the shield: shoved straight back, hands braced, head tucked.
static func _shield(r: HumanReact, rig: CutRig, e: float) -> void:
	r.off = Vector2(-r.travel * e, 0.0)
	rig.c_hands_up = maxf(rig.c_hands_up, 0.35 * e)
	r.head_off = Vector2(-30.0 * e, 0.0)
	r.head_s = 1.0 - 0.08 * e


static func _fold(r: HumanReact, rig: CutRig, e: float) -> void:
	r.off = r.dir * r.travel * e
	rig.c_tuck = maxf(rig.c_tuck, 0.55 * e)
	r.scl = Vector2(1.0 - 0.18 * e, 1.0)
	r.head_off = Vector2(55.0 * e, 0.0)
	r.head_s = 1.0 - 0.12 * e
	rig.gun_out = false


## Electro: the body jitters in place, the torso twitches, the hat jolts (head scale pulses).
static func convulse(r: HumanReact, rig: CutRig, env: float) -> void:
	var f: float = r.t * TAU
	var j: Vector2 = Vector2(sin(f * 9.1 + r.phase), sin(f * 7.3 + r.phase * 2.0))
	r.off = j * r.travel * env
	rig.twist = sin(f * 11.7 + r.phase) * 0.3 * env
	rig.c_hands_up = maxf(rig.c_hands_up, (0.5 + 0.4 * sin(f * 6.3)) * env)
	r.head_rot = sin(f * 13.0 + r.phase) * 0.35 * env
	r.head_s = 1.0 + 0.14 * absf(sin(f * 8.7)) * env
	rig.gun_out = false


## Burning: arms up and flailing, the torso and head thrashing (the host runs the body).
static func flail(r: HumanReact, rig: CutRig, env: float) -> void:
	var f: float = r.t * TAU
	rig.twist = sin(f * 2.6 + r.phase) * 0.55 * env
	rig.c_hands_up = maxf(rig.c_hands_up, env)
	rig.c_reach = maxf(rig.c_reach, (0.5 + 0.5 * sin(f * 3.3)) * env)
	r.head_rot = sin(f * 4.1 + r.phase) * 0.5 * env
	r.off = Vector2(0.0, sin(f * 2.6) * r.travel) * env
	rig.gun_out = false


## Fast attack (to 1 at `attack`), smooth ease back to 0 by k = 1.
static func snap(k: float, attack: float) -> float:
	if k < attack:
		return smoothstep(0.0, attack, k)
	return 1.0 - smoothstep(attack, 1.0, k)


static func ease_out(k: float) -> float:
	var c: float = clampf(k, 0.0, 1.0)
	return 1.0 - (1.0 - c) * (1.0 - c) * (1.0 - c)
