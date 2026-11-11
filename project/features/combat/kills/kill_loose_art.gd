class_name KillLooseArt
extends RefCounted
## The loose headgear of an n16 death with drawn cells (lane kills-new), render only. The pistol's
## drawn snap frame shows the cap or helmet leaving the head; at the next frame (`loose_at`, row fx)
## the asset lane's loose tumble cells take it over: it arcs back along the shot (`loose_m` past
## his feet over `loose_ticks`, a `loose_hop_m` hop), tumbling between its 2 drawn frames, and
## stays on the street behind him at `loose_size_m`. The row's `cells.loose` names the cells per
## view art and card row (KillDeathCells.path_in); a kind with none (a bare head) throws nothing.

const META: StringName = &"kill_loose"
const SCRAPS: StringName = &"kill_scraps"
## Ticks per tumble frame in the air.
const TUMBLE_TICKS: int = 3
## Where the drawn snap frame's cap flies, of his standing height above his feet.
const START_HEIGHT: float = 1.1


## Gives the body copy its loose headgear texture and the death's drawn scraps (the victim's card
## row in the view art; row `cells.loose` and `cells.scraps`).
static func attach(rig: CutRig, body: Node2D, extra: KillTrackRows.Extra) -> void:
	if rig == null or body == null or extra == null or rig.head_card == null:
		return  # no head card (the top view): no card row, so no drawn loose art
	var row: String = StreetWalkerCards.row_of(rig)
	_attach(body, extra.loose, row, META)
	_attach(body, extra.scraps, row, SCRAPS)


static func _attach(body: Node2D, table: Dictionary, row: String, key: StringName) -> void:
	var path: String = KillDeathCells.path_in(table, ViewMode.shared().art, row)
	if path.is_empty():
		return
	var tex: Texture2D = StreetStrips.get_tex(StreetWalkerCards.DIR + path)
	if tex != null:
		body.set_meta(key, tex)


## The loose headgear a body copy carries (null = none); `key` SCRAPS: its drawn scraps.
static func of(body: Node, key: StringName = META) -> Texture2D:
	if body == null or not body.has_meta(key):
		return null
	var t: Variant = body.get_meta(key)
	return t if t is Texture2D else null


## Layer px of the headgear at `age` (its arc from above his head to the street behind him).
static func where(d: KillNewStyles.Death, age: int, ppm: float) -> Vector2:
	var at: int = roundi(d.extra.num("loose_at", 8.0))
	var u: float = clampf(float(age - at) / maxf(1.0, d.extra.num("loose_ticks", 12.0)), 0.0, 1.0)
	var from: Vector2 = d.feet_px + d.dir * 0.15 * ppm
	var to: Vector2 = d.feet_px + d.dir * d.extra.num("loose_m", 1.1) * ppm
	var hop: float = d.extra.num("loose_hop_m", 0.4) * ppm
	var lift: float = d.height * START_HEIGHT * (1.0 - u) + 4.0 * hop * u * (1.0 - u)
	return from.lerp(to, u) + Vector2(0.0, -lift)


static func draw(ci: KillNewStyles, d: KillNewStyles.Death, age: int) -> void:
	if d.loose == null or age < roundi(d.extra.num("loose_at", 8.0)):
		return
	var landed: bool = (
		age >= roundi(d.extra.num("loose_at", 8.0) + d.extra.num("loose_ticks", 12.0))
	)
	var frame: int = 0 if landed else (age / TUMBLE_TICKS) % 2
	var cell: float = float(d.loose.get_height())
	var side: float = d.extra.num("loose_size_m", 0.3) * ci.ppm
	var c: Vector2 = where(d, age, ci.ppm)
	var dst: Rect2 = Rect2(c - Vector2(side, side) * 0.5, Vector2(side, side))
	ci.draw_texture_rect_region(d.loose, dst, Rect2(frame * cell, 0.0, cell, cell))


## Cell `n` (wrapping) of a strip of square cells, `side` px across, centred on `xf`'s origin.
static func draw_cell(
	ci: CanvasItem, strip: Texture2D, n: int, xf: Transform2D, side: float
) -> void:
	var cell: float = float(strip.get_height())
	var count: int = maxi(1, floori(float(strip.get_width()) / cell))
	ci.draw_set_transform_matrix(xf)
	var dst: Rect2 = Rect2(Vector2(side, side) * -0.5, Vector2(side, side))
	ci.draw_texture_rect_region(strip, dst, Rect2(float(n % count) * cell, 0.0, cell, cell))
	ci.draw_set_transform_matrix(Transform2D.IDENTITY)
