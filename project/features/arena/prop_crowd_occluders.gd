class_name PropCrowdOccluders
extends RefCounted
## The arena's tall props as occluders for the city's baked crowd (d9 seams item 1). After street's
## 90-tick hold a corpse leaves its rig for the crowd atlas, which PropOcclusion (rigs only) never
## sees: two dead cops north of the city block's kerb barrier drew their heads over its top at
## tilt70. Each frame PropOcclusion hands every prop it would occlude with (PROP_H_M at or over
## MIN_H_M) to the CityOcclusion on the same actor layer as `extra` (its ground rect and its drawn
## area at the live pitch, in CityOcclusion's px), so CityCrowdOcclusion's lying box serves both.
## The CityOcclusion is found by type under the layer (no handle on CityView: the debt ratchet).
## Nothing when the layer has none (the print stage, `top`). Render only.

## false: the crowd's dead draw over the arena's props again (n8's look; for a before/after).
const ON: bool = true

var _occ: CityOcclusion = null
var _looked: bool = false


## Fills the city occluder's `extra` from `arena`'s tall props, drawn as `po` draws them.
func feed(po: PropOcclusion, layer: Node, arena: ArenaStage) -> void:
	if not ON:
		return
	if not _looked:
		_looked = true
		_occ = find(layer)
	if _occ == null or not is_instance_valid(_occ) or arena == null:
		return
	var to_occ: Transform2D = (
		_occ.get_global_transform().affine_inverse() * po.get_global_transform()
	)
	_occ.extra = blds(po, arena, to_occ)


## The CityOcclusion among `layer`'s children, else null.
static func find(layer: Node) -> CityOcclusion:
	for c: Node in layer.get_children():
		if c is CityOcclusion:
			return c as CityOcclusion
	return null


## Every tall prop of `arena` as a city occluder: its ground rect and drawn area, `po`'s local px
## taken through `to_occ` into the city occluder's.
static func blds(
	po: PropOcclusion, arena: ArenaStage, to_occ: Transform2D
) -> Array[CityOccluders.Bld]:
	var out: Array[CityOccluders.Bld] = []
	for s: ArenaStation in arena.stations.stations:
		for p: ArenaStation.Prop in s.props:
			if ArenaFloorView.PROP_H_M.get(p.kind, 0.0) < PropOcclusion.MIN_H_M:
				continue
			var at: Vector2 = arena.plan.base + p.at
			var r: Rect2 = Rect2(Ink.px(at - p.size * 0.5), p.size * Ink.PX_PER_M)
			var b: CityOccluders.Bld = CityOccluders.Bld.new()
			b.r = to_occ * r
			b.area = to_occ * po.drawn_area(r, p)
			b.at = b.r.get_center()
			out.append(b)
	return out
