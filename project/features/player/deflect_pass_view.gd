class_name DeflectPassView
extends Node2D
## A pass splits a short white-hot rim in two. Its shards separate across the incoming line.
## Recent contacts live on the actor layer only, including when the blade is in the claw.

const LIFE: int = 8
const KEEP: int = 12
const WHITE_HOT: Color = Color("#fffdf4")
const EDGE: Color = Color("#343139")

var _arena: CombatArena
var _marks: Array[Vector4] = []


static func attach(layer: CanvasLayer, arena: CombatArena, order: int) -> void:
	var view: DeflectPassView = DeflectPassView.new()
	view._arena = arena
	view.z_index = order
	view.scale = Vector2.ONE * SimConst.PX_PER_M / Ink.PX_PER_M
	view.visible = false
	layer.add_child(view)
	@warning_ignore("return_value_discarded")
	DeflectRule.of(arena).passed.connect(view._passed)


func _passed(at: Vector2, incoming: Vector2) -> void:
	_marks.append(Vector4(at.x, at.y, incoming.angle(), _arena.tick))
	if _marks.size() > KEEP:
		_marks.remove_at(0)
	visible = true
	queue_redraw()


func _process(_delta: float) -> void:
	while not _marks.is_empty() and _arena.tick - int(_marks[0].w) >= LIFE:
		_marks.remove_at(0)
	if visible:
		visible = not _marks.is_empty()
		queue_redraw()


func _draw() -> void:
	for mark: Vector4 in _marks:
		var age: float = clampf(float(_arena.tick - int(mark.w)) / LIFE, 0.0, 1.0)
		var at: Vector2 = Ink.px(ShotLift.hit_at(Vector2(mark.x, mark.y), GunFx.Hit.PLATING))
		var dir: Vector2 = Vector2.from_angle(mark.z)
		var fade: float = 1.0 - age * age
		for side: float in [-1.0, 1.0]:
			var across: Vector2 = dir.orthogonal() * side
			var split: Vector2 = at + across * (0.08 + 0.30 * age) * Ink.PX_PER_M
			var tip: Vector2 = split + (across * 0.30 + dir * 0.13) * Ink.PX_PER_M
			draw_line(split, tip, Color(EDGE, fade), 6.0, true)
			draw_line(split, tip, Color(WHITE_HOT, fade), 3.0, true)
