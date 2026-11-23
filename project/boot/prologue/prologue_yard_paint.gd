class_name PrologueYardPaint
extends RefCounted
## Draws into the floor canvas in stage order. No physics or navigation objects live here.

const OCHRE: Shader = preload("res://boot/prologue/art/yard_ochre.gdshader")

var _textures: Dictionary[String, Texture2D] = {}


func texture(path: String) -> Texture2D:
	if not _textures.has(path):
		_textures[path] = load(path) as Texture2D
	return _textures[path]


## The world pass prints neutral washes. Keep the source pigment on a static second impression
## below the actor canvas, including its blood and shadows. Both impressions use the same geometry.
func attach_ochre(floor_view: Node2D, plan: PrologueYard) -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = RenderLayers.canvas(&"actors")
	layer.follow_viewport_enabled = true
	floor_view.add_child(layer)
	RenderingServer.viewport_set_canvas_stacking(
		floor_view.get_viewport().get_viewport_rid(), layer.get_canvas(), layer.layer, -1
	)
	var ink: Node2D = Node2D.new()
	ink.transform = floor_view.global_transform
	ink.z_index = RenderLayers.z(&"blood")
	ink.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var look: PrologueYardDressing = plan.dressing
	var marks: Array[PrologueYardDressing.Piece] = []
	for piece: PrologueYardDressing.Piece in look.outside + look.decals + look.factory_front:
		if piece.ochre:
			marks.append(piece)
	var pigment: ShaderMaterial = ShaderMaterial.new()
	pigment.shader = OCHRE
	pigment.set_shader_parameter(&"strength", look.ochre_strength)
	ink.material = pigment
	@warning_ignore("return_value_discarded")
	ink.draw.connect(_draw_ochre.bind(ink, plan, marks))
	layer.add_child(ink)


func ground(canvas: CanvasItem, layer: PrologueYardDressing.Ground) -> void:
	var art: Texture2D = texture(layer.texture)
	var rect: Rect2 = layer.rect
	if layer.tiled and layer.tile_size.x > 0.0 and layer.tile_size.y > 0.0:
		var tiles: Vector2i = Vector2i((rect.size / layer.tile_size).ceil())
		for x: int in tiles.x:
			for y: int in tiles.y:
				var offset: Vector2 = Vector2(x, y) * layer.tile_size
				var size_m: Vector2 = layer.tile_size.min(rect.size - offset)
				var dst: Rect2 = pixels(Rect2(rect.position + offset, size_m))
				var src: Rect2 = Rect2(Vector2.ZERO, art.get_size() * size_m / layer.tile_size)
				canvas.draw_texture_rect_region(art, dst, src, layer.tint)
	else:
		canvas.draw_texture_rect(art, pixels(rect), false, layer.tint)
	if layer.wash.a > 0.0:
		canvas.draw_rect(pixels(rect), layer.wash)


func stamps(canvas: CanvasItem, pieces: Array[PrologueYardDressing.Piece]) -> void:
	for piece: PrologueYardDressing.Piece in pieces:
		var scale_xy: Vector2 = Vector2(-1, 1) if piece.flip else Vector2.ONE
		canvas.draw_set_transform(Ink.px(piece.at), piece.rotation, scale_xy)
		var rect: Rect2 = Rect2(-piece.size_m * 0.5, piece.size_m)
		canvas.draw_texture_rect(texture(piece.art), pixels(rect), false, piece.tint)
	canvas.draw_set_transform(Vector2.ZERO)


## Project each silhouette from its base along the ground, away from the burning hall.
func shadows(canvas: CanvasItem, plan: PrologueYard) -> void:
	var look: PrologueYardDressing = plan.dressing
	if look.shadow_reach == Vector2.ZERO:
		return
	for cover: PrologueYard.Wreck in plan.wrecks:
		_shadow(canvas, texture(cover.art), cover.footprint, look)
	for piece: PrologueYardDressing.Piece in look.fixtures:
		_shadow(
			canvas, texture(piece.art), Rect2(piece.at - piece.size_m * 0.5, piece.size_m), look
		)
	canvas.draw_set_transform(Vector2.ZERO)


func _shadow(canvas: CanvasItem, art: Texture2D, box: Rect2, look: PrologueYardDressing) -> void:
	var base: Vector2 = Ink.px(Vector2(box.position.x, box.end.y))
	var reach: Vector2 = Ink.px(look.shadow_reach)
	canvas.draw_set_transform_matrix(
		Transform2D(Vector2.RIGHT, -reach / art.get_height(), base + reach)
	)
	canvas.draw_texture_rect(
		art, Rect2(0, 0, Ink.px(box.size).x, art.get_height()), false, look.shadow_tint
	)


func wreck(
	canvas: CanvasItem, piece: PrologueYard.Wreck, tint: Color, skin: PrologueYardDressing.CoverArt
) -> void:
	var art: Texture2D = texture(skin.art if skin != null else piece.art)
	var crop: Rect2 = skin.crop if skin != null else piece.crop
	var source: Rect2 = Rect2(crop.position * art.get_size(), crop.size * art.get_size())
	var box: Rect2 = pixels(piece.footprint)
	if skin == null and is_zero_approx(piece.rotation):
		canvas.draw_texture_rect_region(art, box, source, tint)
		return
	if skin == null:
		var center: Vector2 = box.get_center()
		canvas.draw_set_transform(center, piece.rotation)
		canvas.draw_texture_rect_region(art, Rect2(-box.size * 0.5, box.size), source, tint)
		canvas.draw_set_transform(Vector2.ZERO)
		return
	canvas.draw_set_transform_matrix(cover_transform(box, source.size, piece.shell))
	canvas.draw_texture_rect_region(art, Rect2(-source.size * 0.5, source.size), source)
	canvas.draw_set_transform(Vector2.ZERO)


## Match the long collision axis, allowing 30 cm at either end for cut margins and shadows.
## Keep the short axis proportional wherever that still fills the footprint.
static func cover_transform(box: Rect2, source_size: Vector2, shell: bool) -> Transform2D:
	var turn: bool = not shell and (box.size.x > box.size.y) != (source_size.x > source_size.y)
	var target: Vector2 = Vector2(box.size.y, box.size.x) if turn else box.size
	var long_axis: int = target.max_axis_index()
	var short_axis: int = 1 - long_axis
	var margin: float = 0.6 * Ink.PX_PER_M
	var size: Vector2 = source_size * ((target[long_axis] + margin) / source_size[long_axis])
	size[short_axis] = clampf(
		size[short_axis], target[short_axis] * 0.92, target[short_axis] + margin
	)
	return Transform2D(PI * 0.5 if turn else 0.0, size / source_size, 0.0, box.get_center())


static func pixels(rect: Rect2) -> Rect2:
	return Rect2(Ink.px(rect.position), Ink.px(rect.size))


func _draw_ochre(
	canvas: Node2D, plan: PrologueYard, marks: Array[PrologueYardDressing.Piece]
) -> void:
	stamps(canvas, marks)
	for piece: PrologueYard.Wreck in plan.wrecks:
		var skin: PrologueYardDressing.CoverArt = plan.dressing.cover.get(piece.id)
		if skin != null or not plan.dressing.layout.is_empty():
			wreck(canvas, piece, Color.WHITE, skin)
