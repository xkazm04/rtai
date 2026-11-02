class_name ChunkSource
extends RefCounted
## Where chunk data comes from: the baked GTCH files (AST-11/12), read and decoded on
## WorkerThreadPool (WLD-02 stage 1, data only, SIM-06), handed over under a mutex. A missing
## file is generated in memory by the same deterministic generator (identical bytes: the golden
## hash list proves it), so a fresh clone runs without a bake step. A file that fails its header
## or hash is never instantiated: the chunk stays void (solid) and the reason is reported.

var dir: String = "res://data/generated/city"
var generated: int = 0
var failures: Array[String] = []
var _gen: CityGen
var _mutex: Mutex = Mutex.new()
var _done: Dictionary[Vector2i, CityChunk] = {}
var _errors: Dictionary[Vector2i, String] = {}
var _tasks: Dictionary[Vector2i, int] = {}


func _init(gen: CityGen, chunk_dir: String = "res://data/generated/city") -> void:
	_gen = gen
	dir = chunk_dir


## Starts a background read of `key` unless it is already loaded or on its way.
func prefetch(key: Vector2i) -> void:
	if _tasks.has(key):
		return
	_mutex.lock()
	var have: bool = _done.has(key)
	_mutex.unlock()
	if not have:
		_tasks[key] = WorkerThreadPool.add_task(_task.bind(key), false, "city chunk")


## The chunk now (main thread). Waits for an in-flight read, else loads synchronously; null
## when the file is corrupt (the reason lands in `failures`).
func take(key: Vector2i) -> CityChunk:
	if _tasks.has(key):
		var err: int = WorkerThreadPool.wait_for_task_completion(_tasks[key])
		assert(err == OK or err == ERR_INVALID_PARAMETER)
		@warning_ignore("return_value_discarded")
		_tasks.erase(key)
	_mutex.lock()
	var chunk: CityChunk = _done.get(key)
	var why: String = _errors.get(key, "")
	@warning_ignore("return_value_discarded")
	_done.erase(key)
	@warning_ignore("return_value_discarded")
	_errors.erase(key)
	_mutex.unlock()
	if chunk == null and why == "":
		var reasons: Array[String] = []
		chunk = load_now(key, reasons)
		why = reasons[0] if not reasons.is_empty() else ""
	if why != "":
		failures.append("%s: %s" % [ChunkCodec.file_name(key.x, key.y), why])
	elif chunk == null and why == "":
		failures.append("%s: unreadable" % ChunkCodec.file_name(key.x, key.y))
	return chunk


## Reads + decodes one chunk on the calling thread (no logging: workers call it too).
func load_now(key: Vector2i, why: Array[String]) -> CityChunk:
	var path: String = dir.path_join(ChunkCodec.file_name(key.x, key.y))
	if not FileAccess.file_exists(path):
		why.assign([""])
		return _gen.gen_chunk(key.x, key.y) if _gen != null else null
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
	var baked_by: int = ChunkCodec.generator_version_of(bytes)
	if _gen != null and baked_by != CityGen.GENERATOR_VERSION:
		# a stale bake would diverge from a generated chunk: regenerate, and say so
		why.assign(
			["stale bake (generator v%d, expected v%d)" % [baked_by, CityGen.GENERATOR_VERSION]]
		)
		return _gen.gen_chunk(key.x, key.y)
	return ChunkCodec.decode(bytes, key, why)


func _task(key: Vector2i) -> void:
	var why: Array[String] = []
	var path: String = dir.path_join(ChunkCodec.file_name(key.x, key.y))
	var was_generated: bool = not FileAccess.file_exists(path)
	var chunk: CityChunk = load_now(key, why)
	_mutex.lock()
	if chunk != null:
		_done[key] = chunk
		generated += 1 if was_generated else 0
	else:
		_errors[key] = why[0] if not why.is_empty() else "unreadable"
	_mutex.unlock()
