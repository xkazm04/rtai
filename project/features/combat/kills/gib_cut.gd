class_name GibCut
extends RefCounted
## The rig cut (lane brutality): a posed CutRig copied into six loose part groups (head with the
## hat, torso with the pelvis and collar, each arm, each leg) built from the rig's own sprites,
## textures, shared print materials and cream halos, so a gib is the real cop in the D5 print,
## not a debug shape. Each group is a Node2D centred on its parts, in the rig parent's px.
## Render only: never sim state, no RNG.


## Six Node2D groups by SignatureKill.PIECE_IDS index (a group may be empty: no sprites).
static func cut(rig: CutRig) -> Array[Node2D]:
	var kind_of: Dictionary[Node, int] = _limb_kinds(rig)
	var groups: Array[Node2D] = []
	var sums: PackedVector2Array = PackedVector2Array()
	var counts: PackedInt32Array = PackedInt32Array()
	for i: int in SignatureKill.PIECE_IDS.size():
		var g: Node2D = Node2D.new()
		g.name = SignatureKill.PIECE_IDS[i]
		@warning_ignore("return_value_discarded")
		groups.append(g)
		@warning_ignore("return_value_discarded")
		sums.append(Vector2.ZERO)
		@warning_ignore("return_value_discarded")
		counts.append(0)
	var inv: Transform2D = (rig.get_parent() as CanvasItem).get_global_transform().affine_inverse()
	var origin: Vector2 = rig.position
	for spr: Sprite2D in _sprites(rig):
		var k: int = _kind(spr, rig, kind_of)
		var copy: Sprite2D = _copy(spr)
		var xf: Transform2D = inv * spr.get_global_transform()
		xf.origin -= origin
		copy.transform = xf
		copy.z_index = _z(spr, rig)
		groups[k].add_child(copy)
		if spr.name != RigBuild.HALO:
			sums[k] += xf.origin
			counts[k] += 1
	for i: int in groups.size():
		var c: Vector2 = sums[i] / float(counts[i]) if counts[i] > 0 else Vector2.ZERO
		for ch: Node in groups[i].get_children():
			(ch as Node2D).position -= c
		groups[i].position = c
	return groups


static func _limb_kinds(rig: CutRig) -> Dictionary[Node, int]:
	var out: Dictionary[Node, int] = {rig.head: 0}
	for s: int in 2:
		var side: RigLimbs = rig.sides[s]
		for spr: Sprite2D in [side.upper, side.fore, side.hand]:
			if spr != null:
				out[spr] = 2 + s
		for spr: Sprite2D in [side.thigh, side.shin, side.foot]:
			if spr != null:
				out[spr] = 4 + s
	return out


static func _kind(spr: Node, rig: CutRig, kind_of: Dictionary[Node, int]) -> int:
	var n: Node = spr
	while n != null and n != rig:
		if kind_of.has(n):
			return kind_of[n]
		n = n.get_parent()
	return 1


static func _sprites(root: Node) -> Array[Sprite2D]:
	var out: Array[Sprite2D] = []
	for ch: Node in root.get_children():
		if ch is CanvasItem and not (ch as CanvasItem).visible:
			continue
		if ch is Sprite2D and (ch as Sprite2D).texture != null:
			@warning_ignore("return_value_discarded")
			out.append(ch as Sprite2D)
		out.append_array(_sprites(ch))
	return out


static func _copy(spr: Sprite2D) -> Sprite2D:
	var c: Sprite2D = Sprite2D.new()
	c.texture = spr.texture
	c.centered = spr.centered
	c.offset = spr.offset
	c.flip_h = spr.flip_h
	c.flip_v = spr.flip_v
	c.region_enabled = spr.region_enabled
	c.region_rect = spr.region_rect
	c.hframes = spr.hframes
	c.vframes = spr.vframes
	c.frame = spr.frame
	c.material = spr.material
	c.modulate = spr.modulate
	c.self_modulate = spr.self_modulate
	c.name = spr.name
	return c


## The sprite's z under the rig (relative z summed up to the rig).
static func _z(spr: Node, rig: CutRig) -> int:
	var total: int = 0
	var n: Node = spr
	while n != null and n != rig:
		var ci: CanvasItem = n as CanvasItem
		if ci != null:
			total += ci.z_index
			if not ci.z_as_relative:
				break
		n = n.get_parent()
	return clampi(total, RenderingServer.CANVAS_ITEM_Z_MIN, RenderingServer.CANVAS_ITEM_Z_MAX)
