class_name WeaponFxWarm
extends RefCounted
## n12 (the city fight's worst frames): every weapon fx cell loads at the load, not in the draw.
## WeaponFxArt loaded an fx id's frames the first time a draw asked for it, so the rocket's first
## shot and blast in the release city fight (ticks 2019-2034) put an 11-16 ms FxView draw on screen.
## This holds the frame cache WeaponFxArt draws from; RivetHeldView.warm() fills it (the 61 cells
## are 2.9 MB of PNG). The same textures either way: the pixels do not move.
## `-- --strip-prefetch=off` (perf L3's flag for art loaded ahead) = load on first draw (the
## before).

static var _frames: Dictionary[StringName, Array] = {}


## The frames of fx `id`, loaded on first ask and kept.
static func frames_of(id: StringName) -> Array:
	if not _frames.has(id):
		_frames[id] = WeaponFxArt.art().fx_frames(id)
	return _frames[id]


## Loads every fx id's frames (nothing when off or the cells are not drawn).
static func warm() -> void:
	if not StreetStrips.enabled() or not WeaponFxArt.enabled:
		return
	var n: int = 0
	for id: StringName in WeaponFxArt.art().fx_cells.ids():
		n += frames_of(id).size()
	Log.info("fx", "warmed %d weapon fx cells" % n)
