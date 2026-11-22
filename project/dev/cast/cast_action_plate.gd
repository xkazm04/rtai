class_name CastActionPlate
extends CastPlate

const TITLES: Array[String] = ["Walking", "Shoulder", "Locked aim", "Discharge", "Hit", "At rest"]
const ORIGIN: Vector2i = Vector2i(960, 540)

const DOOR_TITLES: Array[String] = ["Walking", "Plant", "Braced", "Shove", "Hit", "At rest"]
var _door: bool
var _panel: Vector2i
var _photos: Array[Texture2D] = []


func _expose() -> bool:
	var shot: Image = get_viewport().get_texture().get_image()
	var start: Vector2i = ORIGIN - Vector2i(roundi(_panel.x * 0.5), _ppm * 3)
	var crop: Image = shot.get_region(Rect2i(start, _panel))
	_matte = crop.get_pixel(0, 0)
	_photos.append(ImageTexture.create_from_image(crop))
	return true


func _size() -> Vector2i:
	return Vector2i(2 * _panel.x + 72, 3 * (_panel.y + 32) + 94)


func _draw_plate() -> void:
	_canvas.draw_rect(Rect2(Vector2.ZERO, Vector2(_size())), _matte)
	_text(Vector2(24, 34), tr("RTAI / Door carrier") if _door else tr("RTAI / Lancer"), 26)
	var ref: String = tr("Rivet and patrol reference  /  %d px/m  /  %d deg")
	_text(Vector2(24, 58), ref % [_ppm, _pitch], 16)
	for i: int in TITLES.size():
		var col: int = i % 2
		var line: int = floori(i / 2.0)
		var at: Vector2 = Vector2(24 + col * (_panel.x + 24), 94 + line * (_panel.y + 32))
		_text(at, tr((DOOR_TITLES if _door else TITLES)[i]), 17)
		_canvas.draw_texture(_photos[i], at + Vector2.DOWN * 4)
