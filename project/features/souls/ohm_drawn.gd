class_name OhmDrawn
extends RefCounted
## The spectral tilt uses the flight transform, shared action clock and facing hysteresis.
## The artist's foot anchor can sit well above the edge of a cell containing trailing cloth.

var charge: OhmCharge = OhmCharge.new()
var _sprite: Sprite2D
var _jars: OhmJars
var _art: String = "?"
var _hover: GhostSheet
var _act: GhostSheet
var _masks: Dictionary[Texture2D, Texture2D] = {}
var _cells: Dictionary[Texture2D, Array] = {}
var _anchor: Vector2


func step(host: Node2D, drawn: GhostDrawn, size_k: float) -> bool:
	var vm: ViewMode = ViewMode.shared()
	if vm.art != _art:
		_rebuild(host, vm)
	if _sprite == null:
		return false
	var hover: GhostHover = drawn.flight.hover if drawn.flight != null else null
	var col: int = drawn.act_col()
	var acting: bool = col >= 0
	if not acting:
		col = int(hover != null and hover.speed_mps > 0.5)
	var facing: float = host.global_rotation
	var sheet: GhostSheet = _act if acting else _hover
	sheet.show(_sprite, drawn.octant(facing), col)
	_sprite.offset = -_anchor
	var fit: float = drawn.height_m * size_k * SimConst.PX_PER_M * host.scale.x / drawn.fig_px
	_sprite.global_position = host.global_position
	_sprite.global_rotation = hover.lean * cos(facing) - 0.3 * hover.bank if hover != null else 0.0
	_sprite.global_scale = Vector2(fit, fit / vm.ground_k())
	if drawn.flight != null:
		_sprite.global_scale *= drawn.flight.body_scale()
	_overlay(sheet)
	return true


func _rebuild(host: Node2D, vm: ViewMode) -> void:
	if _sprite != null:
		host.remove_child(_sprite)
		_sprite.queue_free()
		_sprite = null
	_art = vm.art
	_masks.clear()
	_cells.clear()
	if not vm.cards or _art not in ["p55", "p70"]:
		return
	var dir: String = GhostDrawn.ART_DIR.path_join(_art)
	var meta: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(dir.path_join("ohm_spec_cells.json"))
	)
	_anchor = DataTable.new().vec(meta, "anchor_px")
	var idle: Dictionary = meta.sheets.hover
	var act: Dictionary = meta.sheets.act
	_hover = _sheet(dir, "hover", 2, idle)
	_act = _sheet(dir, "act", GhostDrawn.ACT_COLS, act)
	_sprite = Sprite2D.new()
	_sprite.name = &"ghost_drawn"
	_sprite.centered = false
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	host.add_child(_sprite)
	var glow: Sprite2D = halo(245.0, 0.24)
	glow.position.y = -86.0
	_sprite.add_child(glow)
	_jars = OhmJars.new()
	_sprite.add_child(_jars)


func _sheet(dir: String, kind: String, cols: int, layout: Dictionary) -> GhostSheet:
	var path: String = dir.path_join("ohm_spec_" + kind)
	var sheet: GhostSheet = GhostSheet.of(path + ".png", cols)
	_masks[sheet.tex] = load(path + "_jars.png") as Texture2D
	_cells[sheet.tex] = layout.jar_boxes_row_major
	return sheet


func _overlay(sheet: GhostSheet) -> void:
	_jars.match_cell(_sprite, _masks[sheet.tex])
	var base_y: float = _sprite.frame_coords.y * sheet.tex.get_height() / float(GhostDrawn.ROWS)
	var top: Vector3 = Vector3.ZERO
	var bottom: Vector3 = Vector3.ONE
	var boxes: Array = _cells[sheet.tex][_sprite.frame]
	for i: int in 3:
		if boxes[i] != null:
			var y0: float = boxes[i][1]
			var y1: float = boxes[i][3]
			top[i] = base_y + y0
			bottom[i] = base_y + y1
	_jars.bounds(top, bottom)
	_jars.light(Vector3(charge.jar(0), charge.jar(1), charge.jar(2)), charge.flash(), charge.vent())


static func halo(width: float, alpha: float) -> Sprite2D:
	var glow: Sprite2D = GhostRim.soft_glow(Color("#2ec4b6"), alpha, width)
	var blend: CanvasItemMaterial = CanvasItemMaterial.new()
	blend.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow.material = blend
	glow.show_behind_parent = true
	return glow
