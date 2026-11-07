class_name StreetCrowdCorpse
extends RefCounted
## Lane n8 street: a far corpse under a card view. The baked crowd atlas (CrowdBaker) captures each
## look's DEATH clip from the real rig straight down, so under a raised camera its last cell (the
## corpse the people layer keeps drawing) reads as a thin black bar on the blood. Under a view row
## with `cards`, stamp() replaces that cell with the look's drawn lying frame (StreetWalkerFall's
## grid for the look's card row, the side facing, the last frame), turned to lie along the cell's +y
## with the head that way, as the baked parts' death pose lies, its body centred on the actor
## point, scaled down only as far as the cell needs. Straight down (`top`) the atlas is untouched.

const ENABLED: bool = true
const DIR: String = "res://features/characters/art/view/"
## The fall grid's side facing (RigHeadCard frame 2: drawn facing +x, fallen forward).
const SIDE: int = 2
## The share of the cell the body may span (the rest: the bilinear edge and the quad's rim).
const FIT: float = 0.95


## Stamps every look's lying frame into `image` (the atlas being baked) when the view draws cards.
static func stamp(image: Image, rigs: Array[CutRig]) -> void:
	var view: ViewMode = ViewMode.shared()
	if not ENABLED or not view.cards:
		return
	var death: int = CrowdAtlas.Clip.DEATH
	var col: int = CrowdAtlas.CLIP_FIRST[death] + CrowdAtlas.FRAMES[death] - 1
	for look: int in rigs.size():
		var rig: CutRig = rigs[look]
		var row: String = RigHeadCard.key_of(rig.plan, rig.variant.head) if rig.variant else ""
		var lying: Image = lying_cell(view.art, row)
		if lying != null:
			_blit(image, lying, col, look)


## The lying frame for `row` under `art` (or StreetWalkerFall.FALLBACK's), cropped to the body and
## scaled to atlas px; null = no drawn fall for the row.
static func lying_cell(art: String, row: String) -> Image:
	var own: Dictionary = StreetWalkerFall.FALLS.get(art, {})
	var from: String = art if own.has(row) else StreetWalkerFall.FALLBACK
	var rows: Dictionary = StreetWalkerFall.FALLS.get(from, {})
	if not rows.has(row):
		return null
	var tex: Texture2D = load(DIR + from + "/" + str(rows[row])) as Texture2D
	if tex == null:
		return null
	var grid: Image = tex.get_image()
	if grid.is_compressed() and grid.decompress() != OK:
		return null
	grid.convert(Image.FORMAT_RGBA8)
	var n: int = StreetWalkerFall.FALL_FRAMES
	var cell: Vector2i = Vector2i(grid.get_width() / RigHeadCard.FRAMES, grid.get_height() / n)
	var frame: Image = grid.get_region(Rect2i(cell.x * SIDE, cell.y * (n - 1), cell.x, cell.y))
	var body: Image = frame.get_region(frame.get_used_rect())
	var h: float = StreetWalkerCards.HEIGHT_BY_ART.get(from, StreetWalkerCards.HEIGHT_M)
	var k: float = h * CharacterRigs.PX_PER_M / StreetWalkerFall.STILL_PX * CrowdAtlas.BAKE_ZOOM
	var room: float = CrowdAtlas.CELL_PX * FIT
	k = minf(k, room / maxf(body.get_width(), body.get_height()))
	var size: Vector2i = Vector2i(
		maxi(1, roundi(body.get_width() * k)), maxi(1, roundi(body.get_height() * k))
	)
	body.resize(size.x, size.y, Image.INTERPOLATE_LANCZOS)
	body.rotate_90(CLOCKWISE)  # the drawn head (+x) to the bake's (+y)
	return body


## Clears the atlas cell (col, look) and draws `body` centred on the rig's point in it.
static func _blit(image: Image, body: Image, col: int, look: int) -> void:
	var cell: int = CrowdAtlas.CELL_PX
	var origin: Vector2i = Vector2i(col * cell, look * cell)
	image.fill_rect(Rect2i(origin, Vector2i(cell, cell)), Color(0.0, 0.0, 0.0, 0.0))
	# CrowdBaker stands each rig at (0.5, 0.55) of its cell
	var at: Vector2i = Vector2i(roundi(cell * 0.5), roundi(cell * 0.55)) - body.get_size() / 2
	at = at.clamp(Vector2i.ZERO, Vector2i(cell, cell) - body.get_size())
	image.blend_rect(body, Rect2i(Vector2i.ZERO, body.get_size()), origin + at)
