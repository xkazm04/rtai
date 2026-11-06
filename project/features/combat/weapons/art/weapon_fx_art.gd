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
## A bottle's burst (its fire patch is the splash) holds only the star frame this long, fading
## over the last half: the rocket's smoke and bead rings read as debug over the fire (REQUEST 31).
## `--fire-burst=off` = a bottle plays the rocket's four frames (the before).
const FIRE_BURST_TICKS: int = 10
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
## The bottle's ground shadow: the shell's ink ellipse at this size and ink (was a 28x12 px dash).
const BOTTLE_SHADOW_K: float = 0.8
const BOTTLE_SHADOW_INK: float = 0.6
## The flamethrower's nozzle lick: the jet's tongue cell at this scale (1.0 read as a balloon).
const NOZZLE_K: float = 0.45
## The cone slices' lick swing (rad) about the aim (the teardrops keep 0.18: at 0.18 the long
## cone slices lay parallel and banded like planks at 48 px/m).
const CONE_LICK: float = 0.24
## A round leaves the sim at the body centre; its art shows once it is this far out (past the
## claw), so a rocket never draws over Rivet's chest. Smoke starts behind that point too.
const CLEAR_M: float = 1.1
## The electro arc cell spans ARC_SPAN_PX part px (tail anchor to head); drawn at least ARC_MIN_M.
const ARC_SPAN_PX: float = 296.0
const ARC_MIN_M: float = 2.0

static var enabled: bool = not OS.get_cmdline_user_args().has("--weapon-fx=shapes")
static var fire_burst: bool = not OS.get_cmdline_user_args().has("--fire-burst=off")
## The blast's last frame (a ring of cream discs) read as debug beads; by default the smoke ring
## (frame 2) holds through it, growing and thinning. `--blast-beads=on` = the before.
static var blast_beads: bool = OS.get_cmdline_user_args().has("--blast-beads=on")
## n5-look: while set (FxView's draw), every cell prints in colour on this canvas (WeaponFxColour).
static var colour: WeaponFxColour = null
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
	var at: Vector2 = ShotLift.round_at(ci, s, s.pos + dir.orthogonal() * side, went - CLEAR_M)
	match s.spec.kind:
		WeaponSpec.Kind.BULLET:
			var fx: StringName = art().projectile_fx(s.spec.id)
			var k: float = art().round_k.get(s.spec.id, 1.0)
			var fx_k: Vector2 = Vector2(sqrt(k), k)
			_cell_v(ci, fx if fx != &"" else &"tracer", 0, at, dir.angle(), fx_k, 1.0)
		WeaponSpec.Kind.ROCKET:
			_rocket(ci, at, dir, went, tick)
		WeaponSpec.Kind.CONE:
			_jet(ci, s, dir, went, tick)
		WeaponSpec.Kind.BOLT when WeaponFxRay.FX.has(art().projectile_fx(s.spec.id)):
			WeaponFxRay.draw(ci, art().projectile_fx(s.spec.id), at, dir, went, tick)
		WeaponSpec.Kind.BOLT:
			var len_m: float = maxf(s.spec.tracer_len_m, ARC_MIN_M)
			var span: float = len_m * Ink.PX_PER_M / (ARC_SPAN_PX * cell_scale())
			WeaponFxElectro.ink_under(ci, tick % 3, at - dir * len_m, dir.angle(), span)
			_cell_v(ci, &"arc", tick % 3, at - dir * len_m, dir.angle(), Vector2(span, 1.0), 1.0)
			_cell(ci, &"spark", tick % 3, at, float(tick) * 0.5, 1.1, 1.0)
		WeaponSpec.Kind.THROWN when WeaponFxShell.SHELLS.has(art().projectile_fx(s.spec.id)):
			WeaponFxShell.draw_round(ci, s, dir, went, tick)
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
	var aim: Vector2 = (gun.last_aim if gun.last_aim != Vector2.ZERO else r.facing).normalized()
	var reach: float = r.radius_m + FLASH_AHEAD_M + art().muzzle_m(spec.id).x * 0.5
	var at: Vector2 = HeldMuzzle.at_m(ci, r.pos + aim * reach + aim.orthogonal() * GUN_SIDE_M)
	# the flame cell is the jet's full tongue: at the nozzle only a small lick
	var k: float = NOZZLE_K if fx == &"flame" else WeaponFxIgnite.muzzle_k(spec.id)
	k = WeaponFxIgnite.lick_k(spec.id, tick - age, tick, k)  # the flamer flares as it lights
	_cell(ci, fx, age, at, aim.angle(), k, 1.0)
	return true


## A rocket blast `b` (x, y, radius m) `age` ticks old; false = not drawn (the caller's shapes).
## `areas` (optional) tells a bottle's fire burst from a rocket's blast by its patch.
static func blast(ci: CanvasItem, b: Vector3, age: int, areas: FightAreas = null) -> bool:
	if not enabled:
		return false
	if fire_burst and is_fire_burst(b, areas):
		if age < FIRE_BURST_TICKS:
			var k: float = 2.0 * b.z * Ink.PX_PER_M / 480.0 / cell_scale()
			var fade: float = clampf(
				float(FIRE_BURST_TICKS - age) / (FIRE_BURST_TICKS * 0.5), 0.0, 1.0
			)
			_cell(ci, &"blast", 0, Vector2(b.x, b.y), b.y * 0.9, k, fade)
		WeaponFxShell.glass(ci, b, age)
		return true
	_blast_cells(ci, b, age)
	if b.z < FightNukeArt.NUKE_M:
		WeaponFxDebris.draw(ci, b, age)  # n5-look (r2_w4): slabs flung over the fireball
	return true


