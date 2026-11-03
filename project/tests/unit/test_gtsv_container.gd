extends GutTest
## GTSV container (SAV-02): round trip, and every way a byte stream can be wrong.


func _env(seq: int = 1, version: int = 1) -> Dictionary:
	return {"save_version": version, "seq": seq, "point": "p", "body": {"a": 1, "b": "x"}}


func _body(env: Dictionary) -> Dictionary:
	var b: Dictionary = env["body"]
	return b


func test_round_trip() -> void:
	var d: GtsvContainer.Decoded = GtsvContainer.decode(GtsvContainer.encode(_env(7)))
	assert_eq(d.kind, GtsvContainer.Kind.OK)
	assert_eq(d.seq(), 7)
	assert_eq(str(_body(d.envelope).get("b")), "x")


func test_header_layout_is_the_spec() -> void:
	var b: PackedByteArray = GtsvContainer.encode(_env())
	assert_eq(b.slice(0, 4).get_string_from_ascii(), "GTSV")
	assert_eq(b.decode_u16(4), 1, "container_version")
	assert_eq(b.decode_u16(6), 1, "min_reader_version")
	assert_eq(b.decode_u32(8), 0, "flags")
	assert_eq(b.decode_u64(12), b.size() - GtsvContainer.HEADER_SIZE, "payload_len")


func test_empty_and_short_are_corrupt() -> void:
	assert_eq(GtsvContainer.decode(PackedByteArray()).kind, GtsvContainer.Kind.CORRUPT)
	var b: PackedByteArray = GtsvContainer.encode(_env())
	assert_eq(GtsvContainer.decode(b.slice(0, 20)).kind, GtsvContainer.Kind.CORRUPT)


func test_every_truncation_is_corrupt() -> void:
	var b: PackedByteArray = GtsvContainer.encode(_env())
	for keep: int in range(0, b.size()):
		assert_eq(
			GtsvContainer.decode(b.slice(0, keep)).kind, GtsvContainer.Kind.CORRUPT, str(keep)
		)


func test_every_flipped_byte_is_refused() -> void:
	var b: PackedByteArray = GtsvContainer.encode(_env())
	for at: int in b.size():
		if at >= 4 and at < 8:
			continue  # the two version fields are advisory; the hash covers the payload
		var bad: PackedByteArray = b.duplicate()
		bad[at] = bad[at] ^ 0x01
		assert_ne(GtsvContainer.decode(bad).kind, GtsvContainer.Kind.OK, "byte %d" % at)


func test_bad_magic_is_corrupt() -> void:
	var b: PackedByteArray = GtsvContainer.encode(_env())
	b[0] = 0x58
	assert_eq(GtsvContainer.decode(b).kind, GtsvContainer.Kind.CORRUPT)


func test_newer_container_and_newer_save_version_are_newer() -> void:
	var b: PackedByteArray = GtsvContainer.encode(_env())
	b.encode_u16(6, 9)
	assert_eq(GtsvContainer.decode(b).kind, GtsvContainer.Kind.NEWER, "min_reader_version 9")
	var n: GtsvContainer.Decoded = GtsvContainer.decode(GtsvContainer.encode(_env(1, 99)))
	assert_eq(n.kind, GtsvContainer.Kind.NEWER, "save_version 99")


func test_unknown_flag_is_newer() -> void:
	var b: PackedByteArray = GtsvContainer.encode(_env())
	b.encode_u32(8, 1)
	assert_eq(GtsvContainer.decode(b).kind, GtsvContainer.Kind.NEWER)


func test_payload_that_is_not_an_envelope_is_corrupt() -> void:
	var payload: PackedByteArray = "[1,2]".to_utf8_buffer()
	var buf: StreamPeerBuffer = StreamPeerBuffer.new()
	@warning_ignore("return_value_discarded")
	buf.put_data(GtsvContainer.MAGIC)
	buf.put_u16(1)
	buf.put_u16(1)
	buf.put_u32(0)
	buf.put_u64(payload.size())
	@warning_ignore("return_value_discarded")
	buf.put_data(GtsvContainer.payload_hash(payload))
	@warning_ignore("return_value_discarded")
	buf.put_data(payload)
	assert_eq(GtsvContainer.decode(buf.data_array).kind, GtsvContainer.Kind.CORRUPT)


func test_migrations_chain_in_order() -> void:
	var steps: Array[Callable] = [
		func(e: Dictionary) -> Dictionary:
			_body(e)["two"] = true
			return e,
		func(e: Dictionary) -> Dictionary:
			_body(e)["three"] = _body(e).has("two")
			return e,
	]
	var env: Dictionary = {"save_version": 1, "seq": 1, "body": {}}
	var up: Dictionary = SaveMigrations.migrate(env, 3, steps)
	assert_eq(GtsvContainer.as_int(up.get("save_version")), 3)
	assert_true(_body(up).has("three"), "step 2 ran after step 1")
	assert_false(_body(env).has("two"), "the input is not mutated (pure)")
	var same: Dictionary = SaveMigrations.migrate(env)
	assert_eq(GtsvContainer.as_int(same.get("save_version")), 1, "current is a no-op")


func test_v1_fixture_still_loads_and_the_format_has_not_drifted() -> void:
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes("res://tests/saves/v1.sav")
	assert_gt(bytes.size(), 0, "tests/saves/v1.sav exists")
	var d: GtsvContainer.Decoded = GtsvContainer.decode(bytes)
	assert_eq(d.kind, GtsvContainer.Kind.OK, d.reason)
	var env: Dictionary = SaveMigrations.migrate(d.envelope)
	assert_eq(GtsvContainer.as_int(env.get("save_version")), SaveMigrations.CURRENT)
	assert_eq(str(_body(env).get("quest")), "collect-call")
	var same: bool = GtsvContainer.encode(_v1_envelope()) == bytes
	assert_true(same, "encoding the v1 fixture's source envelope reproduces v1.sav byte for byte")


func _v1_envelope() -> Dictionary:
	var cp: Dictionary = {
		"schema": "gtai.checkpoint/1",
		"version": 1,
		"quest": "collect-call",
		"beat": "b2-payphone",
		"tick": 1234,
		"master_seed": 20261102,
		"state_hash": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
		"input_ticks": [0, 60, 120],
		"inputs": [0, 5, 0],
	}
	return {
		"save_version": 1,
		"seq": 1,
		"saved_unix": 1793700000,
		"point": "as-b2-payphone",
		"body": cp,
	}
