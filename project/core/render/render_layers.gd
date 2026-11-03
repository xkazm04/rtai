class_name RenderLayers
extends RefCounted
## The render layer stack as data (data/tables/render_layers.json, gtai.render-layers/1): named
## canvases (Godot CanvasLayers) and named z bands inside them. Views ask for a canvas number or
## a band z by id instead of hard-coding them, and audit() proves a scene draws only on declared
## layers. Read once and cached; render only (no sim state, no RNG).

const TABLE: String = "res://data/tables/render_layers.json"
const SCHEMA: String = "gtai.render-layers/1"
## A top-level item's children stay within this many z steps of it (the gap between bands).
const BAND_SPAN: int = 100

static var _shared: RenderLayers = null

var canvases: Dictionary[StringName, int] = {}
var bands: Dictionary[StringName, Vector2i] = {}
var status: Dictionary[StringName, String] = {}
var ok: bool = false


static func shared() -> RenderLayers:
	if _shared == null:
		_shared = RenderLayers.from_json(FileAccess.get_file_as_string(TABLE))
	return _shared


static func from_json(text: String) -> RenderLayers:
	var out: RenderLayers = RenderLayers.new()
	var parser: JSON = JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		return out
	var d: Dictionary = parser.data
	if d.get("schema", "") != SCHEMA:
		return out
	for row: Dictionary in d.get("canvases", []):
		var cid: String = row["id"]
		var layer: float = row["layer"]
		out.canvases[StringName(cid)] = int(layer)
	for row: Dictionary in d.get("layers", []):
		var lid: String = row["id"]
		var on: String = row["canvas"]
		var band_z: float = row["z"]
		var at: int = out.canvases.get(StringName(on), -999)
		out.bands[StringName(lid)] = Vector2i(at, int(band_z))
		out.status[StringName(lid)] = str(row["status"])
	out.ok = not out.canvases.is_empty() and not out.bands.is_empty()
	return out


## The CanvasLayer.layer of a canvas id (e.g. &"actors").
static func canvas(id: StringName) -> int:
	return shared().canvases[id]


## The z_index of a layer band (e.g. &"vehicles").
static func z(id: StringName) -> int:
	return shared().bands[id].y


## The CanvasLayer.layer a layer band lives on.
static func canvas_of(id: StringName) -> int:
	return shared().bands[id].x


## True when (canvas layer, z) is a declared band.
func declared(layer: int, z_index: int) -> bool:
	for id: StringName in bands:
		if bands[id] == Vector2i(layer, z_index):
			return true
	return false


## Every top-level CanvasItem under `root` must sit on a declared band of its canvas; returns
## one line per violation ("" free = the scene is clean). Children of a top-level item are
## relative to it (z_as_relative) and must stay below the next band.
func audit(root: Node) -> Array[String]:
	var out: Array[String] = []
	_walk(root, 0, out)
	return out


func _walk(node: Node, layer: int, out: Array[String]) -> void:
	for child: Node in node.get_children():
		if child is CanvasLayer:
			var cl: CanvasLayer = child
			if not canvases.values().has(cl.layer):
				out.append("%s: canvas layer %d is not declared" % [cl.get_path(), cl.layer])
			_walk(cl, cl.layer, out)
		elif child is CanvasItem:
			var item: CanvasItem = child
			if not declared(layer, item.z_index):
				out.append("%s: z %d on canvas %d" % [item.get_path(), item.z_index, layer])
			_check_children(item, out)
		else:
			_walk(child, layer, out)


func _check_children(item: CanvasItem, out: Array[String]) -> void:
	for c: Node in item.get_children():
		if c is CanvasLayer:
			var cl: CanvasLayer = c
			if not canvases.values().has(cl.layer):
				out.append("%s: canvas layer %d is not declared" % [cl.get_path(), cl.layer])
			_walk(cl, cl.layer, out)
		elif c is CanvasItem:
			var ci: CanvasItem = c
			if not ci.z_as_relative or absi(ci.z_index) >= BAND_SPAN:
				out.append("%s: child z %d escapes its band" % [ci.get_path(), ci.z_index])
			_check_children(ci, out)
