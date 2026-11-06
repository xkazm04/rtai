class_name HaulerMarks
extends RefCounted
## The stomp's marks in the inked look, for any canvas (the city clip, quest 1's view, the arena):
## a rough ink shock ring (deterministic wobble) with a thin soul-teal edge and grit flung out over
## SHOCK_S, then the D5 ground crack (features/souls/art/stomp_crack.png, baked from the road
## tile's own crack art at 96 px/m by tools/souls/bake_stomp_crack.py) held and faded out.

const TEAL: Color = HaulerLook.TEAL
const INK: Color = Color(0.09, 0.08, 0.07)
const SHOCK_S: float = 0.4
const VERTS: int = 48
const GRIT: int = 18
const CRACK_ART: Texture2D = preload("res://features/souls/art/stomp_crack.png")
const CRACK_ART_PX_PER_M: float = 96.0
## The art spans +-3.1 m; grown so its branches reach the stomp radius (4 m).
const CRACK_SCALE: float = 1.3
const CRACK_HOLD_S: float = 2.0
const CRACK_FADE_S: float = 1.5


## Draws the marks of a stomp `age` seconds old at `c` (canvas px). `seed` turns the crack.
static func draw(
	ci: CanvasItem, c: Vector2, age: float, radius_m: float, ppm: float, seed: int
) -> void:
	_crack(ci, c, age, ppm, seed)
	SlamDebris.draw(ci, c, age, ppm, seed)  # n7-melee: chips, dust and the landing flash
	if age > SHOCK_S:
		return
	var k: float = age / SHOCK_S
	var r: float = radius_m * ppm * (1.0 - pow(1.0 - k, 3.0))
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in VERTS + 1:
		var a: float = TAU * i / VERTS
		var wob: float = 1.0 + 0.07 * sin(a * 7.0 + 1.3) + 0.04 * sin(a * 13.0)
		@warning_ignore("return_value_discarded")
		pts.push_back(c + Vector2.from_angle(a) * r * wob)
	ci.draw_polyline(pts, Color(INK, 1.0 - k), lerpf(9.0, 2.0, k))
	ci.draw_polyline(pts, Color(TEAL, 0.8 * (1.0 - k)), 1.5)
	for g: int in GRIT:
		var a: float = TAU * g / GRIT + 0.4 * sin(g * 2.1)
		var d: float = r * (0.55 + 0.5 * absf(sin(g * 3.7)))
		ci.draw_circle(c + Vector2.from_angle(a) * d, lerpf(3.0, 1.0, k), Color(INK, 1.0 - k))


static func _crack(ci: CanvasItem, c: Vector2, age: float, ppm: float, seed: int) -> void:
	var a_k: float = 1.0 - clampf((age - CRACK_HOLD_S) / CRACK_FADE_S, 0.0, 1.0)
	if a_k <= 0.0:
		return
	var k: float = CRACK_SCALE * ppm / CRACK_ART_PX_PER_M
	ci.draw_set_transform(c, TAU * fposmod(seed * 0.618, 1.0), Vector2(k, k))
	ci.draw_texture(CRACK_ART, -CRACK_ART.get_size() * 0.5, Color(1.0, 1.0, 1.0, a_k))
	ci.draw_set_transform(Vector2.ZERO)
