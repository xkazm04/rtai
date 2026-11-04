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
## The exhaust lick sits this far behind the head (m, x the shell's size).
const TAIL_M: float = 1.15


## Draws shot `s` flying along `dir`, `went` metres from the muzzle.
static func draw_round(ci: CanvasItem, s: Shot, dir: Vector2, went: float, tick: int) -> void:
	var f: float = clampf(went / maxf(went + s.left_m, 0.1), 0.0, 1.0)
	var arc: float = 4.0 * f * (1.0 - f)
	var lift: float = FightAreasArt.LOB_M * arc
	var base: float = WeaponFxArt.art().round_k.get(s.spec.id, 1.0)
	var size: float = base * (1.0 + APEX_GROW * arc)
	var shadow: Rect2 = Rect2(Ink.px(s.pos) - Vector2(18.0, 7.0), Vector2(36.0, 14.0))
	ci.draw_rect(shadow.grow(-1.5 * lift), FightAreasArt.SCORCH)
	var up: Vector2 = s.pos + Vector2(0.0, -lift)
	var ang: float = dir.angle()
	var lick: Vector2 = Vector2.ONE * (0.42 + 0.08 * float(tick % 2)) * size
	WeaponFxArt.draw_cell(ci, &"flame", tick % 3, up - dir * TAIL_M * size, ang, lick)
	WeaponFxArt.draw_cell(ci, &"rocket", 0, up, ang, Vector2.ONE * size)
