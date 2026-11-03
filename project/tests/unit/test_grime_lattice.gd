extends GutTest


func test_lattice_is_the_shaders_hash_baked_8_bit() -> void:
	var img: Image = GrimeLattice.image()
	assert_eq(img.get_size(), Vector2i(GrimeLattice.SIZE, GrimeLattice.SIZE))
	assert_eq(img.get_format(), Image.FORMAT_L8)
	for p: Vector2i in [Vector2i(0, 0), Vector2i(5, 77), Vector2i(127, 127)]:
		var want: float = GrimeLattice.hash01(p.x, p.y)
		assert_almost_eq(img.get_pixelv(p).r, want, 1.0 / 255.0)


func test_lattice_is_noise_not_a_flat_fill() -> void:
	var img: Image = GrimeLattice.image()
	var total: float = 0.0
	var lo: int = 0
	for y: int in GrimeLattice.SIZE:
		for x: int in GrimeLattice.SIZE:
			var v: float = img.get_pixel(x, y).r
			total += v
			lo += 1 if v < 0.25 else 0
	var n: float = float(GrimeLattice.SIZE * GrimeLattice.SIZE)
	assert_almost_eq(total / n, 0.5, 0.03, "uniform 0..1 values")
	assert_almost_eq(lo / n, 0.25, 0.03)


func test_texture_is_built_once() -> void:
	assert_same(GrimeLattice.texture(), GrimeLattice.texture())
