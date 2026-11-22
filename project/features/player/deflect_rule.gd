class_name DeflectRule
extends RefCounted
## An arena's throughput and spread. The registry stream starts on the first basic contact.
## Hosts can supply their world registry. Standalone arenas have only a seeded combat stream.

signal passed(at: Vector2, incoming: Vector2)

const KEY: StringName = &"deflect_rule"
const REGISTRY: StringName = &"deflect_registry"

var pass_ratio: float
var pass_ratio_k: float
var spread_deg: float
var basic_rounds: Array[StringName] = []
var _registry: RngRegistry
var _local: bool = false
var _stream: RandomNumberGenerator


static func of(arena: CombatArena) -> DeflectRule:
	if arena.has_meta(KEY):
		return arena.get_meta(KEY)
	var rule: DeflectRule = DeflectRule.new()
	if arena.has_meta(REGISTRY):
		rule._registry = arena.get_meta(REGISTRY)
	else:
		# RngRegistry.seed_for puts the master seed in the high word of the combat seed.
		rule._registry = RngRegistry.new(arena._rng.seed >> 32)
		rule._local = true
	var t: DataTable = DataTable.open(CombatTuning.TABLE, CombatTuning.SCHEMA)
	var row: Dictionary = t.object(t.raw, "deflect")
	rule.pass_ratio = t.num(row, "pass_ratio")
	rule.pass_ratio_k = t.num(row, "pass_ratio_k")
	rule.spread_deg = t.num(row, "spread_deg")
	rule.basic_rounds.assign(t.array(row, "basic_rounds"))
	if not t.ok():
		Log.error("deflect", str(t.errors()))
	arena.set_meta(KEY, rule)
	return rule


static func bind(arena: CombatArena, registry: RngRegistry) -> void:
	arena.set_meta(REGISTRY, registry)


func passes() -> bool:
	if _stream == null:
		_stream = _registry.stream(&"deflect")
	var chance: float = clampf(pass_ratio * pass_ratio_k, 0.0, 1.0)
	var roll: float = _stream.randf()
	return chance >= 1.0 or roll < chance


func turn() -> float:
	return deg_to_rad(_stream.randf_range(-spread_deg, spread_deg))


static func write_state(arena: CombatArena, out: StreamPeerBuffer) -> void:
	if not arena.has_meta(KEY):
		return
	var rule: DeflectRule = arena.get_meta(KEY)
	if rule._stream == null:
		return
	if rule._local:
		out.put_64(rule._stream.state)
	# A passed round can stay in blade reach into the next replay checkpoint.
	for shot: Shot in arena.shots:
		out.put_u8(int(shot.has_meta(PlayerDeflect.PASSED)))
