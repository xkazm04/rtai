class_name ChunkCodec
extends RefCounted
## City chunk file format (AST-11): a 32-byte header, then `var_to_bytes` of the chunk's packed
## arrays. Header (little-endian):
##   0  magic "GTCH"          4  format_version u16    6  flags u16 (bit 0: 64-bit floats)
##   8  chunk x u16          10  chunk y u16          12  generator_version u32
##  16  first 16 bytes of SHA-256(payload)
## A bad magic, version, key or hash means: log, skip, never instantiate. Decoding uses only
## bytes_to_var (never *_with_objects, SEC-02).

const MAGIC: PackedByteArray = [0x47, 0x54, 0x43, 0x48]
const FORMAT_VERSION: int = 1
const HEADER_SIZE: int = 32
const HASH_BYTES: int = 16


static func file_name(cx: int, cy: int) -> String:
	return "c_%02d_%02d.bin" % [cx, cy]


static func encode(chunk: CityChunk, generator_version: int) -> PackedByteArray:
	var payload: PackedByteArray = var_to_bytes(chunk.to_payload())
	var head: StreamPeerBuffer = StreamPeerBuffer.new()
	var err: int = head.put_data(MAGIC)
	head.put_u16(FORMAT_VERSION)
	head.put_u16(0)
	head.put_u16(chunk.cx)
	head.put_u16(chunk.cy)
	head.put_u32(generator_version)
	err |= head.put_data(_digest(payload))
	if err != OK:
		return PackedByteArray()
	var out: PackedByteArray = head.data_array
	out.append_array(payload)
	return out


## The chunk, or null with the reason in `why` (a one-element Array the caller passes in).
static func decode(bytes: PackedByteArray, expect: Vector2i, why: Array[String]) -> CityChunk:
	var reason: String = _check_header(bytes, expect)
	var chunk: CityChunk = null
	if reason == "":
		var payload: Variant = bytes_to_var(bytes.slice(HEADER_SIZE))
		if payload is Dictionary:
			var d: Dictionary = payload
			chunk = CityChunk.from_payload(d)
		reason = "" if chunk != null else "payload is not a well-formed chunk"
	why.assign([reason])
	return chunk


static func generator_version_of(bytes: PackedByteArray) -> int:
	return bytes.decode_u32(12) if bytes.size() >= HEADER_SIZE else -1


static func _check_header(bytes: PackedByteArray, expect: Vector2i) -> String:
	if bytes.size() < HEADER_SIZE or bytes.slice(0, 4) != MAGIC:
		return "not a GTCH chunk"
	if bytes.decode_u16(4) != FORMAT_VERSION:
		return "format version %d, reader knows %d" % [bytes.decode_u16(4), FORMAT_VERSION]
	if bytes.decode_u16(6) != 0:
		return "unsupported flags %d" % bytes.decode_u16(6)
	if Vector2i(bytes.decode_u16(8), bytes.decode_u16(10)) != expect:
		return "header names chunk %d,%d" % [bytes.decode_u16(8), bytes.decode_u16(10)]
	if bytes.slice(16, HEADER_SIZE) != _digest(bytes.slice(HEADER_SIZE)):
		return "payload hash mismatch"
	return ""


static func _digest(payload: PackedByteArray) -> PackedByteArray:
	var hashing: HashingContext = HashingContext.new()
	var err: int = hashing.start(HashingContext.HASH_SHA256)
	err |= hashing.update(payload)
	return hashing.finish().slice(0, HASH_BYTES) if err == OK else PackedByteArray()
