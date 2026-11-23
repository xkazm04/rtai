class_name PrologueYardPaint
extends RefCounted
## Draws into the floor canvas in stage order. No physics or navigation objects live here.

var _textures: Dictionary[String, Texture2D] = {}


func texture(path: String) -> Texture2D:
	if not _textures.has(path):
		_textures[path] = load(path) as Texture2D
	return _textures[path]


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
		canvas.draw_texture_rect(texture(piece.art), pixels(rect), false)
	canvas.draw_set_transform(Vector2.ZERO)


static func pixels(rect: Rect2) -> Rect2:
	return Rect2(Ink.px(rect.position), Ink.px(rect.size))
