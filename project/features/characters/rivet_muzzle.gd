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
