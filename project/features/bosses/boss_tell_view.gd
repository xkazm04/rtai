class_name BossTellView
extends Node2D
## A boss attack's telegraph on the ground, drawn from the same BossZone numbers that land the
## hit (what you read is what hits). Enemy-ai's rule scaled up for a boss: while the aim tracks,
## a thin vermilion outline that firms up as the windup runs; at the lock, the zone fills and the
## outline thickens (the "move now" beat); in the active window a bright flash. Vermilion is the
## danger colour (standing palette verdict). Render only: reads the fight each frame.

const LINE_THIN: float = 2.0
const LINE_LOCK: float = 5.0
const FILL_LOCK: float = 0.22
const FILL_ACTIVE: float = 0.45

var fight: BossFight = null
## The boss's adds: their tells draw by the same rules.
var adds: BossAdds = null


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if fight != null:
		_draw_fight(fight)
	if adds != null:
		for f: BossFight in adds.fights:
			_draw_fight(f)


func _draw_fight(f: BossFight) -> void:
	if f.attack == null:
		return
	var s: BossFight.State = f.state
	if s != BossFight.State.WINDUP and s != BossFight.State.ACTIVE:
		return
	var a: BossAttack = f.attack
	var k: float = 1.0 - float(f.tell_left()) / float(maxi(a.windup, 1))
	var col: Color = Ink.VERMILION
	var fill: float = (
		FILL_ACTIVE if s == BossFight.State.ACTIVE else (FILL_LOCK if f.locked else 0.0)
	)
	var width: float = LINE_LOCK if f.locked or s == BossFight.State.ACTIVE else LINE_THIN
	col.a = 0.35 + 0.65 * k if s == BossFight.State.WINDUP else 1.0
	var pts: PackedVector2Array = outline(a, f.origin, f.aim)
	if pts.size() < 3:
		return
	if fill > 0.0:
		draw_colored_polygon(pts, Color(Ink.VERMILION, fill))
	var closed: PackedVector2Array = pts + PackedVector2Array([pts[0]])
	draw_polyline(closed, col, width, true)


## The zone's outline in px (Ink.PX_PER_M), from BossZone's own numbers.
static func outline(a: BossAttack, origin: Vector2, dir: Vector2) -> PackedVector2Array:
	var pts: Array[Vector2] = []
	match a.shape:
		BossAttack.Shape.LINE, BossAttack.Shape.CHARGE:
			var side: Vector2 = dir.orthogonal() * a.width_m * 0.5
			var tip: Vector2 = origin + dir * a.range_m
			for m: Vector2 in [origin + side, tip + side, tip - side, origin - side]:
				pts.append(Ink.px(m))
		BossAttack.Shape.CONE:
			pts.append(Ink.px(origin))
			var half: float = deg_to_rad(a.arc_deg) * 0.5
			for i: int in 13:
				var ang: float = -half + 2.0 * half * float(i) / 12.0
				pts.append(Ink.px(origin + dir.rotated(ang) * a.range_m))
		BossAttack.Shape.CIRCLE:
			for i: int in 32:
				pts.append(Ink.px(origin + Vector2.from_angle(TAU * float(i) / 32.0) * a.radius_m))
	return PackedVector2Array(pts)
