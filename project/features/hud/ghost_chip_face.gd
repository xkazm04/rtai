class_name GhostChipFace
extends RefCounted
## Each ghost's avatar on the ghost HUD (GhostFormHud): frame 0 (facing the camera) of the ghost's
## shipped p55 card strip, cut to its own silhouette by tools/art/ghost_chip_cut.py
## (art/ghost_chips/<id>.png, 84 px; n11: no disc behind it, the owner's "avatars with transparent
## background"). A HUD icon, the same in every view. `rim` inks a silhouette round the avatar so it
## holds on any ground; the current form's rim is soul teal.

## false = the D5 glyphs (GhostFormHud._chip).
const FACES: bool = true
const DIR: String = "res://features/hud/art/ghost_chips/"
## Rim stamps round the avatar: enough directions that a 3 px rim stays round.
const RIM_STEPS: int = 12

static var _cache: Dictionary[StringName, Texture2D] = {}


## The face texture of ghost `id`, or null (no cut: the caller draws the glyph).
static func face(id: StringName) -> Texture2D:
	if not FACES:
		return null
	if not _cache.has(id):
		var path: String = DIR + String(id) + ".png"
		_cache[id] = load(path) as Texture2D if ResourceLoader.exists(path) else null
	return _cache[id]


## Draws ghost `id`'s avatar at `c`, `r` from centre to frame edge; false when it has none.
static func draw(
	ci: CanvasItem, id: StringName, c: Vector2, r: float, tint: Color = Color.WHITE
) -> bool:
	var tex: Texture2D = face(id)
	if tex == null:
		return false
	ci.draw_texture_rect(tex, Rect2(c - Vector2(r, r), Vector2(r, r) * 2.0), false, tint)
	return true


## The avatar's silhouette grown by `px` in `color` (draw it before the avatar).
static func rim(ci: CanvasItem, id: StringName, c: Vector2, r: float, ink: Array[Variant]) -> void:
	var tex: Texture2D = face(id)
	if tex == null:
		return
	var color: Color = ink[0]
	var px: float = ink[1]
	for k: int in RIM_STEPS:
		var off: Vector2 = Vector2.from_angle(TAU * float(k) / float(RIM_STEPS)) * px
		ci.draw_texture_rect(tex, Rect2(c + off - Vector2(r, r), Vector2(r, r) * 2.0), false, color)
