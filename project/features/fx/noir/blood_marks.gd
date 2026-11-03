class_name BloodMarks
extends RefCounted
## D-Noir blood marks (lane noir): the shapes BloodFx leaves on the ground. Static, stateless,
## render only. The wobble is a hash of the mark's position (no RNG stream, no sim state).

const POOL_PTS: int = 28
const RIM: float = 1.1
const LOBES: int = 4


## A spreading pool: a star-shaped wet edge (low-frequency hashed waves, never self-crossing),
## run out along `flow` (the hit direction; length = how far it runs): a dark body inside a
## bright red meniscus rim, a white sheen arc on the lit side. cols = [body, rim, sheen].
static func pool(
	ci: CanvasItem, at: Vector2, r: float, flow: Vector2, cols: PackedColorArray
) -> void:
	var s: float = seed_of(at)
	ci.draw_colored_polygon(ring(at, r * RIM, flow, s), cols[1])
	ci.draw_colored_polygon(ring(at, r, flow, s), cols[0])
	if r > 6.0:
		var c: Vector2 = at + Vector2(-0.3, -0.35) * r
		ci.draw_arc(c, r * 0.32, PI * 1.02, PI * 1.48, 8, cols[2], maxf(1.0, r * 0.07))


## A landed droplet: a round core, and when it landed moving (dir length = elongation 0..1) a
## teardrop body stretched along the travel and a tail of shrinking satellite drops ahead of it,
## so a spray on the ground shows which way the hit went.
static func splat(ci: CanvasItem, at: Vector2, r: float, dir: Vector2, c: Color) -> void:
	ci.draw_circle(at, r * 0.7, c)
	if r < 1.5:
		return
	var e: float = clampf(dir.length(), 0.0, 1.0)
	var d: Vector2 = dir.normalized() if e > 0.0 else Vector2.RIGHT
	for k: int in 3:
		ci.draw_circle(at + d * r * 0.4 * k * e, r * (0.66 - 0.14 * k), c)
	var s: float = seed_of(at)
	for k: int in 3:
		var side: Vector2 = d.orthogonal() * (_wave(s, k) - 0.5) * r * 0.8
		var ahead: Vector2 = d * r * (1.5 + 1.1 * k) * (0.4 + e)
		ci.draw_circle(at + ahead + side, r * (0.26 - 0.06 * k), c)
	for k: int in LOBES:
		var a: float = TAU * (k + 0.6 * _wave(s, k + 7)) / LOBES
		ci.draw_circle(
			at + Vector2.from_angle(a) * r * 0.62, r * (0.16 + 0.18 * _wave(s, k + 3)), c
		)


## The pool outline: radius r wobbled by three low-frequency waves (min 0.66 r, so the polygon
## stays star-shaped and simple), pushed out up to |flow| on the side facing flow.
static func ring(at: Vector2, r: float, flow: Vector2, s: float) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	var f: Vector2 = flow.normalized() if flow.length() > 0.001 else Vector2.ZERO
	var run: float = clampf(flow.length(), 0.0, 1.0)
	for k: int in POOL_PTS:
		var ang: float = TAU * k / POOL_PTS
		var u: Vector2 = Vector2.from_angle(ang)
		var w: float = 1.0 + 0.16 * sin(3.0 * ang + s * TAU) + 0.1 * sin(5.0 * ang + s * 17.0)
		w += 0.06 * sin(9.0 * ang + s * 29.0)
		w *= 1.0 + run * pow(maxf(u.dot(f), 0.0), 2.0)
		@warning_ignore("return_value_discarded")
		out.append(at + u * r * w)
	return out


static func seed_of(at: Vector2) -> float:
	return fposmod(sin(at.dot(Vector2(12.9898, 78.233))) * 43758.5453, 1.0)


static func _wave(s: float, k: int) -> float:
	return fposmod(sin((s + k) * 91.7) * 43758.5453, 1.0)
