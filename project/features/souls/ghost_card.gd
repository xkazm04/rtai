class_name GhostCard
extends RefCounted
## View lab (docs/view-lab/PLAN.md): the upright facing card for a ghost rig that is not a CutRig
## (Tonnage's press). Under a tilted --view whose row has `cards` and `art` (data/tables/view.json),
## a rig whose card strip exists at ART_DIR/<art>/<name>_card.png draws that card (5 facings, the
## left 3 mirrored: RigHeadCard.frame_of) in place of its top-down body parts, standing upright at
## the lifted body point and undoing the camera's ground squash. Its limbs still draw (and walk)
## under it. A live art change (the combined view) rebuilds it. Render only. Straight down, or a
## view without art or without the strip, nothing is built and no part is touched: bit-identical.

const ART_DIR: String = "res://features/souls/art/view/"
const FRAMES: int = 5
const HALO_SHADER: String = "res://features/souls/ghost_card_halo.gdshader"
## The halo's size against the card (it is centred on the card's cell).
const HALO_K: float = 1.12

var card_name: String = ""
## The card's drawn width (metres at the rig's px per metre) and its anchor's height in the card
## (fraction of the card height from the top) that sits on the lifted body point.
var width_m: float = 1.0
var anchor_y: float = 0.5
## The rig's own size factor this pose (Tonnage's unfold), times width_m.
var size_k: float = 1.0
## The soul halo behind the card (its colour and alpha; alpha 0 = none): the card's silhouette in
## soul teal, HALO_K the card's size, so the possessed body keeps its teal read at height.
var halo: Color = Color(0.0, 0.0, 0.0, 0.0)
## The card's lean on screen (radians, + = top to screen right), about its anchor: a darting rig
## leans into its motion (Kerf). 0 = upright.
var lean: float = 0.0
var _spr: Sprite2D = null
var _art: String = ""


func _init(p_name: String, p_width_m: float, p_anchor_y: float) -> void:
	card_name = p_name
	width_m = p_width_m
	anchor_y = p_anchor_y


## Each pose (the rig's pose()): build the card when the view's art changes, then face and place
## it at `at` (rig-local px, the lifted body point). `parts` hide while the card draws.
func step(host: Node2D, parts: Array[Sprite2D], at: Vector2, px_per_m: float) -> void:
	var vm: ViewMode = ViewMode.shared()
	if vm.art != _art:
		_rebuild(host, parts, vm)
	if _spr == null:
		return
	var f: Vector2i = RigHeadCard.frame_of(host.global_rotation)
	_spr.frame = f.x
	_spr.flip_h = f.y == 1
	_spr.position = at
	if _spr.get_child_count() > 0:
		var h: Sprite2D = _spr.get_child(0) as Sprite2D
		h.frame = f.x
		h.flip_h = _spr.flip_h
	_spr.global_rotation = lean
	var cell_w: float = _spr.texture.get_width() / float(FRAMES)
	var s: float = width_m * size_k * px_per_m * absf(host.global_scale.x) / cell_w
	_spr.global_scale = Vector2(s, s / vm.ground_k())


func is_drawn() -> bool:
	return _spr != null


static func path_of(art: String, p_name: String) -> String:
	return ART_DIR.path_join(art).path_join(p_name + "_card.png")


func _rebuild(host: Node2D, parts: Array[Sprite2D], vm: ViewMode) -> void:
	var had: bool = _spr != null
	if had:
		_spr.queue_free()
		_spr = null
	_art = vm.art
	var path: String = path_of(_art, card_name)
	if vm.cards and _art != "" and ResourceLoader.exists(path):
		_spr = Sprite2D.new()
		_spr.name = &"ghost_card"
		_spr.texture = load(path) as Texture2D
		_spr.hframes = FRAMES
		_spr.centered = false
		var cell: Vector2 = Vector2(
			_spr.texture.get_width() / float(FRAMES), _spr.texture.get_height()
		)
		_spr.offset = Vector2(-cell.x * 0.5, -cell.y * anchor_y)
		_spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		if halo.a > 0.0:
			_spr.add_child(_halo(cell))
		host.add_child(_spr)
	if had or _spr != null:
		for p: Sprite2D in parts:
			p.visible = _spr == null


func _halo(cell: Vector2) -> Sprite2D:
	var h: Sprite2D = Sprite2D.new()
	h.name = &"halo"
	h.texture = _spr.texture
	h.hframes = FRAMES
	h.show_behind_parent = true
	h.position = Vector2(0.0, cell.y * (0.5 - anchor_y))
	h.scale = Vector2.ONE * HALO_K
	h.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var m: ShaderMaterial = ShaderMaterial.new()
	m.shader = load(HALO_SHADER) as Shader
	m.set_shader_parameter(&"tint", halo)
	h.material = m
	return h
