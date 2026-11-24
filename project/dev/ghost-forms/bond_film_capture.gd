class_name BondFilmCapture
extends RefCounted
## Native frames for the movie: every drawn frame whose sim tick lies in [from, to] is saved as
## a numbered jpg (the rest screen adds frames while the tick holds, so all are saved).
## GTAI_FILM_DIR, GTAI_FILM_FROM and GTAI_FILM_TO (ticks) name the window; with no directory
## nothing is recorded.

var _dir: String = OS.get_environment("GTAI_FILM_DIR")
var _from: int = OS.get_environment("GTAI_FILM_FROM").to_int()
var _to: int = OS.get_environment("GTAI_FILM_TO").to_int()
var _tree: SceneTree
var _viewport: Viewport
var _tick: Callable
var _saved: int = 0


func enabled() -> bool:
	return not _dir.is_empty()


func attach(tree: SceneTree, viewport: Viewport, tick: Callable) -> void:
	_tree = tree
	_viewport = viewport
	_tick = tick
	@warning_ignore("return_value_discarded")
	RenderingServer.frame_post_draw.connect(_capture)


func _capture() -> void:
	var tick: int = _tick.call()
	if tick < _from:
		return
	if tick > _to:
		Log.info("bond-film", "capture done: %d frames, last tick %d" % [_saved, tick])
		_tree.quit()
		return
	var image: Image = _viewport.get_texture().get_image()
	if image.get_size() != Vector2i(1920, 1080):
		Log.error("bond-film", "frame is %s, not 1920x1080" % image.get_size())
		_tree.quit(1)
		return
	_saved += 1
	if image.save_jpg(_dir.path_join("%05d.jpg" % _saved), 0.95) != OK:
		Log.error("bond-film", "cannot save frame %d" % _saved)
		_tree.quit(1)
