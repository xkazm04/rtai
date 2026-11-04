class_name WeaponCasings
extends RefCounted
## weapon-art: spent brass from Rivet's pistol-class guns in the live fight (render only).
## Each new round (GunHand.shots_fired went up) throws the weapon's `casing` cell out to the right
## of the aim: it flips through the air for FLY_TICKS, lands, and lies on the floor until it
## fades. Positions and spin come from the round's count, never from an RNG, so a replayed fight
## drops the same brass. View state only (a tick that runs backwards clears it).

const FLY_TICKS: int = 14
const LIE_TICKS: int = 360
const FADE_TICKS: int = 60
const MAX_LYING: int = 24
## Out to the side of the aim (m) and a little back, plus a per-round spread.
const THROW_M: float = 1.0
const SCALE: float = 0.75  # it-5: 1.3 drew a 0.4 m casing (a brick beside the magazine)

static var _at: Array[Vector2] = []
static var _to: Array[Vector2] = []
static var _born: Array[int] = []
static var _seen: int = 0
static var _last_tick: int = -1


## Notes a new round from `gun` held by `r` at `tick` (call once per drawn frame).
static func track(r: Fighter, gun: GunHand, tick: int, cell: StringName) -> void:
	if tick < _last_tick or gun.shots_fired < _seen:
		clear()
	_last_tick = tick
	if gun.shots_fired == _seen:
		return
	_seen = gun.shots_fired
	if cell == &"":
		return
	var aim: Vector2 = r.facing.normalized()
	var side: Vector2 = aim.orthogonal()  # the gun claw's side: brass flies away from the body
	var k: float = float(_seen % 7) / 6.0
	var from: Vector2 = r.pos + aim * (r.radius_m + 0.2) + side * WeaponFxArt.GUN_SIDE_M
	var to: Vector2 = from + side * THROW_M * (0.7 + 0.5 * k) - aim * (0.15 + 0.3 * (1.0 - k))
	_at.append(from)
	_to.append(to)
	_born.append(tick)
	while _born.size() > MAX_LYING:
		_at.remove_at(0)
		_to.remove_at(0)
		_born.remove_at(0)


## Draws every casing in flight or on the floor (`cell` from WeaponArt.casing_fx).
static func draw(ci: CanvasItem, tick: int, cell: StringName) -> void:
	# A gun without brass (cell "") still draws the brass an earlier gun left on the floor.
	var frames: Array[Texture2D] = WeaponFxArt.art().fx_frames(cell if cell != &"" else &"casing")
	if frames.is_empty():
		frames = WeaponFxArt.art().fx_frames(&"casing")
	var tex: Texture2D = frames[0]
	var k: float = WeaponFxArt.cell_scale() * SCALE
	for i: int in _born.size():
		var age: int = tick - _born[i]
		if age > LIE_TICKS + FADE_TICKS:
			continue
		var f: float = clampf(float(age) / float(FLY_TICKS), 0.0, 1.0)
		var hop: float = 0.35 * 4.0 * f * (1.0 - f)  # up the screen while it flies
		var pos: Vector2 = _at[i].lerp(_to[i], f) + Vector2(0.0, -hop)
		var spin: float = float(mini(age, FLY_TICKS)) * 0.9 + float(i) * 1.3
		var fade: float = clampf(float(LIE_TICKS + FADE_TICKS - age) / float(FADE_TICKS), 0.0, 1.0)
		ci.draw_set_transform(Ink.px(pos), spin, Vector2.ONE * k)
		ci.draw_texture(tex, -tex.get_size() * 0.5, Color(1, 1, 1, fade))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func clear() -> void:
	_at.clear()
	_to.clear()
	_born.clear()
	_seen = 0
	_last_tick = -1


static func count() -> int:
	return _born.size()
