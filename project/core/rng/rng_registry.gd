class_name RngRegistry
extends RefCounted
## One seeded RandomNumberGenerator per system (SIM-02). A stream's seed depends only on the
## master seed and the system's name, so adding a system (or a draw in one) never shifts another
## system's dice. This is the only place a RandomNumberGenerator is constructed (lint-enforced);
## the global randf/randi/seed()/shuffle()/pick_random() are banned.

const SEED_MASK: int = 0xFFFFFFFF
const FNV_OFFSET: int = 0x811C9DC5
const FNV_PRIME: int = 0x01000193

var _master_seed: int = 0
var _streams: Dictionary[StringName, RandomNumberGenerator] = {}


## The master seed is kept to 32 bits (it travels through JSON, DAT-05).
func _init(base_seed: int) -> void:
	_master_seed = base_seed & SEED_MASK


## master seed in the high 32 bits, FNV-1a of the name in the low 32: stable across runs,
## machines and engine versions (String.hash() is not promised to be).
static func seed_for(base_seed: int, system: StringName) -> int:
	return ((base_seed & SEED_MASK) << 32) | fnv1a32(String(system))


static func fnv1a32(text: String) -> int:
	var h: int = FNV_OFFSET
	for byte: int in text.to_utf8_buffer():
		h = ((h ^ byte) * FNV_PRIME) & SEED_MASK
	return h


func master_seed() -> int:
	return _master_seed


## The system's own stream, created on first use. Ask once in setup() and keep it.
func stream(system: StringName) -> RandomNumberGenerator:
	if not _streams.has(system):
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = seed_for(_master_seed, system)
		_streams[system] = rng
	return _streams[system]


func names() -> Array[StringName]:
	var out: Array[StringName] = []
	out.assign(_streams.keys())
	out.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	return out


## Every stream's name and state, in name order, for the replay state hash (SIM-05).
func write_state(out: StreamPeerBuffer) -> void:
	for system: StringName in names():
		out.put_utf8_string(String(system))
		out.put_64(_streams[system].state)
