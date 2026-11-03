class_name GrimeLattice
extends RefCounted
## The print pass's grime as a baked value-noise lattice (look_d4.gdshader `grime_tex`): one random
## value per lattice point, 128 x 128, tiling. The shader samples it bilinearly at i + smoothstep(f)
## + 0.5, which is the same smoothstep-faded value noise as its vnoise() for 1 texture fetch instead
## of 4 sin hashes (the low-end GPU cost, core/render/README.md). The grime octaves are 9-29 px
## cells, so the tile repeats every 1.1-3.6k screen px: under the blotches, never seen as a pattern.

const SIZE: int = 128

static var _tex: ImageTexture = null


## The shared lattice texture (built once, ~16k values, deterministic: no RNG stream needed).
static func texture() -> ImageTexture:
	if _tex == null:
		_tex = ImageTexture.create_from_image(image())
	return _tex


static func image() -> Image:
	var data: PackedByteArray = PackedByteArray()
	@warning_ignore("return_value_discarded")
	data.resize(SIZE * SIZE)
	for y: int in SIZE:
		for x: int in SIZE:
			data[y * SIZE + x] = int(hash01(x, y) * 255.0 + 0.5)
	return Image.create_from_data(SIZE, SIZE, false, Image.FORMAT_L8, data)


## The shader's lattice hash (fract(sin(dot(p, (12.9898, 78.233))) * 43758.5453)), 0..1.
static func hash01(x: int, y: int) -> float:
	var s: float = sin(x * 12.9898 + y * 78.233) * 43758.5453
	return s - floorf(s)
