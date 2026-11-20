class_name KerfRoninDrawn
extends Sprite2D
## Four flight and four action cells in each pitch. The art's measured centre rides the mount.

enum Pose { HOVER, CRUISE, TURN, HIT, COCK, CUT, RECOVER, BLINK }

const CRUISE_MPS: float = 3.0
const TURN_DPS: float = 360.0
const CUT_META: String = "res://features/souls/art/kerf/ronin/cut.json"

static var _centres: Dictionary[String, PackedVector2Array] = {}

var _fly: GhostSheet
var _act: GhostSheet
var _fly_centres: PackedVector2Array
var _act_centres: PackedVector2Array
var _art: String = ""
var _rim: Sprite2D = Sprite2D.new()


func _init() -> void:
	name = &"ghost_drawn"
	centered = false
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_rim.name = RigBuild.HALO
	_rim.centered = false
	_rim.show_behind_parent = true
	var pale: ShaderMaterial = ShaderMaterial.new()
	pale.shader = preload("res://features/souls/ghost_apparition.gdshader")
	pale.set_shader_parameter(&"silhouette", 1.0)
	pale.set_shader_parameter(&"band_k", 0.0)
	_rim.material = pale
	_rim.scale = Vector2.ONE * 1.055
	_rim.hide()
	add_child(_rim)


static func pose(speed: float, yaw: float, blink: Pose, locked: bool, hurt: bool) -> Pose:
	if blink != Pose.HOVER:
		return blink
	if hurt:
		return Pose.HIT
	if locked and speed <= CRUISE_MPS:
		return Pose.COCK
	if absf(yaw) > TURN_DPS:
		return Pose.TURN
	return Pose.CRUISE if speed > CRUISE_MPS else Pose.HOVER


func show_pose(oct: int, current: Pose, yaw: float, lean: float, flinch: bool) -> void:
	var vm: ViewMode = ViewMode.shared()
	if vm.art != _art:
		_load_pitch(vm.art)
	var acting: bool = current >= Pose.COCK
	var sheet: GhostSheet = _act if acting else _fly
	sheet.show(self, oct, current - Pose.COCK if acting else current)
	if current == Pose.TURN and yaw < 0.0:
		flip_h = not flip_h
	var centre: Vector2 = (_act_centres if acting else _fly_centres)[frame]
	if flip_h:
		centre.x = get_rect().size.x - centre.x
	offset = -centre
	# The packed profile helmets match Dent at 90 px (70 degrees) and 77 px (55 degrees).
	var ratio: float = 70.0 / 77.0 if _art == "p55" else 77.0 / 90.0
	var w: float = 1.8 / 176.5 * ratio
	var h: float = 1.45 / (212.0 if _art == "p55" else 223.0)
	rotation = lean
	scale = Vector2(w, h / vm.ground_k()) * SimConst.PX_PER_M
	_rim.visible = flinch
	if _rim.visible:
		sheet.show(_rim, oct, frame_coords.x)
		_rim.offset = offset


func _load_pitch(art: String) -> void:
	if _centres.is_empty():
		var cut: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(CUT_META))
		var sheets: Dictionary = cut["sheets"]
		for key: String in sheets:
			var centres: PackedVector2Array = []
			@warning_ignore("return_value_discarded")
			centres.resize(4 * GhostDrawn.ROWS)
			for cell: Dictionary in sheets[key]["cells"]:
				var xy: Array = cell["alpha_mass_center"]
				var row: int = cell["facing"]
				var col: int = cell["pose"]
				var x: float = xy[0]
				var y: float = xy[1]
				centres[row * 4 + col] = Vector2(x, y)
			_centres[key] = centres
	_art = art
	_fly = GhostSheet.of(GhostDrawn.path_of(art, "kerf", "sp_fly"), 4)
	_act = GhostSheet.of(GhostDrawn.path_of(art, "kerf", "sp_act"), 4)
	_fly_centres = _centres["kerf_sp_fly_" + art.trim_prefix("p")]
	_act_centres = _centres["kerf_sp_act_" + art.trim_prefix("p")]
