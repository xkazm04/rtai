class_name WeaponFxArt
extends RefCounted
## weapon-art: the lane's inked FX cells (data/tables/weapon_art.json `fx`) in the live fight.
## Quest 1's FxView and gunplay's FightAreasArt ask here first and fall back to their procedural
## shapes when this answers false: Rivet's rounds (tracer, Gloria's nail, the rocket with its
## smoke puffs, flame puffs, the electro arc, the spinning molotov bottle), the muzzle flash
## frames on the gun, and the rocket blast (paper burst, vermilion fireball, smoke ring, a dying
## ring) over its scorch decal. World px via Ink.px. Render only: reads the sim, writes nothing.
## `enabled` false (or `--weapon-fx=shapes`) is the before: gunplay's shapes.

const BLAST_FRAMES: PackedInt32Array = [0, 4, 10, 20, 30]
## Smoke puffs behind the rocket: count and spacing (m).
const PUFFS: int = 6
const PUFF_GAP_M: float = 0.45
## The muzzle flash plays one frame per tick for this many ticks after a round leaves.
const FLASH_TICKS: int = 3
## Where the flash sits ahead of the body edge along the aim (m), plus the gun's muzzle_m.
const FLASH_AHEAD_M: float = 0.45
## The gun claw sits this far to the left of the aim line (aim.orthogonal()) on the cast rig
## (measured in the 64 px/m arena clip: the flash on the centre line missed the held gun).
const GUN_SIDE_M: float = 0.35
## A drawn round starts on the gun's side and reaches the sim's line (body centre) this far out.
const CONVERGE_M: float = 3.0
## The thrown molotov draws this much bigger than the held one (at 1.0 it was a speck in flight).
const BOTTLE_K: float = 1.8
## The flamethrower's nozzle lick: the jet's tongue cell at this scale (1.0 read as a balloon).
const NOZZLE_K: float = 0.45
## A round leaves the sim at the body centre; its art shows once it is this far out (past the
## claw), so a rocket never draws over Rivet's chest. Smoke starts behind that point too.
const CLEAR_M: float = 1.1
## The electro arc cell spans ARC_SPAN_PX part px (tail anchor to head); drawn at least ARC_MIN_M.
const ARC_SPAN_PX: float = 296.0
const ARC_MIN_M: float = 2.0

static var enabled: bool = not OS.get_cmdline_user_args().has("--weapon-fx=shapes")
static var _art: WeaponArt = null
static var _frames: Dictionary[StringName, Array] = {}


static func art() -> WeaponArt:
	if _art == null:
		_art = WeaponArt.new()
	return _art


## The cell scale from part px to the view's world px (fx_draw_scale x the rig part scale).
static func cell_scale() -> float:
	return art().fx_draw_scale * Ink.PX_PER_M / art().rig_px_per_m


## Rivet's round as art; false leaves it to the caller (enemy rounds stay vermilion danger).
static func shot(ci: CanvasItem, s: Shot, tick: int) -> bool:
	if not enabled or s.spec == null or not s.from_rivet:
		return false
	var dir: Vector2 = s.vel.normalized()
	var went: float = s.origin.distance_to(s.pos)
	if went < CLEAR_M and s.spec.kind != WeaponSpec.Kind.CONE:
		return true
	# drawn out of the held gun (left of the aim line), converging onto the sim's line by CONVERGE_M
	var side: float = GUN_SIDE_M * clampf(1.0 - (went - CLEAR_M) / CONVERGE_M, 0.0, 1.0)
	var at: Vector2 = s.pos + dir.orthogonal() * side
	match s.spec.kind:
		WeaponSpec.Kind.BULLET:
			var fx: StringName = art().projectile_fx(s.spec.id)
			_cell(ci, fx if fx != &"" else &"tracer", 0, at, dir.angle(), 1.0, 1.0)
		WeaponSpec.Kind.ROCKET:
			_rocket(ci, at, dir, went, tick)
		WeaponSpec.Kind.CONE:
			_jet(ci, s, dir, went, tick)
		WeaponSpec.Kind.BOLT:
			var len_m: float = maxf(s.spec.tracer_len_m, ARC_MIN_M)
			var span: float = len_m * Ink.PX_PER_M / (ARC_SPAN_PX * cell_scale())
			_cell_v(ci, &"arc", tick % 3, at - dir * len_m, dir.angle(), Vector2(span, 1.0), 1.0)
			_cell(ci, &"spark", tick % 3, at, float(tick) * 0.5, 1.1, 1.0)
		WeaponSpec.Kind.THROWN:
			_bottle(ci, s, went, tick)
		_:
			return false
	return true


