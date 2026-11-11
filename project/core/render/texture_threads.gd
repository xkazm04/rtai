class_name TextureThreads
extends RefCounted
## May a texture be decoded on a loader thread here? Not under the headless display server:
## its dummy renderer keeps textures in a RID owner that is not thread-safe, so textures made
## on two threads at once lose a RID (`Initializing already initialized RID`, then
## `Parameter "t" is null` in texture_2d_initialize, or a crash). Measured 2026-11-11
## (gtai-n15/flake/race): 4 worker threads making ImageTextures beside the main thread gave
## 3-4 errors and a segfault per headless run; 0 under d3d12, 0 on the main thread alone.
## That race was the scenario_rig_stress flake (n11 hero twice, world 11-08, d5-combat 11-03,
## n15 twice): StreetStrips' prefetch beside a main-thread load(). Headless runs (tests,
## scenarios, bakes) load in place; a real renderer keeps the worker decode (perf L3, WLD-07).
## Pixels never differ: only WHEN the decode runs.

## Tests only: -1 = decide by the display server, 0 = never, 1 = always.
static var override: int = -1


static func allowed() -> bool:
	if override >= 0:
		return override == 1
	return DisplayServer.get_name() != "headless"
