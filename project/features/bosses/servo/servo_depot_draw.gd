class_name ServoDepotDraw
extends RefCounted
## The CS courier depot's dressing on the fight floor (servo.json `depot`, first pass, render
## only): roller-door loading bays on one edge (dock bumpers, slats, the bay number painted on the
## apron) and the conveyor on the other (side rails, rollers, chevrons and CS cartons that ride it
## once rush hour starts the belt). Rush hour also rolls the bay doors up over ROLL_S: the slats
## gather into the drum at the wall and the bay's dark mouth opens onto the apron (Servo's bays).
## Ink, paper and steel only: no danger colour on scenery.

## Seconds the doors take to roll up once rush hour starts.
const ROLL_S: float = 1.6

var px: float = 32.0
var pal: PaletteTokens = PaletteTokens.shared()


func draw(c: CanvasItem, t: ServoTuning, origin: Vector2, running_s: float) -> void:
	var u: float = clampf(running_s / ROLL_S, 0.0, 1.0)
	var open: float = u * u * (3.0 - 2.0 * u)  # eased: the drum starts and stops slow
	for i: int in t.bays.size():
		_bay(c, origin + t.bays[i], t.bay_w_m, i + 1, open)
	_belt(c, t, origin, running_s)


## A roller door seen from above: the door strip, slats, two bumpers and the apron number; `open`
## 0..1 rolls the slats up into the drum at the wall side (-y) and shows the dark bay behind.
func _bay(c: CanvasItem, at: Vector2, w: float, n: int, open: float) -> void:
	var door: Rect2 = Rect2((at - Vector2(w * 0.5, 0.45)) * px, Vector2(w, 0.9) * px)
	c.draw_rect(door.grow(3.0), pal.color(&"ink"))
	var slats: Rect2 = door
	slats.size.y = door.size.y * lerpf(1.0, 0.22, open)
	if open > 0.0:  # the bay's mouth: dark inside, a pale strip of the depot's lights deep in
		var mouth: Rect2 = Rect2(
			door.position.x, slats.end.y, door.size.x, door.end.y - slats.end.y
		)
		c.draw_rect(mouth, pal.color(&"ink"))
		var lamp: Rect2 = Rect2(
			mouth.position + Vector2(4.0, 3.0), Vector2(mouth.size.x - 8.0, 2.0)
		)
		c.draw_rect(lamp, Color(pal.color(&"paper"), 0.35 * open))
	c.draw_rect(slats, pal.color(&"steel"))
	var rows: int = maxi(2, roundi(6.0 * (1.0 - open * 0.67)))
	for k: int in rows:
		var y: float = slats.position.y + slats.size.y * (k + 0.5) / rows
		c.draw_line(Vector2(door.position.x, y), Vector2(door.end.x, y), pal.color(&"ink_2"), 1.0)
	for s: float in [-1.0, 1.0]:
		var bump: Vector2 = (at + Vector2(s * (w * 0.5 + 0.25), 0.6)) * px
		c.draw_rect(
			Rect2(bump - Vector2(0.18, 0.3) * px, Vector2(0.36, 0.6) * px), pal.color(&"ink")
		)
	var apron: Rect2 = Rect2((at + Vector2(-w * 0.5, 0.6)) * px, Vector2(w, 2.2) * px)
	c.draw_rect(apron, Color(pal.color(&"paper"), 0.12))
	c.draw_rect(apron, Color(pal.color(&"paper"), 0.5), false, 2.0)
	var font_px: int = int(px * 0.9)
	c.draw_string(
		ThemeDB.fallback_font,
		(at + Vector2(-0.3, 2.3)) * px,
		str(n),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_px,
		Color(pal.color(&"paper"), 0.6)
	)


## The belt: rails, rollers, chevrons (moving at belt_mps after `running_s`) and riding cartons.
func _belt(c: CanvasItem, t: ServoTuning, origin: Vector2, running_s: float) -> void:
	var a: Vector2 = origin + t.belt_from
	var b: Vector2 = origin + t.belt_to
	var len_m: float = a.distance_to(b)
	if len_m < 0.5:
		return
	var dir: Vector2 = (b - a) / len_m
	var side: Vector2 = dir.orthogonal() * t.belt_w_m * 0.5
	var poly: PackedVector2Array = [
		(a + side) * px, (b + side) * px, (b - side) * px, (a - side) * px
	]
	c.draw_colored_polygon(poly, pal.color(&"ink_2"))
	for s: Vector2 in [side, -side]:
		c.draw_line((a + s) * px, (b + s) * px, pal.color(&"ink"), 4.0)
	var shift: float = fposmod(running_s * t.belt_mps, 1.0)
	for k: int in int(len_m):
		var m: Vector2 = a + dir * (float(k) + shift)
		var tip: Vector2 = m + dir * 0.3
		c.draw_line((m + side * 0.6) * px, tip * px, Color(pal.color(&"steel"), 0.8), 2.0)
		c.draw_line((m - side * 0.6) * px, tip * px, Color(pal.color(&"steel"), 0.8), 2.0)
	var ride: float = running_s * t.belt_mps
	for k: int in 5:
		var along: float = fposmod(float(k) * len_m / 5.0 + ride, len_m)
		var at: Vector2 = (a + dir * along) * px
		var h: float = t.belt_w_m * 0.32 * px
		c.draw_rect(Rect2(at - Vector2(h, h), Vector2(h, h) * 2.0), pal.color(&"paper_2"))
		c.draw_rect(Rect2(at - Vector2(h, h), Vector2(h, h) * 2.0), pal.color(&"ink"), false, 1.5)
		c.draw_string(
			ThemeDB.fallback_font,
			at + Vector2(-h * 0.7, h * 0.35),
			"CS",
			0,
			-1,
			int(h),
			pal.color(&"ink")
		)
