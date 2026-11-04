class_name WeaponFxShell
extends RefCounted
## weapon-art's lobbed shell: a THROWN weapon whose projectile_fx is `rocket` (the mini-nuke) flies
## as the rocket cell on the molotov's lob arc (lifted off its ground shadow by FightAreasArt.LOB_M
## at the apex), nose along the travel, swelling toward the apex so the arc reads from above, with
## the exhaust lick behind it. Until iteration 9 every THROWN row drew the molotov bottle, so the
## mini-nuke's shell flew as a burning bottle. projectile_k (WeaponArt.round_k) sets its size.
## Render only: reads the shot.

## How much bigger the shell draws at the apex than at the ends of the arc.
const APEX_GROW: float = 0.35
## The ground shadow: an ink ellipse SHADOW_M long (x the shell's size), shrinking at the apex.
const SHADOW_M: Vector2 = Vector2(0.62, 0.26)
const SHADOW_SHRINK: float = 0.4
## The exhaust lick sits this far behind the head (m, x the shell's size).
const TAIL_M: float = 1.15
## A fire patch's ground: the scorch cell (an inked burst, 400 cell px) spanning this many patch
## diameters at this ink, in place of gunplay's flat grey disc. 0 = the disc (the before).
const PATCH_SCORCH_K: float = 1.0
const PATCH_SCORCH_INK: float = 0.8


## Draws shot `s` flying along `dir`, `went` metres from the muzzle.
static func draw_round(ci: CanvasItem, s: Shot, dir: Vector2, went: float, tick: int) -> void:
	var f: float = clampf(went / maxf(went + s.left_m, 0.1), 0.0, 1.0)
	var arc: float = 4.0 * f * (1.0 - f)
	var lift: float = FightAreasArt.LOB_M * arc
	var base: float = WeaponFxArt.art().round_k.get(s.spec.id, 1.0)
	var size: float = base * (1.0 + APEX_GROW * arc)
	shadow(ci, s.pos, base * (1.0 - SHADOW_SHRINK * arc))
	var up: Vector2 = s.pos + Vector2(0.0, -lift)
	var ang: float = dir.angle()
	var lick: Vector2 = Vector2.ONE * (0.42 + 0.08 * float(tick % 2)) * size
	WeaponFxArt.draw_cell(ci, &"flame", tick % 3, up - dir * TAIL_M * size, ang, lick)
	WeaponFxArt.draw_cell(ci, &"rocket", 0, up, ang, Vector2.ONE * size)


## The ink ellipse a lobbed round casts on `at` (m), SHADOW_M x `k` (the molotov uses it too).
## `ink` is its opacity (the shell's own is the scorch's 0.35; a small bottle needs a darker one).
static func shadow(ci: CanvasItem, at: Vector2, k: float, ink: float = 0.35) -> void:
	var r: Vector2 = SHADOW_M * Ink.PX_PER_M * k
	ci.draw_set_transform(Ink.px(at), 0.0, Vector2(1.0, r.y / r.x))
	ci.draw_circle(Vector2.ZERO, r.x, Color(FightAreasArt.SCORCH, ink))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## The burnt ground under fire patch `p` (x, y, radius m) at `fade` (1 burning .. 0 out); false =
## not drawn (the caller's disc). Its turn is fixed by its place, so it never spins.
static func patch_ground(ci: CanvasItem, p: Vector4, fade: float) -> bool:
	if not WeaponFxArt.enabled or PATCH_SCORCH_K <= 0.0:
		return false
	var k: float = 2.0 * p.z * PATCH_SCORCH_K * Ink.PX_PER_M / 400.0 / WeaponFxArt.cell_scale()
	var a: float = PATCH_SCORCH_INK * (0.5 + 0.5 * fade)
	WeaponFxArt.draw_cell(ci, &"scorch", 0, Vector2(p.x, p.y), p.x * 1.7 + p.y, Vector2.ONE * k, a)
	return true
