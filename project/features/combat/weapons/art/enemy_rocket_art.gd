class_name EnemyRocketArt
extends RefCounted
## The nose sits on the lifted shot line. Both textures use the cut's nozzle as their joint.

const BODY: Texture2D = preload("res://features/combat/weapons/art/enemy_rocket_body.png")
const GLOW: Texture2D = preload("res://features/combat/weapons/art/enemy_rocket_glow.png")
const GLOW_TINT: Color = Color(EnemyRoundLook.LARGE_RIM, 0.46)
const CUT: JSON = preload("res://features/combat/weapons/art/enemy_rocket_cut.json")
const PLUMES: Array[Texture2D] = [
	preload("res://features/combat/weapons/art/enemy_rocket_exhaust_0.png"),
	preload("res://features/combat/weapons/art/enemy_rocket_exhaust_1.png"),
	preload("res://features/combat/weapons/art/enemy_rocket_exhaust_2.png"),
]
static var nozzle: Vector2 = Vector2(CUT.data.nozzle_px[0], CUT.data.nozzle_px[1])
static var scale_px: float = Ink.PX_PER_M / float(CUT.data.px_per_m)
static var glow_offset: Vector2 = (BODY.get_size() - GLOW.get_size()) * 0.5


static func exhaust(tick: int) -> Texture2D:
	return PLUMES[tick % PLUMES.size()]


static func draw(rid: RID, head: Vector2, dir: Vector2, went: float, tick: int) -> void:
	_smoke(rid, head, dir, went, tick)
	var xf: Transform2D = Transform2D(dir.angle(), Ink.px(head)).scaled_local(
		Vector2.ONE * scale_px
	)
	RenderingServer.canvas_item_add_set_transform(rid, xf)
	var body_at: Vector2 = -Vector2(BODY.get_width(), nozzle.y)
	var jet: Texture2D = exhaust(tick)
	var jet_at: Vector2 = body_at + nozzle - Vector2(jet.get_width(), jet.get_height() * 0.5)
	GLOW.draw(rid, body_at + glow_offset, GLOW_TINT)
	jet.draw(rid, jet_at)
	BODY.draw(rid, body_at)
	RenderingServer.canvas_item_add_set_transform(rid, Transform2D.IDENTITY)


## The cased rocket keeps alternate puffs at reduced opacity on its lifted flight line.
static func _smoke(rid: RID, head: Vector2, dir: Vector2, went: float, tick: int) -> void:
	var side: Vector2 = dir.orthogonal()
	for k: int in range(0, 7, 2):
		var back: float = 0.9 + float(k) * 0.5
		if back > went:
			break
		var wob: Vector2 = side * sin(float(tick - k * 3) * 0.9) * 0.1 * float(k)
		var radius: float = (0.16 + 0.08 * float(k)) * Ink.PX_PER_M
		var c: Color = Color(EnemyRoundLook.LARGE_RIM, 0.22 * (1.0 - float(k) / 9.0))
		RenderingServer.canvas_item_add_circle(rid, Ink.px(head - dir * back + wob), radius, c)
