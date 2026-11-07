class_name StreetStrips
extends RefCounted
## perf L3 (d9): the street cast's whole-figure strips, loaded once and shared by every card.
## A fall grid (about 3000 x 1500 RGBA, lossless) decoded on the frame of a death cost 15-28 ms on
## the main thread (the riot's p99.9; LEDGER L3). A full rig's card now asks the ResourceLoader for
## its row's fall grid on a worker thread when the card is first stepped (prefetch_fall), and the
## view's walk grids once per art, so the death finds the strip decoded. get_tex() returns the same
## Texture2D as a plain load() did (it waits for an in-flight request, or loads in place): only WHEN
## the decode runs moves, never a pixel. `-- --strip-prefetch=off` = load on first use (the before).

const PREF: StringName = &"street_fall_pref"

static var _tex: Dictionary[String, Texture2D] = {}
static var _asked: Dictionary[String, bool] = {}
static var _warm_art: String = ""


static func enabled() -> bool:
	return LaunchArgs.value("--strip-prefetch") != "off"


## The strip at `path`, decoded once (a prefetched one is collected from its worker).
static func get_tex(path: String) -> Texture2D:
	var t: Texture2D = _tex.get(path, null)
	if t != null:
		return t
	if _asked.has(path):
		@warning_ignore("return_value_discarded")
		_asked.erase(path)
		t = ResourceLoader.load_threaded_get(path) as Texture2D
	if t == null:
		t = load(path) as Texture2D
	_tex[path] = t
	return t


## Starts a worker-thread decode of `path` unless it is loaded, asked for, or prefetch is off.
static func prefetch(path: String) -> void:
	if path.is_empty() or _tex.has(path) or _asked.has(path) or not enabled():
		return
	if ResourceLoader.load_threaded_request(path, "Texture2D") == OK:
		_asked[path] = true


## Once per card: the fall grid its row draws when down (StreetWalkerFall.path_of), and on the
## first card of a view art that art's walk grids.
static func prefetch_fall(rig: CutRig, art: String, row: String) -> void:
	var card: Sprite2D = rig.head_card
	if card == null or card.has_meta(PREF):
		return
	card.set_meta(PREF, true)  # once per card: the step's guard is this one meta read
	if art != _warm_art:
		_warm_art = art
		var walks: Dictionary = StreetWalkerCards.WALKS.get(art, {})
		for key: String in walks:
			prefetch(StreetWalkerCards.DIR + art + "/" + str(walks[key]))
	var grid: String = StreetWalkerFall.path_of(art, row)
	if not grid.is_empty():
		prefetch(StreetWalkerCards.DIR + grid)
