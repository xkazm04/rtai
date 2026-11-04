class_name NodeSpans
extends Node
## perf-city: what each processing node costs in the live fight (dev arena `--spans=<json>`).
## Every RESCAN_FRAMES frames it lists the tree's processing nodes in their own process order
## (priority, then tree order), gives them strictly increasing priorities in that same order and
## puts a SpanMark right before each one, so the time between two marks is one node's _process.
## The order is unchanged, so the fight is too. Nodes spawned between scans keep priority 0 and
## run before the first mark: their time is the "(new since last scan)" row. Costs are summed per
## script (or engine class) per frame. Measurement only: the marks and the re-sort add their own
## cost, so take frame times from a run without --spans.
## The flush after _process (deferred calls, tweens, timers and every queued CanvasItem redraw)
## is split on the CanvasItem `draw` signal, which fires right after that item's _draw: the time
## since the previous signal (or since the last _process) is that item's "draw:" row. Deferred
## work queued between two redraws lands on the next one; what follows the last redraw up to the
## render server's pre-draw is the FLUSH_REST row.

const RESCAN_FRAMES: int = 30
const NEW_LABEL: String = "(new since last scan)"
const FLUSH_REST: String = "flush: after the last redraw (deferred calls, tweens, timers)"

var out_path: String = ""
var _marks: Array[SpanMark] = []
var _labels: PackedStringArray = PackedStringArray()
var _start: SpanMark = SpanMark.new()
var _series: Dictionary[String, PackedFloat32Array] = {}
var _nodes: Dictionary[String, int] = {}
var _frames: int = 0
var _frame: Dictionary[String, float] = {}
var _ref_us: int = 0
var _hooked: Dictionary[int, bool] = {}
var _written: bool = false


static func attach(parent: Node, args: ArenaArgs) -> void:
	if not args.has("--spans"):
		return
	var probe: NodeSpans = NodeSpans.new()
	probe.out_path = args.text("--spans")
	parent.add_child(probe)


func _ready() -> void:
	process_priority = 8192  # after every node, FightFrames' probe included
	_start.process_priority = -8000
	add_child(_start)
	@warning_ignore("return_value_discarded")
	RenderingServer.frame_pre_draw.connect(_on_pre_draw)


func _process(_delta: float) -> void:
	if not _marks.is_empty():
		_collect()
	if _frames % RESCAN_FRAMES == 0:
		_rescan()
	_ref_us = Time.get_ticks_usec()


func _add(label: String, ms: float) -> void:
	_frame[label] = _frame.get(label, 0.0) + ms


func _on_draw(label: String) -> void:
	if _ref_us == 0:
		return
	var now: int = Time.get_ticks_usec()
	_add(label, (now - _ref_us) / 1000.0)
	_ref_us = now


func _on_pre_draw() -> void:
	if _ref_us != 0:
		_add(FLUSH_REST, (Time.get_ticks_usec() - _ref_us) / 1000.0)
	_ref_us = 0


func _collect() -> void:
	var frame: Dictionary[String, float] = _frame
	_add(NEW_LABEL, (_marks[0].us - _start.us) / 1000.0)
	for k: int in _marks.size() - 1:
		_add(_labels[k], (_marks[k + 1].us - _marks[k].us) / 1000.0)
	_frame = {}
	for label: String in frame:
		if not _series.has(label):
			var pad: PackedFloat32Array = PackedFloat32Array()
			@warning_ignore("return_value_discarded")
			pad.resize(_frames)
			_series[label] = pad
		@warning_ignore("return_value_discarded")
		_series[label].append(frame[label])
	_frames += 1
	for label: String in _series:  # labels absent this frame get a zero
		if _series[label].size() < _frames:
			@warning_ignore("return_value_discarded")
			_series[label].append(0.0)


func _rescan() -> void:
	var found: Array[Array] = []
	_walk(get_tree().root, found)
	found.sort_custom(_before)
	while _marks.size() < found.size() + 1:
		var m: SpanMark = SpanMark.new()
		add_child(m)
		_marks.append(m)
	while _marks.size() > found.size() + 1:
		var gone: SpanMark = _marks.pop_back()
		gone.queue_free()
	_labels.clear()
	_nodes.clear()
	for k: int in found.size():
		var node: Node = found[k][2]
		_marks[k].process_priority = 1 + 2 * k  # mark, then its node, all above the new nodes' 0
		node.process_priority = 2 + 2 * k
		var label: String = _label(node)
		@warning_ignore("return_value_discarded")
		_labels.append(label)
		_nodes[label] = _nodes.get(label, 0) + 1
	_marks[found.size()].process_priority = 2 + 2 * found.size()


func _walk(node: Node, found: Array[Array]) -> void:
	var mine: bool = node == self or node is SpanMark or node is FightFrames
	mine = mine or node.get_parent() is FightFrames
	if not mine and (node.is_processing() or node.is_processing_internal()):
		found.append([node.process_priority, found.size(), node])
	if node is CanvasItem and not _hooked.has(node.get_instance_id()):
		_hooked[node.get_instance_id()] = true
		var label: String = "draw: " + _label(node)
		if not label.ends_with(".gd") and node.get_parent() != null:
			label += " in " + _label(node.get_parent())
		@warning_ignore("return_value_discarded")
		(node as CanvasItem).draw.connect(_on_draw.bind(label))
	for child: Node in node.get_children():
		_walk(child, found)


## Process order: priority, then tree order.
static func _before(a: Array, b: Array) -> bool:
	return a[0] < b[0] or (a[0] == b[0] and a[1] < b[1])


static func _label(node: Node) -> String:
	var script: Object = node.get_script()
	if script is Script and str(script.get(&"resource_path")) != "":
		return str(script.get(&"resource_path")).get_file()
	return node.get_class()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		write()


func write() -> void:
	if _written or out_path == "" or _frames == 0:
		return
	_written = true
	var rows: Array[Dictionary] = []
	for label: String in _series:
		rows.append(_row(label, _series[label]))
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["mean_ms"] > b["mean_ms"])
	var doc: Dictionary = {"schema": "gtai.node-spans/1", "frames": _frames, "rows": rows}
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(out_path.get_base_dir())
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	if f == null:
		Log.warn("bench", "node spans: cannot write %s" % out_path)
		return
	@warning_ignore("return_value_discarded")
	f.store_string(JSON.stringify(doc, "  "))
	f.close()
	Log.info("bench", "node spans -> %s (%d frames, %d rows)" % [out_path, _frames, rows.size()])


func _row(label: String, s: PackedFloat32Array) -> Dictionary:
	var total: float = 0.0
	for v: float in s:
		total += v
	var sorted: PackedFloat32Array = s.duplicate()
	sorted.sort()
	var n: int = sorted.size()
	return {
		"label": label,
		"nodes_last_scan": _nodes.get(label, 0),
		"mean_ms": snappedf(total / maxf(1.0, n), 0.001),
		"p99_ms": snappedf(sorted[mini(n - 1, floori(n * 0.99))], 0.001),
		"max_ms": snappedf(sorted[n - 1], 0.001),
	}


## Stamps the moment the node after it starts its _process.
class SpanMark:
	extends Node
	var us: int = 0

	func _process(_delta: float) -> void:
		us = Time.get_ticks_usec()
