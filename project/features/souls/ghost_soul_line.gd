class_name GhostSoulLine
extends RefCounted
## n15 hero (the n11 next step, colour law "teal only for souls"): a drawn ghost (GhostDrawn) gets a
## thin soul-teal outline, the glow its old card had: eight copies of the shown cell under the
## figure, nudged WIDTH_PX cell px out along the 8 directions, drawn as one flat teal silhouette
## (ghost_soul_line.gdshader, HaulerLook.TEAL at ALPHA). The copies follow the figure's cell,
## mirror, tilt and scale (children of its sprite). `--ghost-soul-line=off` (CastFlags) = none
## (the before). Render only.

const SHADER: String = "res://features/souls/ghost_soul_line.gdshader"
const NAME: StringName = &"soul_line"
const WIDTH_PX: float = 3.0
const ALPHA: float = 0.6
const COPIES: int = 8
static var enabled: bool = true
static var _mat: ShaderMaterial = null


## Puts the outline copies under `spr` (none when switched off).
static func attach(spr: Sprite2D) -> void:
	if not enabled:
		return
	if _mat == null:
		_mat = ShaderMaterial.new()
		_mat.shader = load(SHADER) as Shader
		_mat.set_shader_parameter(&"line", Color(HaulerLook.TEAL, ALPHA))
	for i: int in COPIES:
		var c: Sprite2D = Sprite2D.new()
		c.name = NAME
		c.set_meta(NAME, true)  # a duplicate name is renamed: the meta marks every copy
		c.material = _mat
		c.centered = false
		c.show_behind_parent = true
		c.texture_filter = spr.texture_filter
		c.position = Vector2.from_angle(i * TAU / COPIES) * WIDTH_PX
		spr.add_child(c)


## Gives the copies the cell `spr` shows now (after GhostSheet.show).
static func sync(spr: Sprite2D) -> void:
	for n: Node in spr.get_children():
		var c: Sprite2D = n as Sprite2D
		if c == null or not c.has_meta(NAME):
			continue
		if c.texture != spr.texture or c.hframes != spr.hframes or c.vframes != spr.vframes:
			c.frame = 0
			c.texture = spr.texture
			c.hframes = spr.hframes
			c.vframes = spr.vframes
		c.offset = spr.offset
		c.frame = spr.frame
		c.flip_h = spr.flip_h
