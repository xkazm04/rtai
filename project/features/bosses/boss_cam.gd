class_name BossCam
extends Node
## Dev `--boss-cam` (clips): the arena camera frames Rivet and the boss together, sitting
## FRAME_K of the way from Rivet to the boss, so a filmed attack keeps both on screen. View
## only (SIM-03): it sets CollectCallView.focus, never the sim; without the flag the camera
## follows Rivet. The centre is clamped so the screen stays on the fight's floor
## (BossHook.bounds, the arena record's area): no off-area ground at the boulevard's edge. The
## floor's top edge clears the boss bar: the clamp lets the screen rise HUD_PX (the bar's band,
## in screen pixels) above the floor, so a boss at the top edge (Servo's bays) is never under it.
## The boss wins over the floor: after the clamp the view shifts so the boss and BOSS_MARGIN_M
## round it stay on screen between the bar and the ghost card at the bottom (keep_in): a boss on
## the floor's bottom edge (Servo at the conveyor) shows a strip of off-floor ground rather than
## standing under the ghost card or off the screen.

const FLAG: String = "--boss-cam"
const FRAME_K: float = 0.45
## Farther apart than this (a respawn, the procession's far end) it follows Rivet alone.
const FAR_M: float = 20.0
## The boss bar's band at the top of the screen (BossBar.TOP + BAR_H + its title), screen px.
const HUD_PX: float = BossBar.TOP + BossBar.BAR_H + 10.0

## Metres kept on screen round the boss's centre (Servo's rack is 5.4 m across).
const BOSS_MARGIN_M: float = 3.0
## Sideways the screen is wider, so more is kept: a boss turned side-on (Servo's rack with its
## spine gap reaches 3.1 m from his centre, his defeat spill more) stays whole at the floor's
## side edge. 3.0 = the same margin on both axes (it11).
const BOSS_MARGIN_X_M: float = 5.5
## The ghost card's band at the bottom of the screen (GhostFormHud: MARGIN + its 158 px card +
## the rim), screen px; kept clear of the boss across the whole width.
const FOOT_PX: float = GhostFormHud.MARGIN + 162.0

var view: CollectCallView = null
var hook: BossHook = null


static func wanted() -> bool:
	return OS.get_cmdline_user_args().has(FLAG)


## `focus` moved so a view of `half_m` (half the screen, metres) stays inside `area`; on an
## axis where the view is wider than the area it sits on the area's centre.
static func clamp_focus(focus: Vector2, half_m: Vector2, area: Rect2) -> Vector2:
	if area.size.x <= 0.0 or area.size.y <= 0.0:
		return focus
	var lo: Vector2 = area.position + half_m
	var hi: Vector2 = area.end - half_m
	var c: Vector2 = area.get_center()
	var x: float = clampf(focus.x, lo.x, hi.x) if lo.x <= hi.x else c.x
	var y: float = clampf(focus.y, lo.y, hi.y) if lo.y <= hi.y else c.y
	return Vector2(x, y)


## `focus` moved the least so that `p` +- `margin_m` sits inside the view of `half_m` less its
## HUD bands (`band_m`: x the top, y the bottom, metres); an axis where the view cannot hold it
## is left as it was.
static func keep_in(
	focus: Vector2, half_m: Vector2, p: Vector2, margin_m: float, band_m: Vector2
) -> Vector2:
	var lo: Vector2 = Vector2(p.x + margin_m - half_m.x, p.y + margin_m - half_m.y + band_m.y)
	var hi: Vector2 = Vector2(p.x - margin_m + half_m.x, p.y - margin_m + half_m.y - band_m.x)
	var x: float = clampf(focus.x, lo.x, hi.x) if lo.x <= hi.x else focus.x
	var y: float = clampf(focus.y, lo.y, hi.y) if lo.y <= hi.y else focus.y
	return Vector2(x, y)


func _process(_delta: float) -> void:
	if view == null or hook == null or hook.fight == null:
		return
	var r: Vector2 = hook.rivet_pos()
	var b: Vector2 = hook.fight.body.pos
	var at: Vector2 = r if r.distance_to(b) > FAR_M else r.lerp(b, FRAME_K)
	var half: Vector2 = _half_m()
	var m_per_px: float = half.y / maxf(view.get_viewport_rect().size.y * 0.5, 1.0)
	var hud_m: float = HUD_PX * m_per_px
	var on_floor: Vector2 = clamp_focus(at, half, hook.bounds.grow_side(SIDE_TOP, hud_m))
	var bands: Vector2 = Vector2(hud_m, FOOT_PX * m_per_px)
	var held_x: Vector2 = keep_in(on_floor, half, b, BOSS_MARGIN_X_M, bands)
	view.focus = Vector2(held_x.x, keep_in(on_floor, half, b, BOSS_MARGIN_M, bands).y)


## Half the screen in metres at the view's zoom now.
func _half_m() -> Vector2:
	var ppm: float = view.px_per_m
	if view.print_stage != null:
		ppm = view.print_stage.zoom * SimConst.PX_PER_M
	return view.get_viewport_rect().size * 0.5 / maxf(ppm, 1.0)
