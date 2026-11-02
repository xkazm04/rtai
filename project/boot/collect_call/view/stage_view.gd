class_name StageView
extends Node2D
## Quest 1's places as flat placeholder ink: Factory Row's alley and dumpster, the payphones
## (ringing rings while Patch has a call), the Toner Room basement, Dock 9's floor, gates,
## catwalks and vault cage, the TUCK-IN crate stack with its bolt-through-a-robot mark, the
## Harbor Road skip, and the cash taped under the phone.

var stage: CollectCallStage


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if stage == null:
		return
	_zones()
	for spot: String in stage.layout.hide_at:
		Ink.box(self, stage.layout.hide_at[spot], Vector2(2.4, 1.6), Ink.INK)
		Ink.box(self, stage.layout.hide_at[spot] + Vector2(0, -0.7), Vector2(2.6, 0.3), Ink.CREAM)
	for phone: String in stage.layout.phones:
		_phone(phone, stage.layout.phones[phone])
	_crates()


func _zones() -> void:
	var l: StageLayout = stage.layout
	_floor(Rect2(-9, -9, 18, 18), Ink.WASH, "FACTORY ROW")
	var toner: Vector2 = l.marker("The Toner Room").at
	_floor(Rect2(toner - Vector2(9, 7), Vector2(18, 14)), Color(Ink.INK, 0.22), "THE TONER ROOM")
	var dock: Vector2 = l.marker("Dock 9 bonded storage").at
	_floor(Rect2(dock - Vector2(18, 18), Vector2(38, 36)), Color(Ink.INK, 0.08), "DOCK 9")
	for y: float in [-15.0, 15.0]:
		draw_line(Ink.px(Vector2(dock.x - 12, y)), Ink.px(Vector2(dock.x + 14, y)), Ink.INK, 6.0)
	var cage: Vector2 = l.marker("Dock 9 vault cage").at
	var cage_rect: Rect2 = Rect2(Ink.px(cage - Vector2(8, 10)), Vector2(16, 6) * Ink.PX_PER_M)
	for i: int in 33:
		var x: float = cage_rect.position.x + i * cage_rect.size.x / 32.0
		draw_line(
			Vector2(x, cage_rect.position.y), Vector2(x, cage_rect.end.y), Color(Ink.INK, 0.5), 1.5
		)
	draw_rect(cage_rect, Ink.INK, false, Ink.LINE_PX)
	var road: Vector2 = l.marker("Harbor Road").at
	_floor(Rect2(road.x - 22, road.y + 3, 50, 5), Color(Ink.INK, 0.55), "HARBOR ROAD")


func _floor(r: Rect2, fill: Color, name: String) -> void:
	var p: Rect2 = Rect2(Ink.px(r.position), r.size * Ink.PX_PER_M)
	draw_rect(p, fill, true)
	draw_rect(p, Ink.INK, false, Ink.LINE_PX)
	Ink.label(self, r.position + Vector2(r.size.x * 0.5, 0.8), name, 30, Ink.INK)


func _phone(phone: String, at: Vector2) -> void:
	Ink.box(self, at + Vector2(0.0, 0.3), Vector2(0.25, 0.9), Ink.INK)
	Ink.box(self, at + Vector2(0.0, -0.3), Vector2(0.9, 0.9), Ink.INK)
	Ink.box(self, at + Vector2(-0.15, -0.35), Vector2(0.25, 0.6), Ink.VERMILION)
	Ink.label(self, at + Vector2(0.0, -1.1), "PAYPHONE", 18, Ink.INK)
	if stage.router.ringing(phone):
		var pulse: float = float(stage.tick % 30) / 30.0
		for k: int in 3:
			var r: float = (0.8 + k * 0.5 + pulse * 0.5) * Ink.PX_PER_M
			draw_arc(Ink.px(at), r, -2.4, -0.7, 16, Ink.VERMILION, Ink.LINE_PX, true)
	if stage.cash_phone == phone:
		_cash(at + Vector2(1.6, -0.3))


func _cash(env: Vector2) -> void:
	Ink.box(self, env, Vector2(1.4, 0.8), Ink.CREAM)
	var a: Vector2 = env + Vector2(-0.8, -0.3)
	draw_line(Ink.px(a), Ink.px(env + Vector2(-0.2, 0.4)), Ink.VERMILION, 6.0)
	draw_line(Ink.px(env + Vector2(0.2, -0.4)), Ink.px(env + Vector2(0.8, 0.3)), Ink.VERMILION, 6.0)
	Ink.label(self, env, "$1,500", 18, Ink.INK)
	Ink.label(self, env + Vector2(0.0, 0.75), "taped under", 14, Ink.INK)


func _crates() -> void:
	var at: Vector2 = stage.layout.crates_at
	for row: int in 2:
		for col: int in 5:
			var c: Vector2 = at + Vector2(-4.0 + col * 2.0, -1.0 + row * 1.6)
			Ink.box(self, c, Vector2(1.8, 1.4), Ink.CREAM)
			_bolt_robot(c + Vector2(0.45, 0.0))
	Ink.label(self, at + Vector2(0.0, -2.1), stage.layout.crates_label, 22, Ink.INK)


## The stencil: a little robot head with a lightning bolt through it.
func _bolt_robot(c: Vector2) -> void:
	Ink.box(self, c, Vector2(0.45, 0.4), Ink.CREAM)
	draw_circle(Ink.px(c + Vector2(-0.1, -0.05)), 2.5, Ink.INK)
	draw_circle(Ink.px(c + Vector2(0.1, -0.05)), 2.5, Ink.INK)
	var bolt: Array[Vector2] = []
	for v: Vector2 in [
		Vector2(-0.3, -0.35), Vector2(0.05, 0.0), Vector2(-0.05, 0.05), Vector2(0.3, 0.4)
	]:
		bolt.append(Ink.px(c + v))
	draw_polyline(PackedVector2Array(bolt), Ink.VERMILION, 3.0, true)
	Ink.label(self, c + Vector2(-0.95, 0.0), "TUCK-IN", 11, Ink.INK)
