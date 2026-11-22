class_name KillLabTurn
extends RefCounted
## The kill reel's directions (dev arg --sig-dir=<deg>, tools/film/kill_reel.mjs): turns a solo
## KillLab's guards about Rivet's solo spot, 0 = as placed (east of him), 90 = south (screen down).
## --sig-wall[=<gap m>] (kills-new REQUEST: Gloria's pin-to-wall case) instead stands the one guard
## where a wall (the stage's push_out) is `gap` m behind him along Rivet's shot, the direction
## whose guard lies nearest the usual SOLO_OFF distance (ties: the smaller angle).
## --sig-wound (n17 npc-react): every guard takes each blow and lives (hp WOUND_HP), so the lab
## films a wound's reaction (the living hit cells) at the kill's framing instead of a kill.
## Dev capture only: a lab without these args, and every run without --sig-lab, is untouched.

const WALL_STEP_DEG: int = 5
const WALL_PROBE_M: float = 0.15
const WALL_MAX_M: float = 9.0
## Never nearer Rivet than this: the shot and the guard must read apart.
const WALL_MIN_GUARD_M: float = 2.0
const WOUND_HP: float = 100000.0


## The film probe selects a drawn card. A solo foe mix distinguishes two archetypes sharing
## that card (the contractor and patrol cop, or the SWAT and rocket trooper).
static func melee_victim(blade: StringName, args: ArenaArgs) -> StringName:
	if blade.is_empty() or blade not in MeleeTable.weapon_ids():
		return &""
	var mix: String = args.text("--foe-mix")
	if not mix.is_empty() and not mix.contains(","):
		return StringName(mix)
	match args.text("--victim"):
		"cop/head_helmet":
			return &"riot_cop"
		"cop/head_swat":
			return &"swat"
		"cop/head_cap", "":
			return &"patrol_cop"
	return &""


static func from_args(
	lab: KillLab, push_out: Callable, args: ArenaArgs = ArenaArgs.parse()
) -> void:
	for g: Fighter in lab.guards if args.has("--sig-wound") else []:
		g.hp = WOUND_HP
		g.max_hp = WOUND_HP
	if not args.has("--sig-wall"):
		apply(lab, args.number("--sig-dir", 0.0))
		return
	var gap: float = args.number("--sig-wall", 1.0) if args.text("--sig-wall") != "" else 1.0
	var deg: float = wall(lab, push_out, gap)
	if is_nan(deg):
		var why: String = "no wall %.1f m behind a guard within %.0f m" % [gap, WALL_MAX_M]
		Log.warn("kill_lab", "--sig-wall: " + why)
		return
	var d: float = lab.guards[0].pos.distance_to(lab.solo)
	Log.info("kill_lab", "--sig-wall: dir %d, guard %.2f m, wall %.2f m behind him" % [deg, d, gap])


static func apply(lab: KillLab, deg: float) -> void:
	if lab.solo == Vector2.INF or is_zero_approx(deg):
		return
	for n: int in lab.guards.size():
		var at: Vector2 = lab.solo + (lab.spots[n] - lab.solo).rotated(deg_to_rad(deg))
		lab.spots[n] = at
		lab.guards[n].pos = at


## Places the solo guard `gap_m` short of the first wall; returns the direction (deg) or NAN.
static func wall(lab: KillLab, push_out: Callable, gap_m: float) -> float:
	if lab.solo == Vector2.INF or lab.guards.size() != 1 or not push_out.is_valid():
		return NAN
	var want: float = KillLab.SOLO_OFF.length()
	var best: float = NAN
	var best_d: float = INF
	for step: int in 360 / WALL_STEP_DEG:
		var deg: float = float(step * WALL_STEP_DEG)
		var d: float = (
			first_wall_m(lab.solo, Vector2.RIGHT.rotated(deg_to_rad(deg)), push_out) - gap_m
		)
		if d >= WALL_MIN_GUARD_M and d < INF and absf(d - want) < absf(best_d - want):
			best = deg
			best_d = d
	if not is_nan(best):
		var at: Vector2 = lab.solo + Vector2.RIGHT.rotated(deg_to_rad(best)) * best_d
		lab.spots[0] = at
		lab.guards[0].pos = at
	return best


## Metres along `dir` from `from` to the first point push_out moves (INF: none within WALL_MAX_M).
static func first_wall_m(from: Vector2, dir: Vector2, push_out: Callable) -> float:
	var m: float = WALL_PROBE_M
	while m <= WALL_MAX_M:
		var p: Vector2 = from + dir * m
		if push_out.call(p) != p:
			return m
		m += WALL_PROBE_M
	return INF
