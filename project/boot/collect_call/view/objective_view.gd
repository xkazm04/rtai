class_name ObjectiveView
extends Node2D
## The slice's guidance in screen space (the HUD layer): the current ObjectiveHint's prompt on a
## paper strip under the beat panel, and its goal marked in vermilion (objectives are one of
## vermilion's few uses): a ring on the goal when it is on screen, an edge arrow toward it
## when it is not. The camera centres Rivet, so a goal's screen point is the screen centre plus
## its offset in metres times px_per_m.

const EDGE_INSET: float = 70.0
const RING_PX: float = 34.0
const TEXT_SIZE: int = 24

var stage: CollectCallStage
var system: QuestSystem
var px_per_m: float = 32.0
var _text: QuestText = QuestText.new()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if stage == null or system == null:
		return
	var hint: ObjectiveHint = ObjectiveHint.of(stage, system)
	if hint.key == &"":
		return
	_prompt(hint.words(_text))
	if hint.goal != Vector2.INF:
		_goal(hint.goal)


func _prompt(words: String) -> void:
	var font: Font = ThemeDB.fallback_font
	var size: Vector2 = font.get_string_size(words, HORIZONTAL_ALIGNMENT_LEFT, -1, TEXT_SIZE)
	var at: Vector2 = Vector2(48.0, 186.0)
	draw_rect(Rect2(at - Vector2(14, 30), size + Vector2(28, 18)), Color(Ink.CREAM, 0.92))
	draw_rect(Rect2(at - Vector2(14, 30), size + Vector2(28, 18)), Ink.INK, false, 3.0)
	draw_string(font, at, words, HORIZONTAL_ALIGNMENT_LEFT, -1, TEXT_SIZE, Ink.INK)


func _goal(goal_m: Vector2) -> void:
	var screen: Vector2 = get_viewport_rect().size
	var centre: Vector2 = screen / 2.0
	var at: Vector2 = centre + (goal_m - stage.arena.rivet.pos) * px_per_m
	var inner: Rect2 = Rect2(Vector2.ONE * EDGE_INSET, screen - Vector2.ONE * EDGE_INSET * 2.0)
	if inner.has_point(at):
		if at.distance_to(centre) > RING_PX:
			draw_arc(at, RING_PX, 0.0, TAU, 32, Ink.VERMILION, 4.0, true)
		return
	var dir: Vector2 = (at - centre).normalized()
	var half: Vector2 = inner.size / 2.0
	var tx: float = absf(half.x / dir.x) if dir.x != 0.0 else INF
	var t: float = minf(tx, absf(half.y / dir.y) if dir.y != 0.0 else INF)
	var tip: Vector2 = centre + dir * t
	var side: Vector2 = dir.orthogonal() * 16.0
	var tri: PackedVector2Array = [tip, tip - dir * 34.0 + side, tip - dir * 34.0 - side]
	draw_colored_polygon(tri, Ink.VERMILION)
	draw_polyline(tri + PackedVector2Array([tip]), Ink.INK, 3.0, true)
