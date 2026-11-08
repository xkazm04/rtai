class_name FrameCap
extends RefCounted
## L10 (docs/perf/LEDGER.md): everything on screen steps on the 60 Hz sim tick (the camera follows
## per tick, no view reads SimClock.alpha()), so a frame drawn faster than the tick re-renders the
## same image. On a display faster than the tick with vsync on, the frame limiter is set to the tick
## rate: the same image every tick, a fraction of the CPU and GPU. A 60 Hz (or 59.94 Hz) display
## keeps plain vsync (no limiter on top of it). `--frame-cap=off` is the old uncapped vsync; an
## explicit engine `--max-fps` or `--write-movie` always wins (filming, the bench). Under
## `--fixed-fps` with vsync on a fast display the cap only paces wall time: the frames are the same.

## n9 (Call P-3): the player's frame pacing on top (PlayerSettings.pacing): "efficient" keeps the
## cap above, "steady" adds the limiter at the tick rate on a tick-rate display too (smoother
## presents for ~+0.06..+0.09 of a core, LEDGER L10 / L11).

## A display up to TICK_RATE + MARGIN_HZ is "the tick rate" already: vsync alone paces it.
const MARGIN_HZ: float = 1.0

## The limiter apply() left (the efficient pacing); -1 = not active (headless, filming, the flag
## off, or apply() never ran): the pacing option leaves Engine.max_fps alone.
static var _boot_cap: int = -1


## The limiter for a display of `refresh_hz` (0 = none): `current` is Engine.max_fps now (kept when
## set), `flag` the --frame-cap value ("off" keeps `current`).
static func cap_for(refresh_hz: float, vsync_on: bool, current: int, flag: String) -> int:
	if flag == "off" or current != 0 or not vsync_on:
		return current
	if refresh_hz > SimClock.TICK_RATE + MARGIN_HZ:
		return SimClock.TICK_RATE
	return current


## Sets Engine.max_fps for this window (the Game autoload, once at start).
static func apply(flag: String) -> void:
	_boot_cap = -1
	if DisplayServer.get_name() == "headless" or Engine.get_write_movie_path() != "":
		return
	var screen: int = DisplayServer.window_get_current_screen()
	var hz: float = DisplayServer.screen_get_refresh_rate(screen)
	var vsync_on: bool = DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED
	var cap: int = cap_for(hz, vsync_on, Engine.max_fps, flag)
	if cap != Engine.max_fps:
		Log.info("frame_cap", "display %.2f Hz, vsync on: frame limiter %d fps" % [hz, cap])
		Engine.max_fps = cap
	if flag != "off":
		_boot_cap = Engine.max_fps


## The limiter for the pacing option: an existing cap (a fast display, an explicit one) is kept;
## steady caps a tick-rate display at the tick rate, efficient leaves it uncapped.
static func pacing_cap(boot_cap: int, steady: bool) -> int:
	if boot_cap != 0 or not steady:
		return boot_cap
	return SimClock.TICK_RATE


## Sets Engine.max_fps for the player's pacing (no-op until apply() made the cap active).
static func apply_pacing(steady: bool) -> void:
	if _boot_cap < 0:
		return
	Engine.max_fps = pacing_cap(_boot_cap, steady)
