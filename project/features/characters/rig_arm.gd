class_name RigArm
extends RefCounted
## One arm: a hand target blended from guard (ready) to hanging (relax) with walk speed and a
## counter-swing, then overridden by aim IK on the gun arm (with recoil), the punch reach on the
## melee arm, hands-up, roll tuck and death sprawl; solved as a 3D two-bone chain. A strongly
## foreshortened segment swaps to its end-on cell; the gun arm swaps to its pistol cell.


static func solve(rig: CutRig, s: int, ph: float, walk01: float) -> void:
	var p: BodyPlan = rig.plan
	var side: RigLimbs = rig.sides[s]
	var sh: Vector3 = p.shoulder[s]
	var l1: float = p.upper_len
	var l2: float = p.fore_len[s]
	var aim_arm: bool = rig.gun_out and p.gun_arm == s
	var tgt: Vector3 = _target(rig, s, ph, walk01, aim_arm)
	var elbow: Vector3 = RigGait.ik3(Vector3(sh.x, sh.y, 0.0), tgt, l1, l2, _pole(p, s))
	var e2: Vector2 = Vector2(elbow.x, elbow.y)
	var s2: Vector2 = Vector2(sh.x, sh.y)
	var h2: Vector2 = Vector2(tgt.x, tgt.y)
	var flat: Vector2 = h2 - s2
	if Vector3(flat.x, flat.y, tgt.z).length() > l1 + l2:
		h2 = s2 + flat.normalized() * minf(flat.length(), l1 + l2)
	side.j_shoulder = s2
	side.j_elbow = e2
	side.j_hand = h2
	var fore_draw: float = _place(rig, s, aim_arm)
	_hand(rig, side, fore_draw)
	var behind: bool = h2.x < sh.x - 40.0
	side.upper.z_index = p.arm_below if behind else p.arm_above
	side.fore.z_index = p.arm_below if behind else p.arm_above + 1


static func _pole(p: BodyPlan, s: int) -> Vector3:
	return Vector3(-0.4, p.side_sign(s), -0.5)


static func _target(rig: CutRig, s: int, ph: float, walk01: float, aim_arm: bool) -> Vector3:
	var p: BodyPlan = rig.plan
	var sh: Vector3 = p.shoulder[s]
	var reach: float = p.upper_len + p.fore_len[s]
	var sgn: float = p.side_sign(s)
	var hang: float = clampf(walk01 * (0.55 + 0.45 * rig.run_blend), 0.0, 1.0)
	if not p.ready_stance:
		hang = 1.0
	var tgt: Vector3 = p.hand_ready[s].lerp(p.hand_relax[s], hang)
	tgt.x += sin(ph) * -sgn * lerpf(70.0, 150.0, rig.run_blend) * walk01
	if rig.sides[s].shield != null and rig.sides[s].shield.visible:
		tgt = tgt.lerp(Vector3(sh.x + reach * 0.8, sh.y * 0.35, -20.0), 0.85)
	if rig.aiming and aim_arm:
		var tl: Vector2 = rig.torso.global_transform.affine_inverse() * rig.aim_at
		var dv: Vector2 = (tl - Vector2(sh.x, sh.y)).normalized()
		tgt = Vector3(sh.x + dv.x * reach * 0.97, sh.y + dv.y * reach * 0.97, -10.0)
		tgt.x -= 60.0 * rig.c_recoil
	if s == p.melee_arm and rig.c_reach > 0.0:
		tgt = tgt.lerp(Vector3(sh.x + reach * 0.99, sh.y * 0.2, 0.0), rig.c_reach)
	if rig.c_hands_up > 0.0:
		tgt = tgt.lerp(Vector3(sh.x + 30.0, sh.y * 0.55, 160.0), rig.c_hands_up)
	if rig.c_tuck > 0.0:
		tgt = tgt.lerp(Vector3(sh.x + 70.0, sh.y - sgn * 70.0, -40.0), rig.c_tuck)
	if rig.c_sprawl > 0.0:
		tgt = tgt.lerp(Vector3(sh.x + 60.0, sh.y + sgn * reach * 0.95, -60.0), rig.c_sprawl)
	return tgt


## Places both segments (end-on cells when foreshortened); returns the forearm's drawn length.
## Uses the side's shoulder, elbow and hand joints (rig-local part px).
static func _place(rig: CutRig, s: int, aim_arm: bool) -> float:
	var p: BodyPlan = rig.plan
	var side: RigLimbs = rig.sides[s]
	var s2: Vector2 = side.j_shoulder
	var e2: Vector2 = side.j_elbow
	var h2: Vector2 = side.j_hand
	var fore_cell: String = p.gun_cell if aim_arm and p.gun_cell != "" else p.fore_part[s]
	var d2: float = p.fore_draw[s]
	if not p.has_endon():
		_cell(rig, side.fore, fore_cell, 1, side)
		RigGait.place(side.upper, s2, e2, p.upper_draw)
		RigGait.place(side.fore, e2, h2, d2)
		return d2
	var end1: bool = e2.distance_to(s2) / p.upper_len < p.endon_below and not aim_arm
	var end2: bool = h2.distance_to(e2) / p.fore_len[s] < p.endon_below and not aim_arm
	_cell(rig, side.upper, p.endon_upper[s] if end1 else p.upper_part[s], 0, side)
	_cell(rig, side.fore, p.endon_fore[s] if end2 else fore_cell, 1, side)
	RigGait.place(side.upper, s2, e2, p.endon_upper_len if end1 else p.upper_draw)
	if end2:
		d2 = p.endon_fore_len
	RigGait.place(side.fore, e2, h2, d2)
	if p.endon_round:
		if end1:
			side.upper.scale.x = 1.0
		if end2:
			side.fore.scale.x = 1.0
	return d2


static func _hand(rig: CutRig, side: RigLimbs, fore_draw: float) -> void:
	var fs: float = side.fore.scale.x
	if side.hand != null:
		var p: BodyPlan = rig.plan
		side.hand.position = Vector2(fore_draw + p.hand_gap, 0.0)
		side.hand.scale = Vector2((0.6 + 0.4 * minf(fs, 1.0)) / maxf(fs, 0.01), 1.0)
		var cell: String = p.hand_open
		if rig.gun_out:
			cell = p.hand_pistol
		elif rig.c_reach > 0.5:
			cell = p.hand_closed
		_cell(rig, side.hand, cell, 2, side)
	if side.shield != null:
		side.shield.scale = Vector2(1.0 / maxf(fs, 0.3), 1.0)
		side.shield.rotation = -side.fore.rotation
		side.shield.visible = rig.variant.shield and rig.c_sprawl < 0.5


## Swaps a part's cell only when it changes (which: 0 upper, 1 fore, 2 hand).
static func _cell(rig: CutRig, spr: Sprite2D, cell: String, which: int, side: RigLimbs) -> void:
	if which < 2 and rig.variant != null and rig.variant.sleeve != "":
		var alt: String = cell + rig.variant.sleeve
		if rig.lib.sizes.has(alt):
			cell = alt
	var now: String = (
		side.upper_cell if which == 0 else (side.fore_cell if which == 1 else side.hand_cell)
	)
	if now == cell:
		return
	if which == 0:
		side.upper_cell = cell
	elif which == 1:
		side.fore_cell = cell
	else:
		side.hand_cell = cell
	rig.set_part_tex(spr, cell)
