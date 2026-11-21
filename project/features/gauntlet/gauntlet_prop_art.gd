class_name GauntletPropArt
extends RefCounted
## The city's front-facing cover art, fitted to the box it represents. Pavement fixtures keep
## the city's original facing and proportions, with their full image behind the roadside rail.

const FLAT: String = "res://features/city/art/props/%s.png"
static var _table: DataTable
static var _faces: Dictionary[String, GauntletPropArt] = {}

var image: Texture2D
var width_m: float
var _trimmed: Texture2D


static func cover(ci: CanvasItem, art: String, box: Rect2, scale_m: float) -> void:
	var face: GauntletPropArt = _face(art)
	if face.image != null:
		var pad: Rect2 = box.grow(-0.04)
		var size: Vector2 = (face._metres() * scale_m).min(pad.size)
		var foot: Vector2 = Vector2(pad.get_center().x, pad.end.y)
		ci.draw_texture_rect(
			face._cover_face(),
			GauntletFrontage.px(Rect2(foot - size * Vector2(0.5, 1.0), size)),
			false
		)


static func fixture(
	ci: CanvasItem, art: String, foot: Vector2, scale_m: float, walk: Rect2
) -> void:
	var face: GauntletPropArt = _face(art)
	if face.image == null:
		return
	var size: Vector2 = face._metres()
	scale_m = minf(scale_m, walk.size.y / size.y)
	size *= scale_m
	foot.y = clampf(foot.y, walk.position.y + size.y, walk.end.y)
	var cards: PropCards = PropCards.named()
	if cards != null and cards.draw_named(ci, art, Ink.px(foot), Ink.PX_PER_M * scale_m):
		return
	ci.draw_texture_rect(
		face.image, GauntletFrontage.px(Rect2(foot - size * Vector2(0.5, 1.0), size)), false
	)


## A city strip cell can be half transparent above a low bench. Fit the visible art, so its
## actual roof or seat occupies the footing instead of letting the padding consume the space.
func _cover_face() -> Texture2D:
	if _trimmed != null:
		return _trimmed
	_trimmed = image
	var cell: AtlasTexture = image as AtlasTexture
	if cell != null:
		var sheet: Image = cell.atlas.get_image()
		if sheet != null and (not sheet.is_compressed() or sheet.decompress() == OK):
			var used: Rect2i = sheet.get_region(Rect2i(cell.region)).get_used_rect()
			if used.has_area():
				var trim: AtlasTexture = AtlasTexture.new()
				trim.atlas = cell.atlas
				trim.region = Rect2(used)
				_trimmed = trim
	return _trimmed


func _metres() -> Vector2:
	var size: Vector2 = image.get_size()
	size *= width_m / size.x
	size.y /= ViewMode.shared().ground_k()
	return size


static func _face(art: String) -> GauntletPropArt:
	var view: ViewMode = ViewMode.shared()
	var look: String = "" if view.is_flat() or view.eye_h_m > 0.0 else view.art
	var key: String = look + "/" + art
	if _faces.has(key):
		return _faces[key]
	var face: GauntletPropArt = GauntletPropArt.new()
	_faces[key] = face
	if _table == null:
		_table = DataTable.open(PropCards.TABLE, "gtai.city-facades/1")
	var props: Dictionary = _table.object(_table.raw, "props")
	var row: Dictionary = props.get(art, {})
	if look != "" and not row.is_empty():
		var fallback: Dictionary = _table.object(_table.raw, "art_fallback")
		var strip: Texture2D = PropCards.art_texture(_table.text(row, "art"), look, fallback)
		if strip != null:
			var cell: AtlasTexture = AtlasTexture.new()
			cell.atlas = strip
			cell.region = Rect2(
				Vector2.ZERO,
				Vector2(strip.get_width() / float(PropCards.FACINGS), strip.get_height())
			)
			face.image = cell
			face.width_m = row.get("cell_w_m_" + look, row["cell_w_m"])
			return face
	if ResourceLoader.exists(FLAT % art):
		face.image = load(FLAT % art) as Texture2D
		face.width_m = face.image.get_width() / Ink.PX_PER_M
	return face
