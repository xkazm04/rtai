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

const STRIP: String = "rivet_walk8.png"
const STRIP4: String = "rivet_walk.png"
const ARMED: String = "rivet_walk_eq_"
const ROWS: int = 8
const CYCLE_CELL: Dictionary[String, float] = {"p70": 60.0, "p55": 60.0}
const MAX_CYCLES_S: float = 2.0
const META_PH: StringName = &"rivet_walk_phase"
const META_AT: StringName = &"rivet_walk_at"
static var enabled: bool = true
static var frames: int = 8
static var armed: bool = true


## The walk grid under `art`, "" when it is off, the art has none, or he is not walking bare-claw.
static func path_of(rig: CutRig, art: String, weapon: StringName) -> String:
	if not enabled or rig.speed_now <= RivetFrames.MOVING:
		return ""
	if rig.dead or rig.clips.rolling() or rig.clips.hit_t > 0.0 or rig.clips.strike_t >= 0.0:
		return ""
	if rig.clips.active() == RigClips.Clip.PUNCH:
		return ""
	var name: String = STRIP if frames == 8 else STRIP4
	if weapon != &"":
		if not armed or RivetStrips.fire_latched(rig):
			return ""
		name = ARMED + String(weapon) + ".png"
	var path: String = RivetStrips.DIR + art + "/" + name
	return path if ResourceLoader.exists(path) else ""


## True when `card` shows a walk grid (8 rows; every other strip is one row).
static func is_grid(card: Sprite2D) -> bool:
	return card != null and card.vframes == ROWS


## True when `card` shows an armed walk grid (the drawn figure carries the weapon).
static func is_armed(card: Sprite2D) -> bool:
	return is_grid(card) and str(card.get_meta(RivetFrames.ON, "")).get_file().begins_with(ARMED)


## The columns of walk grid `path`, 0 when it is not one.
static func cols_of(path: String) -> int:
	if path.ends_with("/" + STRIP):
		return 8
	return 4 if path.ends_with("/" + STRIP4) or path.get_file().begins_with(ARMED) else 0


## The grid frame for octant `o` at stride phase `phase` (one cycle = a full stride, two steps).
static func frame_of(o: int, phase: float, n: int = frames) -> int:
	var col: int = mini(int(fposmod(phase, 1.0) * n), n - 1)
	return RivetFrames.BASE_OCT[o] * n + col


## The drawn stride phase: by the ground walked since the last call (`scale`: the card's), the
## 4-frame grid by the gait phase. Called every pose step (the phase carries between grids).
static func phase_of(rig: CutRig, art: String, scale: float) -> float:
	var at: Vector2 = rig.get_meta(META_AT, rig.global_position)
	rig.set_meta(META_AT, rig.global_position)
	var cycle: float = CYCLE_CELL.get(art, 0.0) * scale
	if (frames != 8 and not is_armed(rig.head_card)) or cycle <= 0.0:
		return rig.phase
	cycle = maxf(cycle, rig.speed_now / MAX_CYCLES_S)
	var was: float = rig.get_meta(META_PH, 0.0)
	var ph: float = fposmod(was + rig.global_position.distance_to(at) / cycle, 1.0)
	rig.set_meta(META_PH, ph)
	return ph
