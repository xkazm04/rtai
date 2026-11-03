class_name NoirHeadlights
extends RefCounted
## D-Noir headlights (lane noir): every live car (traffic and police) throws a cone of white light
## ahead of its nose in the noir pass. Render only: reads the sim snapshot (positions and
## headings), never writes it. A record is SimConst.SNAP_STRIDE floats: id, kind, mode, tier,
## x, y, hx, hy, ...

const MAX_CARS: int = 12
## Metres from a car's centre to its nose (the cone's apex).
const NOSE_M: float = 2.0


## Up to MAX_CARS noses (x, y metres) with headings (z, w), nearest the focus first, for cars
## whose cone (reach_m long) can touch the view rect around focus.
static func near(
	snap: PackedFloat64Array, focus: Vector2, half_m: Vector2, reach_m: float
) -> PackedVector4Array:
	var view: Rect2 = Rect2(focus - half_m, half_m * 2.0).grow(reach_m)
	var found: Array[Vector4] = []
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[r] >= SimConst.SNAP_PROJ_BASE:
			break
		var kind: int = int(snap[r + 1])
		if kind != SimConst.K_CAR and kind != SimConst.K_PCAR:
			continue
		if int(snap[r + 2]) == SimConst.M_DEAD:
			continue
		var h: Vector2 = Vector2(snap[r + 6], snap[r + 7])
		if h.length_squared() < 0.01:
			continue
		h = h.normalized()
		var nose: Vector2 = Vector2(snap[r + 4], snap[r + 5]) + h * NOSE_M
		if view.has_point(nose):
			found.append(Vector4(nose.x, nose.y, h.x, h.y))
	found.sort_custom(func(a: Vector4, b: Vector4) -> bool: return _closer(a, b, focus))
	var out: PackedVector4Array = PackedVector4Array()
	for i: int in mini(found.size(), MAX_CARS):
		@warning_ignore("return_value_discarded")
		out.append(found[i])
	return out


## Noses in metres -> screen uv (as NoirLamps.to_uv); the headings stay unit vectors (the canvas
## scales x and y alike).
static func to_uv(
	cars: PackedVector4Array, focus: Vector2, zoom: float, view: Vector2
) -> PackedVector4Array:
	var out: PackedVector4Array = PackedVector4Array()
	for c: Vector4 in cars:
		var p: Vector2 = (
			((Vector2(c.x, c.y) - focus) * SimConst.PX_PER_M * zoom + view * 0.5) / view
		)
		@warning_ignore("return_value_discarded")
		out.append(Vector4(p.x, p.y, c.z, c.w))
	return out


static func _closer(a: Vector4, b: Vector4, focus: Vector2) -> bool:
	var da: float = Vector2(a.x, a.y).distance_squared_to(focus)
	var db: float = Vector2(b.x, b.y).distance_squared_to(focus)
	return da < db or (da == db and (a.x < b.x or (a.x == b.x and a.y < b.y)))
