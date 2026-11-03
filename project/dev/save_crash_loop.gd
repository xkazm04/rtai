extends RefCounted
## The write loop of save_crash_writer.gd: never returns; the test kills the process.

const BODY_CHARS: int = 100000


func run(root: String) -> void:
	var worker: SaveWorker = SaveWorker.new(SaveSlots.new(root))
	var n: int = 0
	while true:
		n += 1
		var body: Dictionary = {"n": n, "pad": "x".repeat(BODY_CHARS)}
		worker.submit({"point": "crash-%d" % n, "body": body, "meta": {"quest": "crash"}})
		worker.flush()
