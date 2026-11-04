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
const FLASH_AHEAD_M: float = 0.15
## A round leaves the sim at the body centre; its art shows once it is this far out (past the
## claw), so a rocket never draws over Rivet's chest. Smoke starts behind that point too.
const CLEAR_M: float = 1.1

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
	match s.spec.kind:
		WeaponSpec.Kind.BULLET:
			var fx: StringName = art().projectile_fx(s.spec.id)
			_cell(ci, fx if fx != &"" else &"tracer", 0, s.pos, dir.angle(), 1.0, 1.0)
		WeaponSpec.Kind.ROCKET:
			_rocket(ci, s.pos, dir, went, tick)
		WeaponSpec.Kind.CONE:
			var k: float = clampf(went / maxf(s.spec.range_m, 0.1), 0.0, 1.0)
			var f: int = (tick / 3 + int(went * 4.0)) % 3
			_cell(ci, &"flame", f, s.pos, float(tick) * 0.2, 0.9 + 1.6 * k, 1.0 - 0.4 * k)
		WeaponSpec.Kind.BOLT:
			var tail: Vector2 = s.pos - dir * maxf(s.spec.tracer_len_m, 1.0)
			_cell(ci, &"arc", tick % 3, tail, dir.angle(), 1.0, 1.0)
			_cell(ci, &"spark", tick % 3, s.pos, float(tick) * 0.5, 0.6, 1.0)
		WeaponSpec.Kind.THROWN:
			_bottle(ci, s, went, tick)
		_:
			return false
	return true


## The muzzle flash cell on Rivet's gun for FLASH_TICKS ticks after a round; false = not drawn.
static func muzzle(ci: CanvasItem, r: Fighter, gun: GunHand) -> bool:
	if not enabled or gun.trigger == null or gun.trigger.spec == null:
		return false
	var spec: WeaponSpec = gun.trigger.spec
	var age: int = spec.interval_ticks - gun.trigger.cooldown
	if gun.shots_fired == 0 or age < 0 or age >= FLASH_TICKS or not art().has(spec.id):
		return true
	var fx: StringName = art().muzzle_fx(spec.id)
	var aim: Vector2 = r.facing.normalized()
	var reach: float = r.radius_m + FLASH_AHEAD_M + art().muzzle_m(spec.id).x * 0.5
	_cell(ci, fx, age, r.pos + aim * reach, aim.angle(), 1.0, 1.0)
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
	_cell(ci, &"flame", tick % 3, tail, float(tick), 0.45 + 0.08 * float(tick % 2), 1.0)
	_cell(ci, &"rocket", 0, at, dir.angle(), 1.0, 1.0)


static func _bottle(ci: CanvasItem, s: Shot, went: float, tick: int) -> void:
	var f: float = clampf(went / maxf(went + s.left_m, 0.1), 0.0, 1.0)
	var lift: float = 4.0 * FightAreasArt.LOB_M * f * (1.0 - f)
	var shadow: Rect2 = Rect2(Ink.px(s.pos) - Vector2(14.0, 6.0), Vector2(28.0, 12.0))
	ci.draw_rect(shadow.grow(-2.0 * lift), FightAreasArt.SCORCH)
	var up: Vector2 = s.pos + Vector2(0.0, -lift)
	var tex: Texture2D = art().held_texture(&"molotov")
	var k: float = art().world_scale(&"molotov") * Ink.PX_PER_M / WeaponArt.WORLD_PX_PER_M
	ci.draw_set_transform(Ink.px(up), float(tick) * 0.45, Vector2.ONE * k)
	ci.draw_texture(tex, -tex.get_size() * 0.5)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var wick: Vector2 = Vector2.from_angle(float(tick) * 0.45) * tex.get_width() * 0.5 * k
	_cell(ci, &"flame", tick % 3, up + wick / Ink.PX_PER_M, 0.0, 0.35, 1.0)


## Frame `frame` of fx `id` with its anchor on `at` (m), turned `angle`, `scale` x the cell scale.
static func _cell(
	ci: CanvasItem, id: StringName, frame: int, at: Vector2, angle: float, scale: float, a: float
) -> void:
	if not _frames.has(id):
		_frames[id] = art().fx_frames(id)
	var frames: Array = _frames[id]
	if frames.is_empty():
		return
	var key: StringName = StringName("%s_%d" % [id, frame]) if frames.size() > 1 else id
	ci.draw_set_transform(Ink.px(at), angle, Vector2.ONE * cell_scale() * scale)
	var tex: Texture2D = frames[frame % frames.size()]
	ci.draw_texture(tex, -art().fx_anchor(key), Color(1, 1, 1, a))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
