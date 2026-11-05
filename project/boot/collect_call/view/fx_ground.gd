class_name FxGround
extends Node2D
## perf-city: FxView's ground marks (dropped rifles, fire scorch, plasma scorch rings, the ink
## scuffs of rounds in the ground), retained instead of re-issued every frame. Each scuff or
## scorch ring is its own child, printed once and re-printed only while it fades (its last 60 of
## 240 ticks): about 100 circle polygons a frame were 0.4-0.5 ms of FxView's draw. The layer sits
## behind FxView's own strokes and keeps draw_under's order (rifle drops, fire scorch, then the
## marks oldest first), with the same calls, so the print is unchanged.
## `enabled` false = FxView draws them every frame as before (the alternative, one value).

static var enabled: bool = true

var _arena: CombatArena = null
var _fx: GunFx = null
var _tick: int = 0
## Impact (x, y, kind, born tick) -> its mark.
var _marks: Dictionary[Vector4, FxGroundMark] = {}


func _init() -> void:
	show_behind_parent = true
	use_parent_material = true


## Called from FxView._draw each frame after GunFx.step (`fx` null = no gun: rifle drops only).
func sync(arena: CombatArena, fx: GunFx, tick: int) -> void:
	_arena = arena
	_fx = fx
	_tick = tick
	queue_redraw()
	var live: Dictionary[Vector4, bool] = {}
	if fx != null:
		for i: int in fx.impacts.size():
			var im: Vector4 = fx.impacts[i]
			if not FxGroundMark.marks(im):
				continue
			var m: FxGroundMark = _marks.get(im)
			if m == null:
				m = FxGroundMark.new(im, fx.impact_dir[i])
				add_child(m)
				_marks[im] = m
			m.at_tick(tick)
			live[im] = true
	for k: Vector4 in _marks.keys():
		if not live.has(k):
			_marks[k].hide()
			_marks[k].queue_free()
			@warning_ignore("return_value_discarded")
			_marks.erase(k)


func _draw() -> void:
	if _arena == null:
		return
	for d: Vector2 in _arena.rifle_drops:
		draw_line(Ink.px(d + Vector2(-0.4, 0.1)), Ink.px(d + Vector2(0.4, -0.1)), Ink.INK, 5.0)
	if _fx != null:
		_fx.scorch.draw(self, _tick)
