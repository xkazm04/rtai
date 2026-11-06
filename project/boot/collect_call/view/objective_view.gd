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
## Edge arrows stay below the beat panel and above the subtitle box (screen px).
const TOP_CLEAR: float = 250.0
const BOTTOM_CLEAR: float = 340.0

var stage: CollectCallStage
var system: QuestSystem
var px_per_m: float = 32.0
## n7-melee: where the camera sits off Rivet this frame (m; KerfGlide's whip after a blink), so
## the ring stays on its goal while the camera travels. Zero = the old Rivet-centred mark.
var cam_off_m: Vector2 = Vector2.ZERO
## true when the prompts should name the pad's buttons (the player used a pad last).
var pad_prompts: Callable = func() -> bool: return false
var _text: QuestText = QuestText.new()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if stage == null or system == null:
		return
	var hint: ObjectiveHint = ObjectiveHint.of(stage, system)
	if hint.key == &"":
		return
	var pad: bool = pad_prompts.call()
	_prompt(hint.words(_text, pad))
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
	var at: Vector2 = centre + (goal_m - stage.arena.rivet.pos - cam_off_m) * px_per_m
	# the clear band between the top panels and the subtitle box
	var top: float = minf(TOP_CLEAR, centre.y - 40.0)
	var clear_below: float = BOTTOM_CLEAR if _subtitled() else EDGE_INSET
	var bottom: float = maxf(screen.y - clear_below, centre.y + 40.0)
	var inner: Rect2 = Rect2(EDGE_INSET, top, screen.x - EDGE_INSET * 2.0, bottom - top)
	if inner.has_point(at):
		if at.distance_to(centre - cam_off_m * px_per_m) > RING_PX:  # Rivet is not on it
			draw_arc(at, RING_PX, 0.0, TAU, 32, Ink.VERMILION, 4.0, true)
		return
	var dir: Vector2 = (at - centre).normalized()
	var tx: float = (
		(inner.end.x - centre.x if dir.x > 0.0 else inner.position.x - centre.x) / dir.x
		if dir.x != 0.0
		else INF
	)
	var ty: float = (
		(inner.end.y - centre.y if dir.y > 0.0 else inner.position.y - centre.y) / dir.y
		if dir.y != 0.0
		else INF
	)
	var tip: Vector2 = centre + dir * minf(absf(tx), absf(ty))
	var base: Vector2 = tip - dir * 40.0
	var wing: Vector2 = dir.orthogonal() * 18.0
	var head: PackedVector2Array = [tip, base + wing, base - dir * -8.0, base - wing]
	draw_colored_polygon(head, Ink.VERMILION)
	draw_polyline(head + PackedVector2Array([tip]), Ink.INK, 3.0, true)


## A line is on screen (the subtitle box covers the bottom band).
func _subtitled() -> bool:
	return system != null and system.runner != null and system.runner.lines.current != null
