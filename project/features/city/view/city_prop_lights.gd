class_name CityPropLights
extends RefCounted
## Street lamps at night (lights.json `prop_lights`, core/render/README.md): on a grade listed
## in `grades`, the `max_props` light-carrying props nearest the focus within `radius_m` hold a
## `kind` light at their row's `at_m` (the prop sprite's frame, metres from its centre: the lamp
## head). The heads are read once per resident chunk from its draw commands (city_textures.json
## `name` -> texture id) and cached until the chunk leaves; the nearest set is re-picked when
## the focus moved REPICK_M or the grade changed. Off-grade (day) it holds nothing and costs one
## check.

const TABLE: String = "res://data/tables/lights.json"
const REPICK_M: float = 2.0

var lights: LightLayer
var grades: PackedStringArray = PackedStringArray()
var max_props: int = 0
var radius_m: float = 0.0
var kind: StringName = &""
## Lights held now (tests and the cost probe read it).
var held: int = 0
var last_us: int = 0
## texture id -> the head offset in the sprite frame (metres)
var _by_tex: Dictionary[int, Vector2] = {}
var _heads: Dictionary[Vector2i, Array] = {}
var _h: PackedInt32Array = PackedInt32Array()
var _picked_at: Vector2 = Vector2.INF


func _init(layer: LightLayer, textures_table: Dictionary) -> void:
	lights = layer
	var d: Dictionary = CityGen.read_json(TABLE)
	var row: Dictionary = d.get("prop_lights", {})
	var g: Array = row.get("grades", [])
	grades = PackedStringArray(g)
	var cap: float = row.get("max_props", 0)
	max_props = int(cap)
	radius_m = row.get("radius_m", 0.0)
	var kind_id: String = row.get("kind", "")
	kind = StringName(kind_id)
	var ids: Dictionary[String, int] = {}
	var tex_rows: Array = textures_table.get("textures", [])
	for t: Dictionary in tex_rows:
		var tid: float = t["id"]
		var tname: String = t["name"]
		ids[tname] = int(tid)
	var props: Array = row.get("props", [])
	for p: Dictionary in props:
		var at: Array = p["at_m"]
		var x: float = at[0]
		var y: float = at[1]
		var prop: String = p["prop"]
		if ids.has(prop):
			_by_tex[ids[prop]] = Vector2(x, y)
	@warning_ignore("return_value_discarded")
	_h.resize(max_props)
	_h.fill(-1)


## Holds the lamps around `focus_m` from the resident chunks of `res` at sim tick `tick`.
func update(res: CityResidency, focus_m: Vector2, tick: int) -> void:
	var on: bool = grades.has(String(lights.grade))
	if not on and held == 0:
		return
	if on and focus_m.distance_to(_picked_at) < REPICK_M:
		return
	var t0: int = Time.get_ticks_usec()
	_picked_at = focus_m if on else Vector2.INF
	var near: Array[Vector3] = _nearest(res, focus_m) if on else ([] as Array[Vector3])
	held = 0
	for c: int in max_props:
		_hold(c, near[c] if c < near.size() else Vector3.INF, tick)
	last_us = Time.get_ticks_usec() - t0


## (x m, y m, distance m) of the nearest heads, at most max_props.
func _nearest(res: CityResidency, focus_m: Vector2) -> Array[Vector3]:
	var cand: Array[Vector3] = []
	for key: Vector2i in _heads.keys():
		if not res.is_resident(key):
			@warning_ignore("return_value_discarded")
			_heads.erase(key)
	for key: Vector2i in res.resident_keys():
		if CityResidency.rect_dist(key, focus_m) > radius_m:
			continue
		if not _heads.has(key):
			_heads[key] = _read_heads(res.chunk_at(key))
		for p: Vector3 in _heads[key]:
			var d: float = Vector2(p.x, p.y).distance_to(focus_m)
			if d <= radius_m:
				cand.append(Vector3(p.x, p.y, d))
	cand.sort_custom(func(a: Vector3, b: Vector3) -> bool: return a.z < b.z)
	return cand.slice(0, max_props)


## Every light-carrying prop's head in `chunk` (world metres; z unused).
func _read_heads(chunk: CityChunk) -> Array[Vector3]:
	var out: Array[Vector3] = []
	if chunk == null:
		return out
	for k: int in chunk.command_count():
		var t: int = chunk.tex[k]
		var o: int = k * CityChunk.XF_STRIDE
		if not _by_tex.has(t) or chunk.xf[o + 3] > 0.5:
			continue  # not a lamp, or the lamp's baked shadow command
		var xf: Transform2D = Transform2D(chunk.xf[o + 2], Vector2(chunk.xf[o], chunk.xf[o + 1]))
		var head: Vector2 = xf * _by_tex[t]
		out.append(Vector3(head.x, head.y, 0.0))
	return out


func _hold(c: int, p: Vector3, tick: int) -> void:
	if p == Vector3.INF:
		if _h[c] >= 0:
			lights.remove(_h[c])
			_h[c] = -1
		return
	var pos_px: Vector2 = Vector2(p.x, p.y) * SimConst.PX_PER_M
	if _h[c] < 0:
		_h[c] = lights.add(kind, pos_px, 0.0, tick)
	else:
		lights.move(_h[c], pos_px, 0.0)
	held += 1 if _h[c] >= 0 else 0
