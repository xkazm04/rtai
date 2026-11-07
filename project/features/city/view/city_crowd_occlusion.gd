class_name CityCrowdOcclusion
extends RefCounted
## The baked crowd (the multimesh peds and cops) behind a lifted building (n8 city; the REPORT gap
## "the baked crowd is not occluded"). CityOcclusion pastes the printed world over the part of each
## crowd body inside a building's drawn area when its feet are north of the building, as it does for
## the rigs, but inks no silhouette: a background walker behind a roof is simply hidden (the rigs
## keep theirs). Positions come from the sim's snapshot (m). Render only.

## A lying body's (down or dead) patch half-size (m) round its position.
const LYING_HALF_M: float = 0.9
## Off-screen margin (m): a body whose feet are just below the screen still shows its head.
const MARGIN_M: float = 2.0


## Appends to `out` the patch of every crowd body behind a building in `blds`; returns the drawn
## areas of the buildings that hid one (each once), for CityOcclusion's lift of the bodies in front.
static func patches(
	snap: PackedFloat64Array, blds: Array[CityOccluders.Bld], view_px: Rect2, out: Array[Rect2]
) -> Array[Rect2]:
	var seen: Rect2 = view_px.grow(MARGIN_M * SimConst.PX_PER_M)
	var zone: Array[Rect2] = []
	var union: Rect2 = Rect2()
	for b: CityOccluders.Bld in blds:
		zone.append(zone_of(b).intersection(seen))
		union = zone[-1] if not union.has_area() else union.merge(zone[-1])
	var hit: Dictionary[CityOccluders.Bld, bool] = {}
	if not union.has_area():
		return []
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[r] >= SimConst.SNAP_PROJ_BASE:
			break  # projectile records follow every actor
		var kind: int = int(snap[r + 1])
		var feet: Vector2 = Vector2(snap[r + 4], snap[r + 5]) * SimConst.PX_PER_M
		if (kind != SimConst.K_PED and kind != SimConst.K_COP) or not union.has_point(feet):
			continue
		var box: Rect2 = body_box(feet, int(snap[r + 2]))
		for i: int in blds.size():
			if zone[i].has_point(feet):
				var p: Rect2 = box.intersection(blds[i].area)
				if p.has_area():
					out.append(p)
					hit[blds[i]] = true
	var areas: Array[Rect2] = []
	for b: CityOccluders.Bld in hit:
		areas.append(b.area)
	return areas


## Where a body's feet put it behind b (px): under its drawn area grown by half a body (a standing
## box's foot line, a lying square), down to its north edge (CityOcclusion.NORTH_TOL_PX).
static func zone_of(b: CityOccluders.Bld) -> Rect2:
	var pad: float = LYING_HALF_M * SimConst.PX_PER_M + Ink.LINE_PX
	var bottom: float = b.r.position.y + CityOcclusion.NORTH_TOL_PX
	return Rect2(
		b.area.position.x - pad,
		b.area.position.y - pad,
		b.area.size.x + pad * 2.0,
		bottom - b.area.position.y + pad
	)


## A crowd body's screen box (px): standing, CityOcclusion's feet-to-head patch; lying, a square
## round its position.
static func body_box(feet: Vector2, mode: int) -> Rect2:
	var px: float = SimConst.PX_PER_M
	if mode == SimConst.M_DEAD or mode == SimConst.M_DOWN:
		var h: float = LYING_HALF_M * px
		return Rect2(feet - Vector2(h, h), Vector2(h, h) * 2.0)
	var w: float = CityOcclusion.PATCH_W_M * px
	var tall: float = CityOcclusion.BODY_H_M * px
	return Rect2(feet.x - w * 0.5, feet.y - tall, w, tall).grow(Ink.LINE_PX)
