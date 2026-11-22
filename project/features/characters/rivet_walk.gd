class_name RivetWalk
extends RefCounted
## Locomotion follows ground distance. RivetStride documents gait modes and stride calibration.
const STRIP: String = "rivet_walk8.png"
const STRIP4: String = "rivet_walk.png"
const ARMED: String = "rivet_walk_eq_"
const RUN: String = "rivet_run8.png"
const ARMED_RUN: String = "rivet_run8_eq_"
const RUN_CYCLE_CELL: Dictionary[String, float] = {"p70": 258.0, "p55": 212.0}
## How long a speed dip keeps the walk grid (0 = the old one-tick stand in a reversal).
const DIP_TICKS: int = 3
const MOVED: StringName = &"rivet_walk_moved"
const RUN_FROM_MPS: float = 2.5
const MAX_RUN_CYCLES_S: float = 3.5
const RUN_ROW_K: Dictionary[String, float] = {
	"p70/hand_cannon/0": 0.91,
	"p70/hand_cannon/3": 0.91,
	"p70/hand_cannon/4": 0.84,
	"p70/hand_cannon/5": 0.96,
	"p70/assault_rifle/0": 0.87,
	"p70/assault_rifle/1": 0.95,
	"p70/assault_rifle/3": 0.82,
	"p70/assault_rifle/4": 0.85,
	"p70/assault_rifle/5": 0.96,
	"p70/electro_baton/0": 0.96,
	"p70/electro_baton/1": 0.90,
	"p70/electro_baton/3": 0.87,
	"p70/electro_baton/4": 0.98,
	"p70/electro_baton/5": 0.97,
	"p70/chainsaw/0": 0.89,
	"p70/chainsaw/1": 0.82,
	"p70/chainsaw/3": 0.89,
	"p70/chainsaw/4": 0.84,
	"p70/chainsaw/5": 0.88,
	"p70/rocket_launcher/0": 0.91,
	"p70/rocket_launcher/3": 0.94,
	"p70/rocket_launcher/4": 0.93,
	"p70/gloria/0": 0.98,
	"p70/gloria/3": 0.97,
	"p70/gloria/4": 0.92,
	"p70/gatling/4": 0.94,
	"p70/flamethrower/3": 0.91,
	"p70/flamethrower/4": 0.92,
	"p55/pistol/1": 0.79,
	"p55/pistol/3": 0.89,
	"p55/plasma_rifle/1": 0.76,
	"p55/plasma_rifle/3": 0.89,
	"p55/katana/1": 0.84,
	"p55/gatling/1": 0.77,
	"p55/gatling/3": 0.83,
	"p55/gatling/4": 0.92,
	"p55/flamethrower/1": 0.68,
	"p55/flamethrower/3": 0.93,
}
const ROWS: int = 8
## n11 grids pack at 1.5x for the larger player. Cycle values stay in 110 px figure space.
const RES: float = 1.5
const CYCLE_CELL: Dictionary[String, float] = {"p70": 60.0, "p55": 60.0}
const ARMED_CYCLE_CELL: Dictionary[String, float] = {
	"p70/hand_cannon": 69.7,
	"p70/assault_rifle": 78.0,
	"p70/electro_baton": 68.7,
	"p70/chainsaw": 64.3,
	"p70/rocket_launcher": 84.0,
	"p70/gloria": 86.7,
	"p70/pistol": 76.0,
	"p70/plasma_rifle": 76.0,
	"p70/katana": 66.0,
	"p70/gatling": 68.0,
	"p55/pistol": 77.0,
	"p55/plasma_rifle": 74.0,
	"p55/katana": 72.0,
	"p55/gatling": 81.0,
}
const MAX_CYCLES_S: float = 2.0
const META_PH: StringName = &"rivet_walk_phase"
const META_AT: StringName = &"rivet_walk_at"
static var enabled: bool = true
static var frames: int = 8
static var armed: bool = true
static var run: bool = true


## A reversal stays walking for DIP_TICKS. Reject stale ages after a pooled rig resets.
static func moving(rig: CutRig) -> bool:
	if rig.speed_now > RivetFrames.MOVING:
		rig.set_meta(MOVED, rig.t_alive)
		return true
	var moved: float = rig.get_meta(MOVED, -INF)
	var age: float = rig.t_alive - moved
	return age >= 0.0 and age <= DIP_TICKS * SimClock.TICK_DT


## Live selection keeps the actual weapon for pose gates even when its legs come from another grid.
static func motion_path(rig: CutRig, art: String, weapon: StringName) -> String:
	return path_of(rig, art, weapon, RivetFramesGrids.grid_for(weapon))


