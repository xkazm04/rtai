class_name RivetWalk
extends RefCounted
## d9 rivet (Call 2): bare-claw Rivet's drawn stride, when the art key has one. n9: the library's
## 8-frame walk (`rivet_walk8.png`, tools/art/rivet_walk.py --cols=8: contact, down, passing, up,
## contact (other foot), down, passing, up; 8 rows in RivetFrames' base cell order), stepped by the
## ground walked: one drawn cycle = CYCLE_CELL cell px x the card's scale, the stance foot's drawn
## travel over a stride (measured on the profile rows, evidence/n9/rivet_walk8_measure.md), so a
## planted foot stays put; above MAX_CYCLES_S the cadence holds there (his 6.75 m/s walk would
## need ~7.5 cycles a second: a drawn walk cannot plant at a run's speed, see the run REQUEST).
## --rivet-walk=4 plays d9's 4-frame grid by the gait phase, --rivet-walk=bob the facing card.
## n9 it4: a weapon out walks on its drawn armed grid (`rivet_walk_eq_<weapon>.png`, 4 frames, the
## library's armed walks for the weapon each draws) until a shot or a strike latches the equipped
## strip's fire cell; --rivet-walk-armed=off keeps the equipped facing card (d9's bob).
## n9 it4: bare-claw above RUN_FROM_MPS he runs on the library's 8-frame run (`rivet_run8.png`,
## flight frames), cadence capped at MAX_RUN_CYCLES_S; --rivet-walk=walk8 keeps the walk at every
## speed. RUN_CYCLE_CELL (it5): in the grid's profile rows the stance foot moves 62-67 cell px from
## contact to push-off, two frame steps, so one frame step = ~32 cell px of ground and a cycle 8 x
## that (it4 wired 136 = the travel per half cycle: the legs churned 1.9x, the foot slid back).
## it6: p55 measured the same way: ~53 cell px over two steps, 26.5 a step, a cycle of 212.
## it6: each armed grid has its own cycle (ARMED_CYCLE_CELL, "<art>/<weapon>"): the profile
## rows' stance boot from contact to the next contact (two of the 4 frame steps) x 2, mean of
## the right and left rows (evidence/n9/rivet_walk_armed_cycle.md); the flamer shuffles: CYCLE_CELL.
## it7: above RUN_FROM_MPS a weapon out runs on its drawn armed run (`rivet_run8_eq_<weapon>.png`,
## the library's run8 legs + the claw armed walk's arms, my it6 REQUEST) where the art key has one,
## stepped on RUN_CYCLE_CELL (its legs are run8's, frame by frame); else the armed walk as before.
## it8: RUN_ROW_K ("<art>/<weapon>/<octant>"): a drawn run row whose stride is shorter than run8's
## (cell px on the packed grid) steps on a cycle shortened by that ratio, so its stance foot plants.

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
## measured on the packed grids (cell px of stance travel, the row's vs run8's same row): the
## heavy left profile 59 / 63; the one-hand 55 3/4 toward right (row 2 B) 43 / 54.5, toward
## left 49 / 55; the two-hand 55 3/4 toward right (row 2 B) 41.5 / 54.5, toward left 49 / 55;
## the blade 55 3/4 toward right (row 2 B) 46 / 54.5 (its toward left 53 / 55: within 5 %, none);
## the heavy 55 3/4 toward right 42 / 54.5, 3/4 toward left 45.5 / 55, left profile (L2 B) 46 / 50;
## the flamer 70 3/4 toward left 42 / 46, left profile (L2 B) 58 / 63; the flamer 55 3/4 toward
## right (row 2 B) 37 / 54.5, toward left 51 / 55 (its left profile 50 / 50: none)
const RUN_ROW_K: Dictionary[String, float] = {
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
const CYCLE_CELL: Dictionary[String, float] = {"p70": 60.0, "p55": 60.0}
const ARMED_CYCLE_CELL: Dictionary[String, float] = {
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


## True while he walks, or a reversal carried his speed through zero within DIP_TICKS (n10: that
## tick drew the standing or reload cell inside the walk). A real stop stands DIP_TICKS later.
## The age is checked both ways: CutRig.reset restarts t_alive and the meta survives the pool.
static func moving(rig: CutRig) -> bool:
	if rig.speed_now > RivetFrames.MOVING:
		rig.set_meta(MOVED, rig.t_alive)
		return true
	var moved: float = rig.get_meta(MOVED, -INF)
	var age: float = rig.t_alive - moved
	return age >= 0.0 and age <= DIP_TICKS * SimClock.TICK_DT


## The walk grid under `art`, "" when it is off, the art has none, or he is not walking bare-claw.
static func path_of(rig: CutRig, art: String, weapon: StringName) -> String:
	if not enabled or not moving(rig):
		return ""
	if rig.dead or rig.clips.rolling() or rig.clips.hit_t > 0.0 or rig.clips.strike_t >= 0.0:
		return ""
	if rig.clips.active() == RigClips.Clip.PUNCH:
		return ""
	var name: String = STRIP if frames == 8 else STRIP4
	var fast: bool = rig.speed_now > RUN_FROM_MPS * CharacterRigs.PX_PER_M
	if run and frames == 8 and fast and ResourceLoader.exists(RivetStrips.DIR + art + "/" + RUN):
		name = RUN
	if weapon != &"":
		if not armed or RivetStrips.fire_latched(rig):
			return ""
		name = ARMED + String(weapon) + ".png"
		var armed_run: String = ARMED_RUN + String(weapon) + ".png"
		var drawn_run: bool = ResourceLoader.exists(RivetStrips.DIR + art + "/" + armed_run)
		name = armed_run if run and frames == 8 and fast and drawn_run else name
	var path: String = RivetStrips.DIR + art + "/" + name
	return path if ResourceLoader.exists(path) else ""


## True when `card` shows a walk grid (8 rows; every other strip is one row).
static func is_grid(card: Sprite2D) -> bool:
	return card != null and card.vframes == ROWS


## True when `card` shows an armed walk grid (the drawn figure carries the weapon).
static func is_armed(card: Sprite2D) -> bool:
	var file: String = str(card.get_meta(RivetFrames.ON, "")).get_file() if card != null else ""
	return is_grid(card) and (file.begins_with(ARMED) or file.begins_with(ARMED_RUN))


## The columns of walk grid `path`, 0 when it is not one.
static func cols_of(path: String) -> int:
	if path.ends_with("/" + STRIP) or path.ends_with("/" + RUN) or is_run(path):
		return 8
	return 4 if path.ends_with("/" + STRIP4) or path.get_file().begins_with(ARMED) else 0


## True for a run grid, bare or armed (both step on RUN_CYCLE_CELL: the same drawn legs).
static func is_run(path: String) -> bool:
	return path.ends_with("/" + RUN) or path.get_file().begins_with(ARMED_RUN)


## The grid frame for octant `o` at stride phase `phase` (one cycle = a full stride, two steps).
static func frame_of(o: int, phase: float, n: int = frames) -> int:
	var col: int = mini(int(fposmod(phase, 1.0) * n), n - 1)
	return RivetFrames.BASE_OCT[o] * n + col


## The drawn stride phase: by the ground walked since the last call (`scale`: the card's), the
## 4-frame grid by the gait phase. Called every pose step (the phase carries between grids).
static func phase_of(rig: CutRig, art: String, scale: float) -> float:
	var at: Vector2 = rig.get_meta(META_AT, rig.global_position)
	rig.set_meta(META_AT, rig.global_position)
	var card: Sprite2D = rig.head_card
	var running: bool = card != null and is_run(str(card.get_meta(RivetFrames.ON, "")))
	var cycle: float = cycle_cell(card, art, running) * scale * row_k(card, art, rig)
	if (frames != 8 and not is_armed(rig.head_card)) or cycle <= 0.0:
		return rig.phase
	cycle = maxf(cycle, rig.speed_now / (MAX_RUN_CYCLES_S if running else MAX_CYCLES_S))
	var was: float = rig.get_meta(META_PH, 0.0)
	var ph: float = fposmod(was + rig.global_position.distance_to(at) / cycle, 1.0)
	rig.set_meta(META_PH, ph)
	return ph


## The drawn cycle in cell px of the grid `card` shows under `art` (it6: per armed grid).
static func cycle_cell(card: Sprite2D, art: String, running: bool) -> float:
	if running:
		return RUN_CYCLE_CELL.get(art, 0.0)
	if is_armed(card):
		var w: String = str(card.get_meta(RivetFrames.ON, "")).get_file().trim_prefix(ARMED)
		return ARMED_CYCLE_CELL.get(art + "/" + w.get_basename(), CYCLE_CELL.get(art, 0.0))
	return CYCLE_CELL.get(art, 0.0)


## The stride ratio of the drawn run row `card` shows for `rig`'s octant (RUN_ROW_K, else 1).
static func row_k(card: Sprite2D, art: String, rig: CutRig) -> float:
	var file: String = str(card.get_meta(RivetFrames.ON, "")).get_file() if card != null else ""
	if not file.begins_with(ARMED_RUN):
		return 1.0
	var weapon: String = file.trim_prefix(ARMED_RUN).get_basename()
	var key: String = "%s/%s/%d" % [art, weapon, RivetFrames.oct_of(rig)]
	return RUN_ROW_K.get(key, 1.0)
