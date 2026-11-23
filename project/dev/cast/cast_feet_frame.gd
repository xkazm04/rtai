class_name CastFeetFrame
extends RefCounted
## A texel centre (u,v) in the cropped cell projects to origin + u*x + v*y.
## Keep the source and transform separate so the sole can be verified against the art.


static func sample(host: ArenaRigs, h: Fighter) -> Dictionary:
	var rig: CutRig = host.rigs.rig_for(h.id)
	if rig == null and host.robots != null:
		rig = host.robots.rig_for(h.id)
	if rig == null:
		return {"error": "actor was outside the full rig pool"}
	for key: StringName in [FoeShieldCardView.CARD, FoeWarCardView.CARD, FoeTurretCardView.CARD]:
		if rig.has_meta(key):
			var sprite: Sprite2D = rig.get_meta(key)
			if sprite.is_visible_in_tree():
				var frame: Dictionary = {"card": _sprite(sprite)}
				if sprite is FoeTurretCardView:
					frame["base"] = _sprite(sprite.get_child(0) as Sprite2D)
				return frame
	if rig.head_card != null and rig.head_card.is_visible_in_tree() and rig.head_card.vframes == 4:
		return {"card": _sprite(rig.head_card)}
	var feet: Array[Dictionary] = []
	for leg: RigLimbs in rig.sides:
		var boot: Dictionary = {}
		if leg.foot != null and leg.foot.is_visible_in_tree() and not leg.stepping:
			boot = _sprite(leg.foot)
		feet.append(boot)
	var torso: Vector2 = rig.torso.get_global_transform_with_canvas().origin
	return {"feet": feet, "torso": [torso.x, torso.y]}


static func _sprite(spr: Sprite2D) -> Dictionary:
	var cell: Rect2 = spr.get_rect()
	var xf: Transform2D = spr.get_global_transform_with_canvas()
	var src: Rect2 = Rect2(Vector2(spr.frame_coords) * cell.size, cell.size)
	if spr.region_enabled:
		src.position += spr.region_rect.position
	var origin: Vector2 = xf * cell.position
	var x: Vector2 = xf.x
	var y: Vector2 = xf.y
	if spr.flip_h:
		origin += x * cell.size.x
		x = -x
	if spr.flip_v:
		origin += y * cell.size.y
		y = -y
	return {
		"path": spr.texture.resource_path,
		"col": spr.frame_coords.x,
		"row": spr.frame_coords.y,
		"rect":
		[roundi(src.position.x), roundi(src.position.y), roundi(src.size.x), roundi(src.size.y)],
		"xf": [origin.x, origin.y, x.x, x.y, y.x, y.y]
	}
