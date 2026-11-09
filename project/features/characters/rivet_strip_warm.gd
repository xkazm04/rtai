class_name RivetStripWarm
extends RefCounted
## n12 (the city fight's worst frames): Rivet's drawn strips decode before he needs them.
## RivetFrames loaded a strip the first time his pose asked for its path (a walk grid, a weapon's
## equipped, left, diagonal or reload strip), inside his pose step: 7.5-14.6 ms frames in the
## release city fight at ticks 6-8, 258, 1513 and 1533. RivetHeldView.warm() calls this with the
## guns he carries; every file that exists under the view's art key is asked of a worker thread
## through StreetStrips (perf L3's cache and flag), which RivetFrames reads, so the frames draw the
## same textures. `-- --strip-prefetch=off` = load on first use (the before).

const BASE_FILES: PackedStringArray = [
	RivetStrips.BASE, RivetWalk.STRIP, RivetWalk.STRIP4, RivetWalk.RUN, RivetKnock.STRIP
]
## Per weapon, `%s` = its id: the equipped strip, its left and diagonal cuts, the reload strips and
## the armed walk and run grids (RivetStrips, RivetReload, RivetWalk name them the same way).
const WEAPON_FILES: PackedStringArray = [
	"rivet_eq_%s.png",
	"rivet_eq_%s_left.png",
	"rivet_eq_%s" + RivetStrips.DIAG,
	RivetReload.PREFIX + "%s.png",
	RivetReload.PREFIX + "%s_left.png",
	RivetWalk.ARMED + "%s.png",
	RivetWalk.ARMED_RUN + "%s.png",
]


## Every shipped strip Rivet can draw under `art` with `weapons` (and bare-clawed), in a fixed
## order.
static func paths(art: String, weapons: Array[StringName]) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	if art.is_empty():
		return out
	var dir: String = RivetStrips.DIR + art + "/"
	for file: String in BASE_FILES:
		_add(out, dir + file)
	for weapon: StringName in weapons:
		if weapon == &"":
			continue
		for file: String in WEAPON_FILES:
			_add(out, dir + file % String(weapon))
	return out


## The art of the guns he carries, behind the load (moved from RivetHeldView.warm, the same calls:
## perf-city's 8-19 ms first draw of a gun), then his drawn strips for them and bare-clawed, each
## asked of a worker. No strips under a flat view (no cards) or with the prefetch off.
static func warm(slots: Array[StringName], arsenal: ArsenalTable, art: WeaponArt) -> void:
	for weapon: StringName in slots:
		var id: StringName = arsenal.art_id(weapon) if weapon != &"" else &""
		if art.has(id):
			art.make_held(id).free()
			for part: String in ["mag", "tank"]:
				@warning_ignore("return_value_discarded")
				art.part_texture(id, part)
	var view: ViewMode = ViewMode.shared()
	if not view.cards or not StreetStrips.enabled():
		return
	var list: PackedStringArray = paths(view.art, slots)
	for path: String in list:
		StreetStrips.prefetch(path)
	Log.info("rivet", "prefetching %d drawn strips for %s" % [list.size(), str(slots)])


static func _add(out: PackedStringArray, path: String) -> void:
	if not out.has(path) and RivetStrips.has_file(path):
		@warning_ignore("return_value_discarded")
		out.append(path)
