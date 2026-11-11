extends SceneTree
## Repro: textures created on worker threads while the main thread creates textures, under the
## headless (dummy) renderer. Args after --: threads=<n> (0 = main thread only), rounds=<n>.

var _stop: bool = false


func _initialize() -> void:
	var args: Dictionary = {}
	for a: String in OS.get_cmdline_user_args():
		var kv: PackedStringArray = a.trim_prefix("--").split("=")
		args[kv[0]] = int(kv[1])
	var n: int = args.get("threads", 4)
	var rounds: int = args.get("rounds", 20000)
	var threads: Array[Thread] = []
	for i: int in n:
		var t: Thread = Thread.new()
		t.start(_worker)
		threads.append(t)
	var made: int = 0
	for r: int in rounds:
		var tex: ImageTexture = ImageTexture.create_from_image(Image.create(8, 8, false, Image.FORMAT_RGBA8))
		if tex != null and tex.get_width() == 8:
			made += 1
	_stop = true
	for t: Thread in threads:
		t.wait_to_finish()
	print("race: threads=%d rounds=%d main made=%d" % [n, rounds, made])
	quit(0)


func _worker() -> void:
	while not _stop:
		var tex: ImageTexture = ImageTexture.create_from_image(Image.create(8, 8, false, Image.FORMAT_RGBA8))
		tex = null
