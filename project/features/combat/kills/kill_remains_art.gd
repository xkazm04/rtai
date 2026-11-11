class_name KillRemainsArt
extends RefCounted
## n16 kills-polish item 3 (asset lane A7, it434; KILLS: the ray gun left a plain dust heap): what
## the ray gun leaves is drawn: a grey-cream ash heap with a half-sunk skull, rib arcs and a
## forearm bone, the empty clothes crumpled flat beside it (cop navy for a cop, grey for anyone
## else). The heap sits where the man stood, the clothes downstream along the ray; it grows as the
## ring eats him, and its amber cracks cool as the plain heap's glow does. Render only, no RNG.
## `--ray-remains=plain` = the before (KillDustPile's procedural heap).

const ART: Texture2D = preload("res://features/combat/weapons/art/gore/ray_remains.png")
## The cells (tools/art/ray_remains_cells.py): navy hot, navy cool, grey hot, grey cool.
const NAVY: int = 0
const GREY: int = 2
## The whole sticker's width on the street (m) and the heap's centre in the cell (fraction of the
## cell's size from its centre: the heap is the left half, the clothes the right).
const WIDE_M: float = 1.7
const HEAP_AT: Vector2 = Vector2(-0.227, 0.05)
## Street kinds whose clothes are the navy set (KillXray's kinds).
const COPS: Array[String] = ["cop_patrol", "cop_riot", "swat"]

static var _plain: int = -1


## True under `--ray-remains=plain` (the procedural heap: the before).
static func plain() -> bool:
	if _plain < 0:
		_plain = 1 if ArenaArgs.parse().text("--ray-remains") == "plain" else 0
	return _plain == 1


## The set's first cell for a victim of KillXray kind `kind` ("" = unknown: grey).
static func set_of(kind: String) -> int:
	return NAVY if COPS.has(kind) else GREY


## Draws the remains with the heap at `p` (px), the clothes along `axis`; `k` = (grown 0..1, ppm,
## glow 0.25..1 as KillDustPile's), `first` the set's hot cell.
static func draw(ci: CanvasItem, p: Vector2, axis: Vector2, k: Vector3, first: int) -> void:
	var g: float = k.x
	if g <= 0.0:
		return
	var cw: float = ART.get_width() / 4.0
	var ch: float = ART.get_height()
	var w: float = WIDE_M * k.y * g
	var h: float = w * ch / cw
	var flip: float = -1.0 if axis.x < 0.0 else 1.0
	ci.draw_set_transform(p, 0.0, Vector2(flip, 1.0))
	var at: Rect2 = Rect2(-HEAP_AT * Vector2(w, h) - Vector2(w, h) * 0.5, Vector2(w, h))
	ci.draw_texture_rect_region(ART, at, Rect2(cw * (first + 1), 0.0, cw, ch))
	var hot: float = clampf((k.z - 0.25) / 0.75, 0.0, 1.0)
	ci.draw_texture_rect_region(ART, at, Rect2(cw * first, 0.0, cw, ch), Color(1, 1, 1, hot))
	ci.draw_set_transform(Vector2.ZERO)
