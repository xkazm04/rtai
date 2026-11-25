extends GutTest
## The explosion light prints its outer band in its alt ink (lights.json `rim`): LightPool packs the
## alt colour into the instance custom data; a non-rim kind and a flicker kind leave .z/.w at 0.
## (Asserted on `custom_data`, the value `write` stores: a headless MultiMesh reads back defaults.)

const AMBER: Color = Color8(0xED, 0xAB, 0x42)


func _custom(kind: StringName) -> Color:
	var lights: LightLayer = autofree(LightLayer.new())
	return LightPool.custom_data(lights.kinds[kind])


func test_the_explosion_packs_its_amber_rim() -> void:
	var c: Color = _custom(&"explosion")
	assert_eq(c.b, 1.0, "rim on")
	assert_eq(int(c.a), 0xED * 65536 + 0xAB * 256 + 0x42, "amber packed")  # 15575874
	assert_eq(c.r, 3.0, "steps kept")


func test_the_pack_round_trips_every_channel() -> void:
	var p: int = int(LightPool.pack_rgb(AMBER))
	assert_eq(Color8(p >> 16, (p >> 8) & 255, p & 255), AMBER)


func test_a_plain_and_a_flicker_kind_have_no_rim() -> void:
	for k: StringName in [&"muzzle_flash", &"siren"]:
		var c: Color = _custom(k)
		assert_eq(c.b, 0.0, "%s rim off" % k)
		assert_eq(c.a, 0.0, "%s no ink" % k)
