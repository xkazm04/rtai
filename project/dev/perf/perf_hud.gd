class_name PerfHud
extends CanvasLayer
## perf lane (d9): the live frame-budget overlay (`--perf-hud`), bottom right, over every view.
## A graph of the last WINDOW frames' busy time (lines at 8.3 and 16.7 ms) and, refreshed every
## TEXT_EVERY frames, the window's busy and wall p50 / p99 / worst, process and physics time, the
## render server's CPU and GPU time, draw calls, objects, nodes, static + video memory. Busy =
## the frame's first _process to the render server's post-draw (its own clock: a --write-movie
## encode or a vsync wait is not in it); wall = between two of its _process calls (it runs last),
## left off under --write-movie. Never the frame delta. Read only: nothing in the sim moves.

const WINDOW: int = 240
const TEXT_EVERY: int = 15
const GRAPH: Vector2 = Vector2(240.0, 72.0)
const SCALE_MS: float = 33.3
const MARGIN: float = 12.0
const FONT_PX: int = 14
const BG: Color = Color(0.08, 0.07, 0.06, 0.78)
const INK: Color = Color(0.93, 0.89, 0.8)
const BAR: Color = Color(0.78, 0.74, 0.66)
const OVER: Color = Color(0.95, 0.68, 0.2)
const RULE: Color = Color(0.6, 0.57, 0.5, 0.7)

var _ms: PackedFloat32Array = PackedFloat32Array()
var _busy: PackedFloat32Array = PackedFloat32Array()
var _start: FrameStart = FrameStart.new()
var _last_busy: float = 0.0
var _movie: bool = Engine.get_write_movie_path() != ""
var _head: int = 0
var _count: int = 0
var _last_us: int = 0
var _frames: int = 0
var _lines: PackedStringArray = PackedStringArray()
var _panel: Control = Control.new()


## Adds the overlay under `parent` when the command line has --perf-hud (LaunchArgs).
static func attach(parent: Node) -> void:
	if LaunchArgs.has("--perf-hud"):
		parent.add_child(PerfHud.new())


func _init() -> void:
	layer = 127
	process_priority = 8100  # after the game's nodes: the wall time spans a whole frame
	@warning_ignore("return_value_discarded")
	_ms.resize(WINDOW)
	@warning_ignore("return_value_discarded")
	_busy.resize(WINDOW)
	_start.process_priority = -8100  # before the game's nodes
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	@warning_ignore("return_value_discarded")
	_panel.draw.connect(_draw_panel)


func _ready() -> void:
	RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(), true)
	add_child(_panel)
	add_child(_start)
	@warning_ignore("return_value_discarded")
	RenderingServer.frame_post_draw.connect(_on_post_draw)


func _on_post_draw() -> void:
	if _start.us > 0:
		_last_busy = (Time.get_ticks_usec() - _start.us) / 1000.0


func _process(_delta: float) -> void:
	var now: int = Time.get_ticks_usec()
	if _last_us > 0:
		_ms[_head] = (now - _last_us) / 1000.0
		_busy[_head] = _last_busy
		_head = (_head + 1) % WINDOW
		_count = mini(_count + 1, WINDOW)
	_last_us = now
	_frames += 1
	if _frames % TEXT_EVERY == 0:
		_lines = lines()
	_panel.queue_redraw()


## The overlay's text rows (also what a test reads).
func lines() -> PackedStringArray:
	if _count == 0:
		return PackedStringArray()
	var out: PackedStringArray = PackedStringArray([_frame_row("busy", _busy.slice(0, _count))])
	if not _movie:
		@warning_ignore("return_value_discarded")
		out.append(_frame_row("wall", _ms.slice(0, _count)))
	@warning_ignore("return_value_discarded")
	out.append_array([_cost_row(), _count_row()])
	return out


## `label`: ms/frame from the window's mean, p50, p99 and the worst frame of the window.
static func _frame_row(label: String, s: PackedFloat32Array) -> String:
	s.sort()
	var n: int = s.size()
	var mean: float = 0.0
	for v: float in s:
		mean += v
	mean /= n
	var p99: float = s[mini(n - 1, floori(n * 0.99))]
	var at: Array = [label, mean, s[n / 2], p99, s[n - 1]]
	return "%s mean %.2f  p50 %.2f  p99 %.2f  worst %.1f ms" % at


func _cost_row() -> String:
	var vp: RID = get_viewport().get_viewport_rid()
	var at: Array = [
		Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
		Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0,
		RenderingServer.viewport_get_measured_render_time_cpu(vp),
		RenderingServer.viewport_get_measured_render_time_gpu(vp),
	]
	return "process %.2f  physics %.2f  render cpu %.2f  gpu %.2f ms" % at


static func _count_row() -> String:
	var at: Array = [
		Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
		Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
		Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0,
	]
	return "draws %d  objs %d  nodes %d  mem %.0f MB  vram %.0f MB" % at


func _draw_panel() -> void:
	var font: Font = ThemeDB.fallback_font
	var text_h: float = FONT_PX + 4.0
	var size: Vector2 = Vector2(GRAPH.x + 200.0, GRAPH.y + text_h * _lines.size() + 18.0)
	var view: Vector2 = _panel.get_viewport_rect().size
	var origin: Vector2 = view - size - Vector2(MARGIN, MARGIN)
	_panel.draw_rect(Rect2(origin, size), BG)
	var base: Vector2 = origin + Vector2(6.0, 6.0 + GRAPH.y)
	var step: float = GRAPH.x / WINDOW
	for i: int in _count:
		var v: float = _busy[(_head - _count + i + WINDOW) % WINDOW]
		var h: float = minf(v / SCALE_MS, 1.0) * GRAPH.y
		var x: float = base.x + i * step
		_panel.draw_line(
			Vector2(x, base.y), Vector2(x, base.y - h), OVER if v > 16.7 else BAR, step
		)
	for budget: float in [8.33, 16.67]:
		var y: float = base.y - budget / SCALE_MS * GRAPH.y
		_panel.draw_line(Vector2(base.x, y), Vector2(base.x + GRAPH.x, y), RULE, 1.0)
	for k: int in _lines.size():
		var at: Vector2 = Vector2(base.x, base.y + 6.0 + text_h * (k + 1))
		_panel.draw_string(font, at, _lines[k], HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_PX, INK)


## Stamps the start of the frame's _process pass (the lowest priority runs first).
class FrameStart:
	extends Node
	var us: int = 0

	func _process(_delta: float) -> void:
		us = Time.get_ticks_usec()
