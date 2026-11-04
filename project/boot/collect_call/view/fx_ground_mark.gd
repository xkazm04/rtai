class_name FxGroundMark
extends Node2D
## perf-city: one retained ground mark of FxGround: a round's ink scuff or a plasma bolt's scorch
## ring. Its print depends only on its fade, so it is redrawn only when the fade changes.

var _im: Vector4
var _dir: Vector2
var _tick: int = 0
var _fade: float = -1.0


func _init(im: Vector4, dir: Vector2) -> void:
	_im = im
	_dir = dir
	use_parent_material = true


## True for the impacts GunFxArt.draw_under leaves on the floor (the same test, same order).
static func marks(im: Vector4) -> bool:
	if int(im.z) >= GunFx.SCORCH and int(im.z) % GunFx.SCORCH != GunFx.Hit.BODY:
		return true
	return int(im.z) == GunFx.Hit.GROUND


func at_tick(tick: int) -> void:
	_tick = tick
	# GunFxMarks.scuff and .scorch read the age only through this fade
	var fade: float = clampf(float(GunFx.SCUFF_TICKS - (tick - int(_im.w))) / 60.0, 0.0, 1.0)
	if fade != _fade:
		_fade = fade
		queue_redraw()


func _draw() -> void:
	var at: Vector2 = Vector2(_im.x, _im.y)
	if int(_im.z) >= GunFx.SCORCH:
		GunFxMarks.scorch(self, at, _tick - int(_im.w))
	else:
		GunFxMarks.scuff(self, at, _dir, _tick - int(_im.w), int(_im.w))
