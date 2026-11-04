class_name WeaponFxColour
extends RefCounted
## n5-look: the weapon FX cells in colour (target r2_w4). WeaponFxArt draws every cell onto this
## canvas item (a child of the host FX view) instead of the host while it is attached; its
## material is look_d5_fx (the cell's own colour, the riso halftone and tooth, never blood red,
## never teal) instead of the actors' nearest-ink item print, which turned the colour cells
## vermilion and cream. Attached only while weapon_art.json `fx_colour_dir` is set, so "" is the
## whole before (ink cells under the item print). Render only.

const SHADER: String = "res://assets/shaders/look_d5_fx.gdshader"
const PARAMS: String = "res://assets/shaders/look_d5.params.json"
const PARAMS_KEY: String = "fx"

var rid: RID = RID()
var mat: ShaderMaterial = ShaderMaterial.new()


## A colour canvas under `parent` (drawn after its own commands), or null when the FX are ink.
static func attach(parent: CanvasItem, colour_dir: String) -> WeaponFxColour:
	if colour_dir == "":
		return null
	var c: WeaponFxColour = WeaponFxColour.new()
	c.mat.shader = load(SHADER)
	c._apply_params()
	c.rid = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(c.rid, parent.get_canvas_item())
	RenderingServer.canvas_item_set_material(c.rid, c.mat.get_rid())
	return c


## Once a frame before the host draws: last frame's cells cleared, the world lock and the page
## inks taken from the host's item print `host` (null keeps the shader's).
func begin(host: ShaderMaterial) -> void:
	RenderingServer.canvas_item_clear(rid)
	if host == null:
		return
	for p: StringName in [&"world_px", &"paper_tone", &"ink_tone"]:
		var v: Variant = host.get_shader_parameter(p)
		if v != null:
			mat.set_shader_parameter(p, v)


## One cell: `tex` with its `anchor` on the origin of `xf` (view px), alpha `a`.
func cell(tex: Texture2D, xf: Transform2D, anchor: Vector2, a: float) -> void:
	RenderingServer.canvas_item_add_set_transform(rid, xf)
	var rect: Rect2 = Rect2(-anchor, tex.get_size())
	RenderingServer.canvas_item_add_texture_rect(rid, rect, tex.get_rid(), false, Color(1, 1, 1, a))


func release() -> void:
	if rid.is_valid():
		RenderingServer.free_rid(rid)
	rid = RID()


func _apply_params() -> void:
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(PARAMS)) != OK or not parser.data is Dictionary:
		return
	var d: Dictionary = parser.data
	var u: Dictionary = d.get(PARAMS_KEY, {})
	for k: String in u:
		mat.set_shader_parameter(StringName(k), LookParams.uniform_value(u[k]))