## The muzzle flash cell on Rivet's gun for FLASH_TICKS ticks after a round; false = not drawn.
## Also throws and draws the spent brass (WeaponCasings) of casing guns.
static func muzzle(ci: CanvasItem, r: Fighter, gun: GunHand, tick: int) -> bool:
	if not enabled or gun.trigger == null or gun.trigger.spec == null:
		return false
	var spec: WeaponSpec = gun.trigger.spec
	var brass: StringName = art().casing_fx(spec.id) if art().has(spec.id) else &""
	WeaponCasings.track(r, gun, tick, brass)
	WeaponCasings.draw(ci, tick, brass)
	var age: int = spec.interval_ticks - gun.trigger.cooldown
	if gun.shots_fired == 0 or age < 0 or age >= FLASH_TICKS or not art().has(spec.id):
		return true
	var fx: StringName = art().muzzle_fx(spec.id)
	if fx == &"":  # a throw (the molotov) has no flash: the wick already burns on the bottle
		return true
	var aim: Vector2 = r.facing.normalized()
	var reach: float = r.radius_m + FLASH_AHEAD_M + art().muzzle_m(spec.id).x * 0.5
	var at: Vector2 = r.pos + aim * reach + aim.orthogonal() * GUN_SIDE_M
	# the flame cell is the jet's full tongue: at the nozzle only a small lick
	_cell(ci, fx, age, at, aim.angle(), NOZZLE_K if fx == &"flame" else 1.0, 1.0)
	return true


## A rocket blast `b` (x, y, radius m) `age` ticks old; false = not drawn (the caller's shapes).
static func blast(ci: CanvasItem, b: Vector3, age: int) -> bool:
	if not enabled:
		return false
	var at: Vector2 = Vector2(b.x, b.y)
	# the scorch decal stays under it for the whole VFX life, fading out
	var keep: float = float(FightAreas.VFX_KEEP_TICKS)
	var s_scale: float = 2.0 * b.z * Ink.PX_PER_M / 400.0 / cell_scale()
	_cell(ci, &"scorch", 0, at, b.x * 1.7, s_scale, clampf(1.0 - float(age) / keep, 0.0, 0.85))
	var f: int = BLAST_FRAMES.size() - 2
	while f > 0 and age < BLAST_FRAMES[f]:
		f -= 1
	if age >= BLAST_FRAMES[-1]:
		return true
	var into: float = float(age - BLAST_FRAMES[f]) / float(BLAST_FRAMES[f + 1] - BLAST_FRAMES[f])
	var fade: float = 1.0 - into * 0.6 if f == 3 else 1.0
	# frame sizes grow 300 -> 480 part px; the last frame spans the splash diameter
	var size_k: float = 2.0 * b.z * Ink.PX_PER_M / 480.0 / cell_scale()
	_cell(ci, &"blast", f, at, b.y * 0.9, size_k * (1.0 + 0.08 * into), fade)
	return true


## The flamethrower stream: tongues along the jet, growing and fading with range.
static func _jet(ci: CanvasItem, s: Shot, dir: Vector2, went: float, tick: int) -> void:
	var k: float = clampf(went / maxf(s.spec.range_m, 0.1), 0.0, 1.0)
	var f: int = (tick / 3 + int(went * 4.0)) % 3
	var lick: float = dir.angle() + sin(float(tick) * 0.7 + went * 3.0) * 0.18
	# long and thin at the nozzle, fanning out with distance (round puffs near it read as drops)
	var grow: Vector2 = Vector2(1.15 + 0.6 * k, 0.32 + 1.5 * k)
	# a second tongue halfway back to the previous puff closes the gap: one gushing jet
	var gap: float = s.spec.speed_mps * float(s.spec.interval_ticks) / 120.0
	if went > gap + CLEAR_M:
		_cell_v(ci, &"flame", f + 1, s.pos - dir * gap, -lick + 2.0 * dir.angle(), grow * 0.85, 1.0)
	_cell_v(ci, &"flame", f, s.pos, lick, grow, 1.0 - 0.35 * k)


