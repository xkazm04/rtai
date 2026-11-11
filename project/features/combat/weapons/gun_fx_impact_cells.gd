class_name GunFxImpactCells
extends RefCounted
## n15 combat (brief item 4, impacts by surface; n11 "not done"): where a round stops on the ground,
## the asset lane's drawn impact (it317 fx_impacts_70 take a, A: concrete dust with chips;
## tools/art/impact_cells.py) instead of GunFxMarks' four grey dust dots. Its metal sparks wait for
## a film of a round on metal (the crates keep GunFxMarks' strokes). Drawn travelling right, so the
## cell turns to point back along the round (the debris flies toward the shooter); it opens from
## OPEN_K of its span to the whole over the first GROW of the impact's life and fades over the
## rest. A body keeps its ink burst and Rivet's plating its cream strokes (GunFxMarks): the FX
## print lies under the rigs, so a drawn cell on him hid under him (filmed: city t363, only its
## rim showed round his hip). Render only. `--impact-fx=shapes` = the before.

const DIR: String = "res://features/combat/weapons/art/fx/"
const FILES: Dictionary[int, String] = {
	GunFx.Hit.GROUND: "impact_dust.png",
}
## The cell's longest side (m) per surface at full size.
const SPAN_M: Dictionary[int, float] = {
	GunFx.Hit.GROUND: 0.75,
}
## Where the round stopped in the cell (fractions of its width and height): the burst's heart, left
## of the debris the cell throws right.
const HIT_AT: Vector2 = Vector2(0.32, 0.5)
const OPEN_K: float = 0.55
const GROW: float = 0.3

static var _tex: Dictionary[String, Texture2D] = {}
static var _shapes: int = -1


## Draws the drawn impact of `kind` stopped at `at` (m) along `dir`, `age` ticks old; false = a
## body, the before flag, or no cell (GunFxMarks draws its shapes).
static func draw(ci: CanvasItem, at: Vector2, dir: Vector2, kind: int, age: int) -> bool:
	if _shapes < 0:
		_shapes = 1 if ArenaArgs.parse().text("--impact-fx") == "shapes" else 0
	if _shapes == 1 or not FILES.has(kind):
		return false
	var tex: Texture2D = _load(FILES[kind])
	if tex == null:
		return false
	var k: float = clampf(float(age) / float(GunFx.IMPACT_TICKS), 0.0, 1.0)
	var size: Vector2 = tex.get_size() * (span_px(kind, tex) * open_of(k))
	var c: Color = Color(1.0, 1.0, 1.0, fade_of(k))
	var back: Vector2 = -dir if dir != Vector2.ZERO else Vector2.LEFT
	ci.draw_set_transform(Ink.px(at), back.angle())
	ci.draw_texture_rect(tex, Rect2(-size * HIT_AT, size), false, c)
	ci.draw_set_transform(Vector2.ZERO)
	return true


## Cell px -> world px at full size: the longest side spans SPAN_M.
static func span_px(kind: int, tex: Texture2D) -> float:
	return float(SPAN_M[kind]) * Ink.PX_PER_M / maxf(tex.get_width(), tex.get_height())


## The cell's scale at `k` (0..1 of the impact's life): OPEN_K to 1 over GROW, eased out.
static func open_of(k: float) -> float:
	var t: float = clampf(k / GROW, 0.0, 1.0)
	return lerpf(OPEN_K, 1.0, 1.0 - (1.0 - t) * (1.0 - t))


## Its alpha: whole through GROW, then down to 0 at the end of the impact's life.
static func fade_of(k: float) -> float:
	return 1.0 - clampf((k - GROW) / (1.0 - GROW), 0.0, 1.0)


static func _load(file: String) -> Texture2D:
	if not _tex.has(file):
		var path: String = DIR + file
		_tex[file] = load(path) as Texture2D if ResourceLoader.exists(path) else null
	return _tex[file]
