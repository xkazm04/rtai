class_name KingBodyView
extends BossView
## King from straight above, after the 90-degree panel of boss_king.jpg: phase 1 the gilded
## throne-car (a long black stretch body, gold trim and grille, the hood cannon forward, the throne
## mid-car with King under a vermilion fur-trimmed cape); phases 2-3 King on foot (squat grey
## press body, two gold press plates, the jewelled crown, the cape behind). FIRST PASS, drawn
## shapes: the cutout rig from part sheets replaces this (docs/bosses/king.md, "The body").

const GOLD: Color = Color("#D9A933")
const GOLD_DARK: Color = Color("#8A6418")
const CAR_BLACK: Color = Color("#231F22")
const STEEL: Color = Color("#8E8B86")
const FUR: Color = Color("#EFE6D2")
const PLUM: Color = Color("#5A2335")
const CAR_LEN_M: float = 6.6
const CAR_W_M: float = 2.5


func _draw() -> void:
	if fight == null:
		return
	draw_set_transform(Ink.px(fight.body.pos), fight.body.facing.angle(), Vector2.ONE)
	if fight.phase <= 1:  # the procession, then the court on the stalled car
		_car()
	else:
		_on_foot()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for g: BossFight in standing_adds():  # the gang off the car (phase 2's adds)
		draw_set_transform(Ink.px(g.body.pos), g.body.facing.angle(), Vector2.ONE * 1.3)
		_gangster(Vector2.ZERO)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## The throne-car along +x (its nose), centred on the body.
func _car() -> void:
	var p: float = Ink.PX_PER_M
	var l: float = CAR_LEN_M * p
	var w: float = CAR_W_M * p
	var body: Rect2 = Rect2(-l * 0.5, -w * 0.5, l, w)
	draw_rect(body.grow(4.0), Ink.INK)
	draw_rect(body, CAR_BLACK)
	draw_rect(body.grow(-6.0), GOLD_DARK, false, 3.0)
	draw_rect(Rect2(l * 0.5 - 10.0, -w * 0.42, 10.0, w * 0.84), GOLD)  # the grille
	draw_rect(Rect2(-l * 0.5, -w * 0.45, 8.0, w * 0.9), GOLD_DARK)  # rear bumper
	draw_rect(Rect2(l * 0.12, -10.0, l * 0.3, 20.0), GOLD)  # the hood cannon
	draw_circle(Vector2(l * 0.42, 0.0), 13.0, GOLD_DARK)
	draw_rect(Rect2(-l * 0.28, -w * 0.5, l * 0.18, w), PLUM)  # the rear cabin's plush
	for sx: float in [-0.36, 0.3]:  # the gang at the four corners
		for sy: float in [-1.0, 1.0]:
			_gangster(Vector2(l * sx, sy * (w * 0.5 + 0.3 * p)))
	_king(Vector2(-l * 0.08, 0.0), 1.0)


## King on foot: the squat press body, plates out to the sides, cape behind.
func _on_foot() -> void:
	var lunge: float = 0.0
	if fight.state == BossFight.State.WINDUP:
		lunge = -0.25 * (1.0 - float(fight.tell_left()) / float(maxi(fight.attack.windup, 1)))
	_king(Vector2(lunge * Ink.PX_PER_M, 0.0), 1.25)


func _king(at: Vector2, k: float) -> void:
	var p: float = Ink.PX_PER_M * k
	var cape: PackedVector2Array = PackedVector2Array(
		[
			at + Vector2(0.1, -0.7) * p,
			at + Vector2(-1.1, -0.95) * p,
			at + Vector2(-1.3, 0.0) * p,
			at + Vector2(-1.1, 0.95) * p,
			at + Vector2(0.1, 0.7) * p
		]
	)
	draw_colored_polygon(cape, Ink.VERMILION)  # the King's cape: vermilion by verdict
	draw_polyline(cape, FUR, 0.16 * p)
	draw_circle(at, 0.62 * p, Ink.INK)
	draw_circle(at, 0.56 * p, STEEL)
	for sy: float in [-1.0, 1.0]:  # the gold press plates
		var plate: Rect2 = Rect2(at + Vector2(-0.1, sy * 0.62 - 0.22) * p, Vector2(0.62, 0.44) * p)
		draw_rect(plate.grow(3.0), Ink.INK)
		draw_rect(plate, GOLD)
	draw_arc(at, 0.4 * p, -2.4, 2.4, 16, GOLD, 0.1 * p)  # the gold chains
	_crown(at, 0.3 * p)


func _crown(at: Vector2, r: float) -> void:
	var pts: Array[Vector2] = []
	for i: int in 10:
		var rr: float = r if i % 2 == 0 else r * 0.62
		pts.append(at + Vector2.from_angle(TAU * float(i) / 10.0) * rr)
	var poly: PackedVector2Array = PackedVector2Array(pts)
	draw_colored_polygon(poly, GOLD)
	draw_polyline(poly + PackedVector2Array([pts[0]]), Ink.INK, 2.0)
	draw_circle(at, r * 0.3, Ink.VERMILION.darkened(0.15))


func _gangster(at: Vector2) -> void:
	var p: float = Ink.PX_PER_M
	draw_circle(at, 0.36 * p, Ink.INK)
	draw_circle(at, 0.31 * p, STEEL)
	draw_rect(Rect2(at + Vector2(0.06, -0.2) * p, Vector2(0.12, 0.4) * p), Ink.INK)  # shades
	draw_arc(at, 0.22 * p, 1.2, 5.1, 10, GOLD, 4.0)  # gold chain
