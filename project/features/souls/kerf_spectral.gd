class_name KerfSpectral
extends Node2D
## The cutter head around the flight body's centre. Its host supplies ground facing and tick state.

enum Mood { POISED, CRUISE, LUNGE }

const LUNGE_TICKS: int = 8
const ART: String = "res://features/souls/art/kerf/spectral/"
## cut.json packs both tilted grids at the old 1.8 m figure's 165 pixels.
const GRID_PX_PER_M: float = 165.0 / 1.8

var beams: KerfBeams = KerfBeams.new()
var _top: Node2D = Node2D.new()
var _lens: Sprite2D
var _tilted: Sprite2D = Sprite2D.new()
var _sheet: GhostSheet
var _art: String = "?"
var _hull_m: float
var _eyes: Array[Texture2D] = []


func _init(hull_m: float) -> void:
	_hull_m = hull_m


static func mood(speed_mps: float, ticks_since_blink: int, _charges: int) -> int:
	if ticks_since_blink >= 0 and ticks_since_blink < LUNGE_TICKS:
		return Mood.LUNGE
	return Mood.CRUISE if speed_mps > 3.0 else Mood.POISED


func _ready() -> void:
	add_child(beams)
	add_child(_top)
	_part("cables", 0.66, Vector2(-0.60, 0.0)).rotation = -PI / 2.0
	for side: int in [-1, 1]:
		_part("arm", 0.72, Vector2(0.0, side * 0.54)).rotation = side * deg_to_rad(7.0)
	@warning_ignore("return_value_discarded")
	_part("hull", _hull_m, Vector2.ZERO)
	# Nose socket (281,154) in the centred 375 x 313 hull, with a 62 px bezel.
	_lens = _part("lens_open", _hull_m * 62.0 / 375.0, Vector2(93.5, -2.5) * _hull_m / 375.0)
	_eyes = [_lens.texture, load(ART + "lens_half.png"), load(ART + "lens_slit.png")]
	_tilted.name = &"ghost_drawn"
	_tilted.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(_tilted)


func pose(speed_mps: float, since: int, locked: bool, facing: float, oct: int) -> void:
	var vm: ViewMode = ViewMode.shared()
	if vm.art != _art:
		_art = vm.art
		_sheet = null
		if _art in ["p70", "p55"]:
			_sheet = GhostSheet.of(GhostDrawn.path_of(_art, "kerf", "hover"), 3)
			if _sheet == null:
				Log.error("kerf", "missing %s hover grid" % _art)
		_tilted.visible = _sheet != null
		_top.visible = _sheet == null
	var col: int = mood(speed_mps, since, beams.charges)
	beams.fast = clampf(speed_mps / 12.0, 0.0, 1.0)
	beams.tail_x = -0.55 * SimConst.PX_PER_M * absf(global_scale.x)
	beams.global_transform = Transform2D(facing, global_position)
	beams.queue_redraw()
	if _sheet != null:
		_sheet.show(_tilted, oct, col)
		_tilted.offset = Vector2.ZERO  # GhostSheet normally anchors at the feet.
		var s: float = SimConst.PX_PER_M * absf(global_scale.x) / GRID_PX_PER_M
		_tilted.global_transform = Transform2D(
			0.0, Vector2(s, s / vm.ground_k()), 0.0, global_position
		)
	else:
		_top.global_rotation = facing
		_top.scale = Vector2.ONE.lerp(Vector2(1.08, 0.86), beams.fast)
		var eye: int = Mood.LUNGE if beams.charges == 0 else col
		_lens.texture = _eyes[Mood.CRUISE if eye == Mood.POISED and locked else eye]


func _part(part: String, width_m: float, at_m: Vector2) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = load(ART + part + ".png") as Texture2D
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	sprite.scale = Vector2.ONE * width_m * SimConst.PX_PER_M / sprite.texture.get_width()
	sprite.position = at_m * SimConst.PX_PER_M
	_top.add_child(sprite)
	return sprite
