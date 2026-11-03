class_name GtsvContainer
extends RefCounted
## The GTSV container (SAV-02): `GTSV`, container_version u16, min_reader_version u16, flags u32,
## payload_len u64, 16 bytes of SHA-256 over the stored payload, then the payload: UTF-8 JSON
## (sort_keys, full_precision) of the envelope {save_version, seq, saved_unix, point, body}.
## decode() never throws and never default-fills: every failure is a Decoded with a kind and a
## reason. A newer container, flag or save_version is NEWER (refused, never overwritten, SAV-04).

enum Kind { OK, MISSING, CORRUPT, NEWER }

const MAGIC: PackedByteArray = [0x47, 0x54, 0x53, 0x56]
const CONTAINER_VERSION: int = 1
const HEADER_SIZE: int = 36
const HASH_SIZE: int = 16


class Decoded:
	extends RefCounted
	var kind: Kind = Kind.CORRUPT
	var reason: String = ""
	var envelope: Dictionary = {}

	func seq() -> int:
		return GtsvContainer.as_int(envelope.get("seq"))


## The container bytes for `envelope` (a Dictionary the caller built; JSON-safe values only).
static func encode(envelope: Dictionary) -> PackedByteArray:
	var payload: PackedByteArray = JSON.stringify(envelope, "", true, true).to_utf8_buffer()
	var buf: StreamPeerBuffer = StreamPeerBuffer.new()
	var err: int = buf.put_data(MAGIC)
	buf.put_u16(CONTAINER_VERSION)
	buf.put_u16(CONTAINER_VERSION)
	buf.put_u32(0)
	buf.put_u64(payload.size())
	err |= buf.put_data(payload_hash(payload))
	err |= buf.put_data(payload)
	return buf.data_array if err == OK else PackedByteArray()


## An int from a JSON number (JSON parses every number as float); -1 for anything else.
static func as_int(v: Variant) -> int:
	if v is int:
		return v
	var f: float = v if v is float else -1.0
	return roundi(f)


static func payload_hash(payload: PackedByteArray) -> PackedByteArray:
	var hashing: HashingContext = HashingContext.new()
	var err: int = hashing.start(HashingContext.HASH_SHA256)
	err |= hashing.update(payload)
	if err != OK:
		return PackedByteArray()
	return hashing.finish().slice(0, HASH_SIZE)


static func decode(bytes: PackedByteArray) -> Decoded:
	var out: Decoded = Decoded.new()
	if bytes.size() < HEADER_SIZE:
		out.reason = "shorter than the header (%d bytes)" % bytes.size()
		return out
	if bytes.slice(0, 4) != MAGIC:
		out.reason = "bad magic"
		return out
	var head: StreamPeerBuffer = StreamPeerBuffer.new()
	head.data_array = bytes.slice(4, HEADER_SIZE)
	@warning_ignore("return_value_discarded")
	head.get_u16()
	var min_reader: int = head.get_u16()
	var flags: int = head.get_u32()
	var length: int = head.get_u64()
	if min_reader > CONTAINER_VERSION or flags != 0:
		out.kind = Kind.NEWER
		out.reason = "container needs reader %d / flags %d" % [min_reader, flags]
		return out
	var payload: PackedByteArray = bytes.slice(HEADER_SIZE)
	if length != payload.size():
		out.reason = "payload is %d bytes, header says %d" % [payload.size(), length]
		return out
	if payload_hash(payload) != bytes.slice(HEADER_SIZE - HASH_SIZE, HEADER_SIZE):
		out.reason = "payload hash mismatch"
		return out
	return _parse(payload, out)


static func _parse(payload: PackedByteArray, out: Decoded) -> Decoded:
	var parser: JSON = JSON.new()
	if parser.parse(payload.get_string_from_utf8()) != OK or not parser.data is Dictionary:
		out.reason = "payload is not a JSON object"
		return out
	var env: Dictionary = parser.data
	var version: Variant = env.get("save_version")
	var seq: Variant = env.get("seq")
	if not (version is float or version is int) or not (seq is float or seq is int):
		out.reason = "envelope lacks save_version / seq"
		return out
	if not env.get("body") is Dictionary or as_int(seq) < 0:
		out.reason = "envelope body or seq invalid"
		return out
	out.envelope = env
	out.kind = Kind.NEWER if as_int(version) > SaveMigrations.CURRENT else Kind.OK
	if out.kind == Kind.NEWER:
		out.reason = "save_version %d is newer than this reader" % as_int(version)
	return out