static func _rocket(ci: CanvasItem, at: Vector2, dir: Vector2, went: float, tick: int) -> void:
	var side: Vector2 = dir.orthogonal()
	for k: int in range(PUFFS - 1, -1, -1):
		var back: float = 1.0 + float(k) * PUFF_GAP_M
		if back > went - CLEAR_M * 0.5:
			continue
		var wob: Vector2 = side * sin(float(tick - k * 3) * 0.8) * 0.06 * float(k)
		var grow: float = 0.55 + 0.18 * float(k)
		_cell(
			ci, &"smoke", (k + tick / 4) % 3, at - dir * back + wob, float(k), grow, 1.0 - 0.13 * k
		)
	var tail: Vector2 = at - dir * 1.15
	_cell(ci, &"flame", tick % 3, tail, dir.angle(), 0.42 + 0.08 * float(tick % 2), 1.0)
	_cell(ci, &"rocket", 0, at, dir.angle(), 1.0, 1.0)


static func _bottle(ci: CanvasItem, s: Shot, went: float, tick: int) -> void:
	var f: float = clampf(went / maxf(went + s.left_m, 0.1), 0.0, 1.0)
	var lift: float = 4.0 * FightAreasArt.LOB_M * f * (1.0 - f)
	var shadow: Rect2 = Rect2(Ink.px(s.pos) - Vector2(14.0, 6.0), Vector2(28.0, 12.0))
	ci.draw_rect(shadow.grow(-2.0 * lift), FightAreasArt.SCORCH)
	var up: Vector2 = s.pos + Vector2(0.0, -lift)
	var tex: Texture2D = art().held_texture(&"molotov")
	var k: float = (
		art().world_scale(&"molotov") * Ink.PX_PER_M / WeaponArt.WORLD_PX_PER_M * BOTTLE_K
	)
	ci.draw_set_transform(Ink.px(up), float(tick) * 0.45, Vector2.ONE * k)
	ci.draw_texture(tex, -tex.get_size() * 0.5)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var wick: Vector2 = Vector2.from_angle(float(tick) * 0.45) * tex.get_width() * 0.5 * k
	_cell(ci, &"flame", tick % 3, up + wick / Ink.PX_PER_M, -PI * 0.5, 0.45, 1.0)


## Frame `frame` of fx `id` with its anchor on `at` (m), turned `angle`, `scale` x the cell scale.
static func _cell(
	ci: CanvasItem, id: StringName, frame: int, at: Vector2, angle: float, scale: float, a: float
) -> void:
	_cell_v(ci, id, frame, at, angle, Vector2.ONE * scale, a)


## Draws fx cell `id` (frame `frame`) at `at` (m), rotated, scaled per axis (cell px), alpha `a`.
static func draw_cell(
	ci: CanvasItem, id: StringName, frame: int, at: Vector2, angle: float, scale: Vector2
) -> void:
	_cell_v(ci, id, frame, at, angle, scale, 1.0)


## As _cell with a per-axis `scale` (x along the cell's +x: a jet or a bolt stretched to length).
static func _cell_v(
	ci: CanvasItem, id: StringName, frame: int, at: Vector2, angle: float, scale: Vector2, a: float
) -> void:
	if not _frames.has(id):
		_frames[id] = art().fx_frames(id)
	var frames: Array = _frames[id]
	if frames.is_empty():
		return
	var key: StringName = StringName("%s_%d" % [id, frame]) if frames.size() > 1 else id
	ci.draw_set_transform(Ink.px(at), angle, scale * cell_scale())
	var tex: Texture2D = frames[frame % frames.size()]
	ci.draw_texture(tex, -art().fx_anchor(key), Color(1, 1, 1, a))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
