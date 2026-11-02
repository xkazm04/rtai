class_name WorldMarkers
extends Node2D
## World-UI markers as data (data/tables/world_markers.json, gtai.world-markers/1) on the
## world_ui canvas's world_markers band: diamonds and rings in palette inks at a constant screen
## size at every zoom (ink outline + paper sticker rim), bobbing on the 60 Hz tick, plus the
## objective pointer pinned inside the screen edge while the objective is off screen. A kind whose
## accent ink is not allowed for its `use` (palette.json) does not load. Render only.

const TABLE: String = "res://data/tables/world_markers.json"

var kinds: Dictionary[StringName, Dictionary] = {}
var pointer: Dictionary = {}
var reduced_motion: bool = false
## The marker handle the pointer follows (-1 = none).
var objective: int = -1
var _kind: Dictionary[int, StringName] = {}
var _pos: Dictionary[int, Vector2] = {}
var _next: int = 0
var _tick: int = 0


func _init() -> void:
	z_index = RenderLayers.z(&"world_markers")
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(TABLE)) != OK or not parser.data is Dictionary:
		return
	var d: Dictionary = parser.data
	var pal: PaletteTokens = PaletteTokens.shared()
	for row: Dictionary in d["kinds"]:
		var k: Dictionary = row.duplicate()
		var token: StringName = StringName(str(row["token"]))
		var fill: StringName = StringName(str(row.get("fill_token", token)))
		if not on_doctrine(pal, token, row) or not on_doctrine(pal, fill, row):
			continue
		k["color"] = pal.color(fill)
		k["core_color"] = pal.color(token)
		var core: float = row.get("core", 0.0)
		k["core"] = core
		kinds[StringName(str(row["id"]))] = k
	var ptr: Dictionary = d["pointer"]
	pointer = ptr.duplicate()
	pointer["color"] = pal.color(StringName(str(pointer["token"])))


## A marker of `kind` at `pos_px` (world px); -1 when the kind is unknown.
func add(kind: StringName, pos_px: Vector2) -> int:
	if not kinds.has(kind):
		return -1
	_next += 1
	_kind[_next] = kind
	_pos[_next] = pos_px
	return _next


func move(handle: int, pos_px: Vector2) -> void:
	if _pos.has(handle):
		_pos[handle] = pos_px


func remove(handle: int) -> void:
	@warning_ignore("return_value_discarded")
	_kind.erase(handle)
	@warning_ignore("return_value_discarded")
	_pos.erase(handle)
	if objective == handle:
		objective = -1


func count() -> int:
	return _kind.size()


## Advances the bob to sim tick `tick` and redraws; call once a frame.
func step(tick: int) -> void:
	_tick = tick
	queue_redraw()


## Where the pointer sits in screen px (Vector2.INF while the objective is on screen or unset).
func pointer_at(xf: Transform2D, screen: Vector2) -> Vector2:
	if not _pos.has(objective):
		return Vector2.INF
	var p: Vector2 = xf * _pos[objective]
	var m: float = pointer["margin_px"]
	var inner: Rect2 = Rect2(Vector2(m, m), screen - Vector2(m, m) * 2.0)
	if inner.has_point(p):
		return Vector2.INF
	var c: Vector2 = screen * 0.5
	var d: Vector2 = p - c
	var t: float = minf(
		absf(inner.size.x * 0.5 / d.x) if d.x != 0.0 else INF,
		absf(inner.size.y * 0.5 / d.y) if d.y != 0.0 else INF
	)
	return c + d * t


func _draw() -> void:
	var xf: Transform2D = get_global_transform_with_canvas()
	var px: float = 1.0 / maxf(xf.get_scale().x, 0.001)
	for h: int in _kind:
		var k: Dictionary = kinds[_kind[h]]
		var bob: float = _bob(k) * px
		var at: Vector2 = _pos[h] + Vector2(0.0, -bob)
		var size: float = k["size_px"]
		var rim: float = k["rim_px"]
		var col: Color = k["color"]
		var shape: StringName = StringName(str(k["shape"]))
		MarkerShapes.draw(self, shape, at, Vector2(size, rim) * px, col)
		var core: float = k["core"]
		var core_col: Color = k["core_color"]
		if core > 0.0:
			MarkerShapes.fill(self, shape, at, size * core * px, core_col)
	var screen: Vector2 = get_viewport_rect().size
	var at_screen: Vector2 = pointer_at(xf, screen)
	if at_screen == Vector2.INF:
		return
	var dir: Vector2 = (xf * _pos[objective] - at_screen).normalized()
	var size_p: float = pointer["size_px"]
	var rim_p: float = pointer["rim_px"]
	var col_p: Color = pointer["color"]
	var dims: Vector2 = Vector2(size_p, rim_p) * px
	MarkerShapes.arrow(self, xf.affine_inverse() * at_screen, dir, dims, col_p)


## An accent ink only where palette.json allows it for the kind's `use`.
static func on_doctrine(pal: PaletteTokens, token: StringName, row: Dictionary) -> bool:
	return not pal.accent_uses.has(token) or pal.accent_uses[token].has(str(row["use"]))


func _bob(k: Dictionary) -> float:
	var ticks: int = k["bob_ticks"]
	if reduced_motion or ticks <= 0:
		return 0.0
	var amp: float = k["bob_px"]
	return amp * (0.5 + 0.5 * sin(TAU * float(_tick % ticks) / float(ticks)))