## Query the weapon's own drawing first. Without a fallback this answers only for its own art.
static func path_of(
	rig: CutRig, art: String, weapon: StringName, fallback: StringName = &""
) -> String:
	if not enabled or not moving(rig):
		return ""
	if rig.dead or rig.clips.rolling() or rig.clips.hit_t > 0.0 or rig.clips.strike_t >= 0.0:
		return ""
	if rig.clips.active() == RigClips.Clip.PUNCH:
		return ""
	if weapon != &"" and (not armed or RivetStrips.fire_latched(rig)):
		return ""
	var dir: String = RivetStrips.DIR + art + "/"
	var fast: bool = run and frames == 8 and rig.speed_now > RUN_FROM_MPS * CharacterRigs.PX_PER_M
	var own: String = _grid(dir, WeaponArtKey.of(weapon), fast)
	if own != "" or fallback == &"" or fallback == weapon:
		return own
	return _grid(dir, fallback, fast)


static func _grid(dir: String, id: StringName, fast: bool) -> String:
	var bare: bool = id == &"" or id == RivetFramesGrids.BARE
	var walk: String = (STRIP if frames == 8 else STRIP4) if bare else ARMED + String(id) + ".png"
	var running: String = dir + (RUN if bare else ARMED_RUN + String(id) + ".png")
	var path: String = running if fast and RivetStrips.has_file(running) else dir + walk
	return path if RivetStrips.has_file(path) else ""


## True when `card` shows a walk grid (8 rows; every other strip is one row).
static func is_grid(card: Sprite2D) -> bool:
	return card != null and card.vframes == ROWS


## Texture pixels per 110-space pixel. Packed grids use RES and a one-row strip uses RivetRes.
static func res_of(card: Sprite2D) -> float:
	var on: String = str(card.get_meta(RivetFrames.ON, ""))
	return RES if is_grid(card) else RivetRes.of(on)


## True when `card` shows an armed walk grid (the drawn figure carries the weapon).
static func is_armed(card: Sprite2D) -> bool:
	var file: String = str(card.get_meta(RivetFrames.ON, "")).get_file() if card != null else ""
	return is_grid(card) and (file.begins_with(ARMED) or file.begins_with(ARMED_RUN))


## The columns of walk grid `path`, 0 when it is not one.
static func cols_of(path: String) -> int:
	if path.ends_with("/" + STRIP) or path.ends_with("/" + RUN) or is_run(path):
		return 8
	return 4 if path.ends_with("/" + STRIP4) or path.get_file().begins_with(ARMED) else 0


static func is_run(path: String) -> bool:
	return path.ends_with("/" + RUN) or path.get_file().begins_with(ARMED_RUN)


static func frame_of(o: int, phase: float, n: int = frames) -> int:
	var col: int = mini(int(fposmod(phase, 1.0) * n), n - 1)
	return RivetFrames.BASE_OCT[o] * n + col


## Each pose step carries the ground-distance phase between grids. Walk4 uses the gait phase.
static func phase_of(rig: CutRig, art: String, scale: float) -> float:
	var at: Vector2 = rig.get_meta(META_AT, rig.global_position)
	rig.set_meta(META_AT, rig.global_position)
	var card: Sprite2D = rig.head_card
	var running: bool = card != null and is_run(str(card.get_meta(RivetFrames.ON, "")))
	var cycle: float = cycle_cell(card, art, running) * scale * row_k(card, art, rig)
	if (frames != 8 and not is_armed(rig.head_card)) or cycle <= 0.0:
		return rig.phase
	if not running:
		cycle = RivetStride.profile_cycle(card, scale / RES, cycle)
	cycle = maxf(cycle, rig.speed_now / (MAX_RUN_CYCLES_S if running else MAX_CYCLES_S))
	var was: float = rig.get_meta(META_PH, 0.0)
	var step: float = rig.global_position.distance_to(at) / cycle
	var ph: float = fposmod(was + step * _direction(rig), 1.0)
	rig.set_meta(META_PH, ph)
	return ph


## +1 steps the grid forward, -1 backward on a backpedal (no head yet: forward).
static func _direction(rig: CutRig) -> float:
	return RivetStride.direction(rig, RivetFrames.oct_of(rig)) if rig.head != null else 1.0


static func cycle_cell(card: Sprite2D, art: String, running: bool) -> float:
	if running:
		return RUN_CYCLE_CELL.get(art, 0.0)
	if is_armed(card):
		var w: String = str(card.get_meta(RivetFrames.ON, "")).get_file().trim_prefix(ARMED)
		return ARMED_CYCLE_CELL.get(art + "/" + w.get_basename(), CYCLE_CELL.get(art, 0.0))
	return CYCLE_CELL.get(art, 0.0)


static func row_k(card: Sprite2D, art: String, rig: CutRig) -> float:
	var file: String = str(card.get_meta(RivetFrames.ON, "")).get_file() if card != null else ""
	if not file.begins_with(ARMED_RUN):
		return 1.0
	var weapon: String = file.trim_prefix(ARMED_RUN).get_basename()
	var row: int = RivetStride.row(rig, RivetFrames.oct_of(rig))
	var key: String = "%s/%s/%d" % [art, weapon, row]
	return RUN_ROW_K.get(key, 1.0)
