class_name KillTrackRows
extends RefCounted
## The n16 deaths' own keys of a signature_kills.json row (lane kills-new): the pose track, the
## fall side, the lying length and the style's overlay values, read once from the table by row id
## (SignatureKill keeps the framework's keys only, so the n16 styles grow no shared class).
## Render only.


class Extra:
	extends RefCounted
	## [tick, lean_deg, squash, tip] keys (KillTrack.sample).
	var track: Array[PackedFloat32Array] = []
	## forward | back | side (KillTrack.fall_vec).
	var fall: StringName = &"back"
	var lie_len: float = 1.0
	## The slide along the shot (m) by the track's last key, eased with the tip.
	var slide_m: float = 0.0
	## Style overlay values (spurts, nails, scraps, glow ...), as the row has them.
	var fx: Dictionary[String, float] = {}
	## The death's own drawn cells (row `cells`): each frame's start tick, and art -> card row ->
	## grid file (KillDeathCells). Empty = the victim's fall grid plays (KillFallCells).
	var cells_at: PackedInt32Array = PackedInt32Array()
	var grids: Dictionary = {}
	## art -> card row -> the loose headgear's tumble cells (KillLooseArt).
	var loose: Dictionary = {}
	## art -> card row -> the death's drawn loose scraps, square cells across (KillShredArt).
	var scraps: Dictionary = {}

	## The style value `key` (row fx), or `fallback`.
	func num(key: String, fallback: float) -> float:
		return fx.get(key, fallback)


static var _rows: Dictionary[StringName, Extra] = {}
static var _loaded: bool = false


## The row's extra keys (an empty Extra when the row has none).
static func of(row_id: StringName) -> Extra:
	if not _loaded:
		load_from(DataTable.open(SignatureKillTable.PATH, SignatureKillTable.SCHEMA))
	return _rows.get(row_id, Extra.new())


static func load_from(t: DataTable) -> void:
	_loaded = true
	_rows.clear()
	if not t.ok():
		return
	for v: Variant in t.array(t.raw, "kills"):
		if v is Dictionary:
			var d: Dictionary = v
			_rows[StringName(str(d.get("id", "")))] = from_dict(d)


static func from_dict(d: Dictionary) -> Extra:
	var e: Extra = Extra.new()
	for k: Variant in d.get("track", []):
		var key: PackedFloat32Array = _floats(k)
		if key.size() >= 4:
			e.track.append(key)
	e.fall = StringName(str(d.get("fall", "back")))
	e.lie_len = _f(d.get("lie_len", 1.0))
	e.slide_m = _f(d.get("slide_m", 0.0))
	var fx: Variant = d.get("fx", {})
	if fx is Dictionary:
		var src: Dictionary = fx
		for name: Variant in src:
			e.fx[str(name)] = _f(src[name])
	_cells(e, d.get("cells", {}))
	return e


static func _cells(e: Extra, v: Variant) -> void:
	if not v is Dictionary:
		return
	var c: Dictionary = v
	for x: float in _floats(c.get("at", [])):
		@warning_ignore("return_value_discarded")
		e.cells_at.append(roundi(x))
	var g: Variant = c.get("grids", {})
	if g is Dictionary:
		e.grids = g
	var l: Variant = c.get("loose", {})
	if l is Dictionary:
		e.loose = l
	var sc: Variant = c.get("scraps", {})
	if sc is Dictionary:
		e.scraps = sc


static func _f(v: Variant) -> float:
	return str(v).to_float()


static func _floats(v: Variant) -> PackedFloat32Array:
	var out: PackedFloat32Array = PackedFloat32Array()
	if v is Array:
		var a: Array = v
		for x: Variant in a:
			@warning_ignore("return_value_discarded")
			out.append(_f(x))
	return out
