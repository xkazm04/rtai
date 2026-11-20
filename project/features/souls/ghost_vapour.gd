class_name GhostVapour
extends RefCounted
## One synchronously generated tile shared by the ribbon and the bridge silhouette.
static var _grain: Texture2D


static func grain() -> Texture2D:
	if _grain == null:
		var noise: FastNoiseLite = FastNoiseLite.new()
		noise.seed = 41731
		noise.frequency = 0.065
		noise.fractal_octaves = 3
		var img: Image = noise.get_seamless_image(128, 128)
		_grain = ImageTexture.create_from_image(img)
	return _grain