## The rocket blast's cells over its scorch decal (the burst, fireball, smoke ring).
static func _blast_cells(ci: CanvasItem, b: Vector3, age: int) -> void:
	var at: Vector2 = Vector2(b.x, b.y)
	# the scorch decal stays under it for the whole VFX life, fading out
	var keep: float = float(FightAreas.VFX_KEEP_TICKS)
	var s_scale: float = 2.0 * b.z * Ink.PX_PER_M / 400.0 / cell_scale()
	_cell(ci, &"scorch", 0, at, b.x * 1.7, s_scale, clampf(1.0 - float(age) / keep, 0.0, 0.85))
	var f: int = BLAST_FRAMES.size() - 2
	while f > 0 and age < BLAST_FRAMES[f]:
		f -= 1
	if not blast_beads and WeaponFxShell.wisps(ci, b, age):
		return
	if age >= BLAST_FRAMES[-1]:
		return
	var into: float = float(age - BLAST_FRAMES[f]) / float(BLAST_FRAMES[f + 1] - BLAST_FRAMES[f])
	var fade: float = 1.0 - into * 0.6 if f == 3 else 1.0
	# frame sizes grow 300 -> 480 part px; the last frame spans the splash diameter
	var size_k: float = 2.0 * b.z * Ink.PX_PER_M / 480.0 / cell_scale()
	var grow: float = 1.0 + 0.08 * into
	if f == 3 and not blast_beads:
		f = 2
		grow = 1.08 + 0.22 * into
		fade = 1.0 - into * 0.85
	_cell(ci, &"blast", f, at, b.y * 0.9, size_k * grow, fade)


## A splash whose own fire patch lies under it (same radius, within it): a burst bottle.
static func is_fire_burst(b: Vector3, areas: FightAreas) -> bool:
	if areas == null:
		return false
	for p: Vector4 in areas.patches:
		if is_equal_approx(p.z, b.z) and Vector2(p.x, p.y).distance_to(Vector2(b.x, b.y)) < b.z:
			return true
	return false


## The flamethrower stream: tongues along the jet, growing and fading with range. The cell is the
## weapon's projectile_fx (flame_cone: r2_w4's ragged cone, n5-look; flame = the teardrops).
static func _jet(ci: CanvasItem, s: Shot, dir: Vector2, went: float, tick: int) -> void:
	var fx: StringName = art().projectile_fx(s.spec.id)
	fx = &"flame" if fx == &"" else fx
	var k: float = clampf(went / maxf(s.spec.range_m, 0.1), 0.0, 1.0)
	var f: int = (tick / 3 + int(went * 4.0)) % 3
	var cone: bool = fx != &"flame"
	var swing: float = CONE_LICK if cone else 0.18
	var lick: float = dir.angle() + sin(float(tick) * 0.7 + went * 3.0) * swing
	# long and thin at the nozzle, fanning out with distance (round puffs near it read as drops)
	var grow: Vector2 = Vector2(1.15 + 0.6 * k, 0.32 + 1.5 * k)
	if cone and int(went * 4.0) % 2 == 1:
		grow.y = -grow.y  # every other cone slice mirrored: their jags never line up as planks
	# a second tongue halfway back to the previous puff closes the gap: one gushing jet
	var gap: float = s.spec.speed_mps * float(s.spec.interval_ticks) / 120.0
	if went > gap + CLEAR_M:
		var back: Vector2 = Vector2(_jet_x(fx, went - gap, grow.x * 0.85), grow.y * 0.85)
		_cell_v(ci, fx, f + 1, s.pos - dir * gap, -lick + 2.0 * dir.angle(), back, 1.0)
	grow.x = _jet_x(fx, went, grow.x)
	_cell_v(ci, fx, f, s.pos, lick, grow, 1.0 - 0.35 * k)
	WeaponFxEmber.draw(ci, s, dir, went, tick)


## The long cone cells' x scale, capped so the tail `went` m out never reaches back over the gun
## (the flame teardrops keep theirs: the before).
static func _jet_x(fx: StringName, went: float, x: float) -> float:
	if fx == &"flame":
		return x
	var tail_m: float = art().fx_anchor(StringName("%s_0" % fx)).x * cell_scale() / Ink.PX_PER_M
	return minf(x, maxf(went, 0.2) / maxf(tail_m, 0.01))


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
	var arc: float = 4.0 * f * (1.0 - f)
	var lift: float = FightAreasArt.LOB_M * arc
	var shade: float = BOTTLE_SHADOW_K * (1.0 - WeaponFxShell.SHADOW_SHRINK * arc)
	WeaponFxShell.shadow(ci, s.pos, shade, BOTTLE_SHADOW_INK)
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
	ci: CanvasItem,
	id: StringName,
	frame: int,
	at: Vector2,
	angle: float,
	scale: Vector2,
	a: float = 1.0,
) -> void:
	_cell_v(ci, id, frame, at, angle, scale, a)


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
	var tex: Texture2D = frames[frame % frames.size()]
	if colour != null:
		var xf: Transform2D = Transform2D(angle, scale * cell_scale(), 0.0, Ink.px(at))
		colour.cell(tex, xf, art().fx_anchor(key), a)
		return
	ci.draw_set_transform(Ink.px(at), angle, scale * cell_scale())
	ci.draw_texture(tex, -art().fx_anchor(key), Color(1, 1, 1, a))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
