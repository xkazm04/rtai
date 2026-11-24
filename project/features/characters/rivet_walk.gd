class_name RivetWalk
extends RefCounted
## One full stride (two steps) advances by the distance Rivet crosses on the ground.
## Walk8 draws contact, down, passing and up for each foot. Run8 adds flight.
## Native weapon grids carry their own arms. Borrowed bare grids retain the equipped part.

const STRIP: String = "rivet_walk8.png"
const STRIP4: String = "rivet_walk.png"
const ARMED: String = "rivet_walk_eq_"
const RUN: String = "rivet_run8.png"
const ARMED_RUN: String = "rivet_run8_eq_"
const DIP_TICKS: int = 3  ## Keep the grid through speed dips. Zero restores the one-tick stand.
const MOVED: StringName = &"rivet_walk_moved"
const RUN_FROM_MPS: float = 2.5
const MAX_RUN_CYCLES_S: float = 3.5
const ROWS: int = 8  ## is_grid recognizes eight-row walk and run grids. Other strips have one row.
const RES: float = 1.5  ## n11 grid texels per 110-space pixel. One-row strips use RivetRes.
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
	var own: String = ""
	if not RivetFramesGrids.held_only(weapon, art):
		own = _grid(dir, WeaponArtKey.of(weapon), fast)
	if fast and own != "" and not is_run(own) and fallback != &"" and fallback != weapon:
		var borrowed: String = _grid(dir, fallback, true)  ## walk sheet only: sprint borrows
		return borrowed if is_run(borrowed) else own
	if own != "" or fallback == &"" or fallback == weapon:
		return own
	return _grid(dir, fallback, fast)


static func _grid(dir: String, id: StringName, fast: bool) -> String:
	var bare: bool = id == &"" or id == RivetFramesGrids.BARE
	var walk: String = (STRIP if frames == 8 else STRIP4) if bare else ARMED + String(id) + ".png"
	var running: String = dir + (RUN if bare else ARMED_RUN + String(id) + ".png")
	var path: String = running if fast and RivetStrips.has_file(running) else dir + walk
	return path if RivetStrips.has_file(path) else ""


static func is_grid(card: Sprite2D) -> bool:
	return card != null and card.vframes == ROWS


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


## Changing sheets preserves phase so a moving weapon swap stays on the same step.
## Each pose step carries the ground-distance phase between grids. Walk4 uses the gait phase.
static func phase_of(rig: CutRig, art: String, scale: float) -> float:
	var at: Vector2 = rig.get_meta(META_AT, rig.global_position)
	rig.set_meta(META_AT, rig.global_position)
	var card: Sprite2D = rig.head_card
	var running: bool = card != null and is_run(str(card.get_meta(RivetFrames.ON, "")))
	var cycle: float = cycle_cell(card, art, running) * scale * row_k(card, art, rig)
	if (frames != 8 and not is_armed(rig.head_card)) or cycle <= 0.0:
		return rig.phase
	var was: float = rig.get_meta(META_PH, 0.0)
	var distance: float = rig.global_position.distance_to(at) * _direction(rig)
	var cycles: Vector2 = _bare_cycles(card, art, rig, scale)
	var ph: float
	if cycles.x > 0.0 and cycles.y > 0.0:
		ph = bare_phase(was, distance, cycles)
	else:
		if not running:
			cycle = RivetStride.profile_cycle(card, scale / RES, cycle)
		cycle = maxf(cycle, rig.speed_now / (MAX_RUN_CYCLES_S if running else MAX_CYCLES_S))
		ph = fposmod(was + distance / cycle, 1.0)
	rig.set_meta(META_PH, ph)
	return ph


## +1 steps the grid forward, -1 backward on a backpedal (no head yet: forward).
static func _direction(rig: CutRig) -> float:
	return RivetStride.direction(rig, RivetFrames.oct_of(rig)) if rig.head != null else 1.0


## Full cycle in 110-space pixels. Unmeasured armed walks share the bare walk for the pitch.
static func cycle_cell(card: Sprite2D, art: String, running: bool) -> float:
	var grid: RivetGridStride = RivetGridStride.shared()
	if running:
		return grid.run_cycle_cell.get(art, 0.0)
	if is_armed(card):
		var w: String = str(card.get_meta(RivetFrames.ON, "")).get_file().trim_prefix(ARMED)
		return grid.armed_cycle_cell.get(
			art + "/" + w.get_basename(), grid.cycle_cell.get(art, 0.0)
		)
	return grid.cycle_cell.get(art, 0.0)


## Ratio of the armed row travel to the bare run. Unmeasured rows keep 1.
static func row_k(card: Sprite2D, art: String, rig: CutRig) -> float:
	var file: String = str(card.get_meta(RivetFrames.ON, "")).get_file() if card != null else ""
	if not file.begins_with(ARMED_RUN):
		return 1.0
	var weapon: String = file.trim_prefix(ARMED_RUN).get_basename()
	var row: int = RivetStride.row(rig, RivetFrames.oct_of(rig))
	var key: String = "%s/%s/%d" % [art, weapon, row]
	return RivetGridStride.shared().run_row_k.get(key, 1.0)


## Advance through two measured half-strides. Carry any unused ground distance across
## contact, wrap and reversal, including when the two boots have different stance lengths.
static func bare_phase(was: float, distance: float, cycles: Vector2) -> float:
	var first: float = cycles.x * 0.5
	var full: float = first + cycles.y * 0.5
	var at: float = was * cycles.x if was < 0.5 else first + (was - 0.5) * cycles.y
	at = fposmod(at + distance, full)
	return at / cycles.x if at < first else 0.5 + (at - first) / cycles.y


static func _bare_cycles(card: Sprite2D, art: String, rig: CutRig, scale: float) -> Vector2:
	if card == null or card.texture == null or RivetFrames.weapon_of(rig) != &"":
		return Vector2.ZERO
	var file: String = str(card.get_meta(RivetFrames.ON, "")).get_file()
	if file != STRIP and file != RUN:
		return Vector2.ZERO
	var grid: RivetGridStride = RivetGridStride.shared()
	var row: int = RivetFrames.BASE_OCT[RivetStride.row(rig, RivetFrames.oct_of(rig))]
	var by_row: PackedVector2Array = (
		grid.bare_run.get(art, PackedVector2Array())
		if file == RUN
		else grid.bare_walk.get(art, PackedVector2Array())
	)
	if by_row.size() != ROWS:
		return Vector2.ZERO
	# A boot with too little drawn travel keeps the pitch's original gait and speed cap.
	var running: bool = file == RUN
	var base: float = cycle_cell(card, art, running) * scale
	var minimum: float = base * grid.bare_min_travel
	var original: float = maxf(
		base, rig.speed_now / (MAX_RUN_CYCLES_S if running else MAX_CYCLES_S)
	)
	var mps: float = rig.speed_now / CharacterRigs.PX_PER_M
	var travel: Vector2 = by_row[row] * scale * (grid.sprint_k(art, row, mps) if running else 1.0)
	var capped: Vector2 = travel.max(Vector2.ONE * (rig.speed_now / grid.bare_max_cycles_s))
	return Vector2(
		original if travel.x < minimum else capped.x, original if travel.y < minimum else capped.y
	)
