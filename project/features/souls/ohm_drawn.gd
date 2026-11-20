class_name OhmDrawn
extends RefCounted
## The spectral tilt uses the flight transform, shared action clock and facing hysteresis.
## The artist's foot anchor can sit well above the edge of a cell containing trailing cloth.

var charge: OhmCharge = OhmCharge.new()
var _fork: OhmFork
var _forks: Dictionary[Texture2D, Array] = {}
var _sprite: Sprite2D
var _jars: OhmJars
var _hover: GhostSheet
var _masks: Dictionary[Texture2D, Texture2D] = {}
var _cells: Dictionary[Texture2D, Array] = {}
var _row: GhostHoverRow = GhostHoverRow.of(OhmStage.ID)
var _anchor: Vector2


func step(host: OhmRig, drawn: GhostDrawn, size_k: float) -> bool:
	if not drawn.step(host, [], SimConst.PX_PER_M, size_k):
		return false
	var shown: Sprite2D = drawn.sprite()
	if not is_instance_valid(_jars) or _jars.get_parent() != shown:
		_attach(shown)
	var hover: GhostHover = drawn.flight.hover if drawn.flight != null else null
	if not _masks.has(shown.texture):
		# Flight infers square pose cells. Both authored Ohm hover grids are rectangular.
		var drift: bool = hover != null and hover.speed_mps >= GhostDrawn.SPEC_CRUISE_MPS
		_hover.show(shown, drawn.octant(host.global_rotation), int(drift))
		# Release the fallback cell's belt socket and material on the authored robe.
		drawn.release_fade()
	shown.offset = -_anchor
	GhostSoulLine.sync(shown)
	if hover != null:
		var motion: float = 0.5 if host.reduced_motion else 1.0
		shown.global_rotation += drawn.flight.body_rotation()
		shown.global_rotation += OhmDrift.sway(host.tick, hover.speed_mps / _row.top_mps) * motion
		pin_tail(drawn.flight, shown.to_global(Vector2(0.0, -9.0)))
	_fork.stage = host.ohm
	_fork.vent = charge.vent()
	var tips: PackedVector2Array = _forks[shown.texture][shown.frame]
	_fork.place(shown, tips)
	_overlay()
	return true


## The flight integrates the ribbon in ground space. Translate the drawing from its neutral
## anchor to the actual hem (the artist's anchor on a tilt, the lagging cloth tip from above).
static func pin_tail(flight: GhostFlight, tip: Vector2) -> void:
	if flight.hover.tick == 0:
		return  # The rig can mount before flight has stepped its ribbon.
	var points: PackedVector2Array = flight.tail.points()
	if not points.is_empty():
		flight.tail.position += flight.to_local(tip) - flight.to_local(points[0])


func _attach(shown: Sprite2D) -> void:
	_sprite = shown
	_masks.clear()
	_cells.clear()
	_forks.clear()
	var dir: String = GhostDrawn.ART_DIR.path_join(ViewMode.shared().art)
	var meta: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(dir.path_join("ohm_spec_cells.json"))
	)
	_anchor = DataTable.new().vec(meta, "anchor_px")
	_hover = GhostSheet.of(dir.path_join("ohm_spec_hover.png"), 2)
	_masks[_hover.tex] = load(dir.path_join("ohm_spec_hover_jars.png")) as Texture2D
	_cells[_hover.tex] = meta.sheets.hover.jar_boxes_row_major
	var act: Texture2D = load(dir.path_join("ohm_spec_act.png")) as Texture2D
	_masks[act] = load(dir.path_join("ohm_spec_act_jars.png")) as Texture2D
	_cells[act] = meta.sheets.act.jar_boxes_row_major
	var hover_rows: Array = meta.sheets.hover.forks_row_major
	_forks[_hover.tex] = hover_rows.map(OhmFork.unpack)
	var act_rows: Array = meta.sheets.act.forks_row_major
	_forks[act] = act_rows.map(OhmFork.unpack)
	_fork = OhmFork.new()
	_sprite.add_child(_fork)
	var glow: Sprite2D = halo(245.0, 0.24)
	glow.position.y = -86.0
	_sprite.add_child(glow)
	_jars = OhmJars.new()
	_sprite.add_child(_jars)


func _overlay() -> void:
	var tex: Texture2D = _sprite.texture
	_jars.match_cell(_sprite, _masks[tex])
	var base_y: float = _sprite.frame_coords.y * tex.get_height() / float(GhostDrawn.ROWS)
	var top: Vector3 = Vector3.ZERO
	var bottom: Vector3 = Vector3.ONE
	var boxes: Array = _cells[tex][_sprite.frame]
	for i: int in 3:
		if boxes[i] != null:
			var y0: float = boxes[i][1]
			var y1: float = boxes[i][3]
			top[i] = base_y + y0
			bottom[i] = base_y + y1
	_jars.bounds(top, bottom)
	_jars.light(Vector3(charge.jar(0), charge.jar(1), charge.jar(2)), 0.0, charge.vent())


static func halo(width: float, alpha: float) -> Sprite2D:
	var glow: Sprite2D = GhostRim.soft_glow(Color("#2ec4b6"), alpha, width)
	var blend: CanvasItemMaterial = CanvasItemMaterial.new()
	blend.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow.material = blend
	glow.show_behind_parent = true
	return glow
