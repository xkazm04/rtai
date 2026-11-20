class_name KerfChargeSlots
extends RefCounted
## Each mask follows one printed lamp. The atlas uses four poses across and five facings down.

const CUT_META: String = "res://features/souls/art/kerf/ronin/cut.json"
const MASKS: String = "res://features/souls/art/kerf/ronin/slot_masks.png"
const SHEETS: Array[String] = [
	"kerf_sp_fly_70", "kerf_sp_act_70", "kerf_sp_fly_55", "kerf_sp_act_55"
]
const TOP: int = 4
const STEEL: Color = Color("#304744")
const RELIGHT: Color = Color("#d6fff5")


class Cell:
	var centre: Vector2
	var slots: PackedVector2Array = []

	func _init(data: Dictionary) -> void:
		var xy: Array = data["alpha_mass_center"]
		centre = _point(xy)
		for point: Array in data["slots"]:
			@warning_ignore("return_value_discarded")
			slots.append(_point(point))

	func _point(pair: Array) -> Vector2:
		var x: float = pair[0]
		var y: float = pair[1]
		return Vector2(x, y)


static var _cells: Array[Cell] = []

var masks: Array[Sprite2D] = []
var plate: Sprite2D


static func cell(sheet: int, frame: int) -> Cell:
	if _cells.is_empty():
		var cut: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(CUT_META))
		@warning_ignore("return_value_discarded")
		_cells.resize(81)
		for s: int in SHEETS.size():
			for entry: Dictionary in cut["sheets"][SHEETS[s]]["cells"]:
				var row: int = entry["facing"]
				var col: int = entry["pose"]
				_cells[s * 20 + row * 4 + col] = Cell.new(entry)
		var torso: Dictionary = cut["torso"]
		_cells[80] = Cell.new(torso)
	return _cells[sheet * 20 + frame]


## Lower source x is charge one. Reflecting the printed plate reflects the entire gauge.
static func tint(index: int, charges: int, recharge: float) -> Color:
	if index < charges:
		return Color.TRANSPARENT
	if index == charges:
		return STEEL.lerp(RELIGHT, smoothstep(0.93, 1.0, recharge))
	return STEEL


func bind(source: Sprite2D) -> void:
	plate = source
	var atlas: Texture2D = load(MASKS) as Texture2D
	for i: int in 3:
		var mask: Sprite2D = Sprite2D.new()
		mask.texture = atlas
		mask.hframes = 12
		mask.vframes = 21
		mask.hide()
		plate.add_child(mask)
		masks.append(mask)


func paint(sheet: int, charges: int, recharge: float) -> void:
	var points: PackedVector2Array = cell(sheet, plate.frame).slots
	var rect: Rect2 = plate.get_rect()
	for i: int in masks.size():
		var mask: Sprite2D = masks[i]
		var color: Color = tint(i, charges, recharge)
		mask.visible = i < points.size() and color.a > 0.0
		if not mask.visible:
			continue
		var at: Vector2 = points[i].round()
		if plate.flip_h:
			at.x = rect.size.x - at.x
		mask.position = rect.position + at
		mask.flip_h = plate.flip_h
		mask.frame_coords = Vector2i(plate.frame_coords.x * 3 + i, sheet * 5 + plate.frame_coords.y)
		mask.self_modulate = color
