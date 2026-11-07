class_name GhostChipFace
extends RefCounted
## n8-hud: each ghost's own face inside its chip on the ghost-form card (GhostFormHud), instead of
## the D5 ink glyph: frame 0 (facing the camera) of the ghost's shipped p55 card strip, cut to a
## disc by tools/art/ghost_chip_cut.py (art/ghost_chips/<id>.png, 84 px: 1:1 at 1080p). The chip's
## fill (teal for the current form, paper for the rest) shows as a ring round the face, so the
## current form still reads by colour as well as by size. A HUD icon, the same in every view.

## false = the D5 glyphs (GhostFormHud._glyph).
const FACES: bool = true
const DIR: String = "res://features/hud/art/ghost_chips/"
## The face's radius as a share of the chip's: the ring of fill left round it.
const INSET: float = 0.92

static var _cache: Dictionary[StringName, Texture2D] = {}


## The face texture of ghost `id`, or null (no cut: the caller draws the glyph).
static func face(id: StringName) -> Texture2D:
	if not FACES:
		return null
	if not _cache.has(id):
		var path: String = DIR + String(id) + ".png"
		_cache[id] = load(path) as Texture2D if ResourceLoader.exists(path) else null
	return _cache[id]


## Draws ghost `id`'s face into the chip at `c` of radius `r`; false when it has none.
static func draw(ci: CanvasItem, id: StringName, c: Vector2, r: float) -> bool:
	var tex: Texture2D = face(id)
	if tex == null:
		return false
	var fr: float = r * INSET
	ci.draw_texture_rect(tex, Rect2(c - Vector2(fr, fr), Vector2(fr, fr) * 2.0), false)
	return true
