class_name RigBuild
extends RefCounted
## Builds a CutRig's part tree once (the expensive step a pool prewarms): legs under the rig,
## body -> pelvis / torso -> head and arms, Rivet's claw and hose, the riot shield, and the cream
## readability halos (the sticker rim) under the core and along the arms.

const HALO: StringName = &"halo"
## CutRig.halo_limb values: how a halo widens at gameplay scale (CutRig._on_view).
const HALO_BODY: int = 0
const HALO_ARM: int = 1
## n5-cast: the leg rim (BodyPlan.leg_rim): Rivet's piston shins are ~2 screen px at 32 px/m.
const HALO_LEG: int = 2


static func build(rig: CutRig) -> void:
	var p: BodyPlan = rig.plan
	for s: int in 2:
		var side: RigLimbs = rig.sides[s]
		side.thigh = _limb(rig, p.thigh_part[s], p.z_thigh, rig)
		side.shin = _limb(rig, p.shin_part[s], p.z_shin, rig)
		side.foot = _limb(rig, p.foot_part[s], p.z_foot, rig)
	rig.body = _node(rig, Vector2.ZERO)
	rig.pelvis = _node(rig.body, p.pelvis_pos)
	rig.torso = _node(rig.body, p.torso_pos)
	rig.head = _node(rig.torso, p.head_pos - p.torso_pos)
	var core: PartMaterials.PartKind = (
		PartMaterials.PartKind.CORE if p.has_collar() else PartMaterials.PartKind.PART
	)
	rig.pelvis_spr = _part(rig, p.pelvis_part, core, true, -1)
	_attach(rig.pelvis, rig.pelvis_spr, p.pelvis_z)
	rig.torso_spr = _part(rig, p.torso_part, core, true, p.torso_swap)
	_attach(rig.torso, rig.torso_spr, p.torso_z)
	if p.has_collar():
		rig.collar_spr = _part(rig, p.collar_part, PartMaterials.PartKind.COLLAR, true, -1)
		rig.collar_spr.position = p.collar_pos - p.torso_pos
		_attach(rig.torso, rig.collar_spr, p.collar_z)
	rig.head_spr = _part(rig, p.head_part, _head_kind(core), true, p.head_swap)
	_attach(rig.head, rig.head_spr, p.head_z)
	_arms(rig, p)
	if p.has_hose():
		_hose(rig, p)
	_halo(rig, rig.torso_spr, -1, HALO_BODY)
	_halo(rig, rig.head_spr, -1, HALO_BODY)
	for s: int in 2:
		var side: RigLimbs = rig.sides[s]
		for spr: Sprite2D in [side.upper, side.fore, side.hand]:
			if spr != null:
				_halo(rig, spr, -16, HALO_ARM)
		if p.leg_rim:
			for spr: Sprite2D in [side.thigh, side.shin, side.foot]:
				_halo(rig, spr, -16, HALO_LEG)


## Swaps a part's texture and pivot; body parts stay centred; limb halos follow their part.
static func set_tex(rig: CutRig, spr: Sprite2D, part: String) -> void:
	var t: Texture2D = rig.lib.tex(part)
	if spr.texture == t:
		return
	spr.texture = t
	var centred: bool = spr == rig.head_spr or spr == rig.torso_spr or spr == rig.pelvis_spr
	var pv: Vector2 = t.get_size() * 0.5
	if not centred:
		pv = rig.lib.pivot(part, t)
	spr.offset = -pv
	var holder: Node = spr.get_parent() if centred else spr
	for c: Node in holder.get_children():
		if c.name == HALO and c is Sprite2D:
			var h: Sprite2D = c as Sprite2D
			h.texture = t
			h.offset = spr.offset


## n5-cast: Rivet's helmet (the core rig) prints the welder-visor sticker at gameplay scale.
static func _head_kind(core: PartMaterials.PartKind) -> PartMaterials.PartKind:
	if core == PartMaterials.PartKind.CORE:
		return PartMaterials.PartKind.HEAD
	return core


static func _arms(rig: CutRig, p: BodyPlan) -> void:
	for s: int in 2:
		var side: RigLimbs = rig.sides[s]
		side.upper = _limb(rig, p.upper_part[s], 0, rig.torso)
		side.fore = _limb(rig, p.fore_part[s], 0, rig.torso)
	if p.has_hand():
		var left: RigLimbs = rig.sides[BodyPlan.L]
		left.hand = _part(rig, p.hand_open, _limb_kind(p), false, -1)
		left.fore.add_child(left.hand)
	if p.shield_part != "":
		var sp: Sprite2D = _part(rig, p.shield_part, PartMaterials.PartKind.PART, true, -1)
		sp.position = p.shield_pos
		_attach(rig.sides[BodyPlan.L].fore, sp, 3)
		rig.sides[BodyPlan.L].shield = sp


static func _hose(rig: CutRig, p: BodyPlan) -> void:
	var hose: Line2D = Line2D.new()
	hose.width = p.hose_width
	hose.texture = PartLibrary.texture(p.art_dir, p.hose_tex)
	hose.texture_mode = Line2D.LINE_TEXTURE_STRETCH
	hose.joint_mode = Line2D.LINE_JOINT_ROUND
	hose.material = PartMaterials.get_mat(PartMaterials.PartKind.PART, false, 0)
	hose.z_index = 8
	rig.add_child(hose)
	rig.hose = hose


static func _limb(rig: CutRig, part: String, z: int, parent: Node2D) -> Sprite2D:
	var spr: Sprite2D = _part(rig, part, _limb_kind(rig.plan), false, -1)
	_attach(parent, spr, z)
	return spr


static func _limb_kind(p: BodyPlan) -> PartMaterials.PartKind:
	return PartMaterials.PartKind.LIMB if p.limb_lod else PartMaterials.PartKind.PART


static func _part(
	rig: CutRig, part: String, kind: PartMaterials.PartKind, centred: bool, swap: int
) -> Sprite2D:
	var spr: Sprite2D = Sprite2D.new()
	spr.texture = PartLibrary.texture(rig.plan.art_dir, part)
	spr.centered = false
	var pv: Vector2 = spr.texture.get_size() * 0.5
	if not centred:
		pv = PartLibrary.of(rig.plan.art_dir).pivot(part, spr.texture)
	spr.offset = -pv
	var sw: int = maxi(swap, 0)
	spr.material = PartMaterials.get_mat(kind, false, sw)
	rig.sprites.append(spr)
	@warning_ignore_start("return_value_discarded")
	rig.sprite_kinds.append(int(kind))
	rig.sprite_swaps.append(sw)
	@warning_ignore_restore("return_value_discarded")
	return spr


static func _attach(parent: Node2D, spr: Sprite2D, z: int) -> void:
	spr.z_index = z
	parent.add_child(spr)


static func _node(parent: Node2D, at: Vector2) -> Node2D:
	var n: Node2D = Node2D.new()
	n.position = at
	parent.add_child(n)
	return n


static func _halo(rig: CutRig, src: Sprite2D, z: int, mode: int) -> void:
	var h: Sprite2D = Sprite2D.new()
	h.name = HALO
	h.texture = src.texture
	h.centered = false
	h.offset = src.offset
	h.material = PartMaterials.get_mat(PartMaterials.PartKind.HALO, false, 0)
	h.z_index = z
	if mode != HALO_BODY:
		src.add_child(h)
	else:
		src.get_parent().add_child(h)
	rig.halos.append(h)
	@warning_ignore("return_value_discarded")
	rig.halo_limb.append(mode)
