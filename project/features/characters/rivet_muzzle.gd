class_name RivetMuzzle
extends RefCounted
## Lane d9 rivet: the muzzle of Rivet's drawn figure. While a drawn strip carries the weapon the
## held part is hidden, so nothing published HeldMuzzle and the flash, the flame jet's root and the
## spin whirl fell back to the GUN_SIDE_M spot on the ground beside him. Each drawn cell with a
## measured muzzle (data/tables/rivet_muzzle.json, tools/art/rivet_muzzle.py: a fire cell's drawn
## flash root, a left strip's gun tip) publishes it instead, mirrored with the cell. A cell without
## a point (a facing, the base strip) keeps the caller's fallback. View only: writes no sim.

const TABLE: String = "res://data/tables/rivet_muzzle.json"
const SCHEMA: String = "gtai.rivet-muzzle/1"
static var _points: Dictionary = {}
static var _loaded: bool = false


## The measured muzzle of strip `path`'s cell `cell` (px from the cell's top-left, unmirrored),
## or Vector2(-1, -1) when it has none.
static func point(path: String, cell: int) -> Vector2:
	var by_cell: Dictionary = _table().get(path, {})
	return by_cell.get(cell, Vector2(-1.0, -1.0))


## Publishes the drawn cell's muzzle as this frame's HeldMuzzle (a no-op without a point).
static func publish(rig: CutRig) -> void:
	var card: Sprite2D = rig.head_card
	if card == null or not card.has_meta(RivetFrames.ON) or card.texture == null:
		return
	var p: Vector2 = point(str(card.get_meta(RivetFrames.ON)), card.frame)
	if p.x < 0.0:
		return
	var w: float = card.texture.get_width() / float(card.hframes)
	HeldMuzzle.publish(card, card.offset + Vector2(w - p.x if card.flip_h else p.x, p.y))


## d9 it20: feeds RivetHeldView's smear from `held` (the held part, hidden under a drawn figure)
## with `on` (the cut runs); `over_rigs` = the smear holder's z above the rigs. Under a drawn figure
## whose strike draws no arc (RivetStrips.NO_ARC) the cut is rooted on the figure's axis at the
## strike cell's measured tip height, as long as its reach to that tip (the hidden part's own grip
## and length put the crescent out past the drawn tip), just under the figure's card (head_z) so
## the drawn weapon reads over it. Else the held part's grip and length, as before.
static func feed_smear(
	smear: MeleeSmearView, rig: CutRig, held: Sprite2D, on: bool, over_rigs: int
) -> void:
	var len_px: float = held.get_rect().end.x * absf(held.global_scale.x)
	var root: Vector2 = held.global_position
	var eq: String = RivetStrips.strip_of(ViewMode.shared().art, RivetFrames.weapon_of(rig))
	var tip: Vector2 = point(eq, RivetFrames.Eq.FIRE_SIDE)
	var drawn: bool = RivetFrames.owns_weapon(rig) and tip.x >= 0.0
	smear.z_index = rig.plan.head_z - 1 - over_rigs if drawn else 0
	if drawn:
		var tex: Texture2D = load(eq) as Texture2D
		var card: Sprite2D = rig.head_card
		root = card.to_global(Vector2(0.0, RivetFrames.PAD_PX - tex.get_height() + tip.y))
		var half: float = tex.get_width() / float(RivetFrames.EQ_CELLS) * 0.5
		len_px = (tip.x - half) * absf(card.global_scale.x)
	smear.feed(root, held.global_rotation, len_px, on)


static func _table() -> Dictionary:
	if _loaded:
		return _points
	_loaded = true
	var t: DataTable = DataTable.open(TABLE, SCHEMA)
	var strips: Dictionary = t.object(t.raw, "strips")
	for art: String in strips:
		var rows: Dictionary = t.object(strips, art)
		for name: String in rows:
			var cells: Dictionary = t.object(t.object(rows, name), "cells")
			var by_cell: Dictionary = {}
			for c: String in cells:
				by_cell[int(c)] = t.vec(cells, c)
			_points[RivetStrips.DIR + art + "/" + name + ".png"] = by_cell
	return _points
