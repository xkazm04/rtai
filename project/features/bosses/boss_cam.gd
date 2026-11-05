class_name BossCam
extends Node
## Dev `--boss-cam` (clips): the arena camera frames Rivet and the boss together, sitting
## FRAME_K of the way from Rivet to the boss, so a filmed attack keeps both on screen. View
## only (SIM-03): it sets CollectCallView.focus, never the sim; without the flag the camera
## follows Rivet. The centre is clamped so the screen stays on the fight's floor
## (BossHook.bounds, the arena record's area): no off-area ground at the boulevard's edge. The
## floor's top edge clears the boss bar: the clamp lets the screen rise HUD_PX (the bar's band,
## in screen pixels) above the floor, so a boss at the top edge (Servo's bays) is never under it.

const FLAG: String = "--boss-cam"
const FRAME_K: float = 0.45
## Farther apart than this (a respawn, the procession's far end) it follows Rivet alone.
const FAR_M: float = 20.0
## The boss bar's band at the top of the screen (BossBar.TOP + BAR_H + its title), screen px.
const HUD_PX: float = BossBar.TOP + BossBar.BAR_H + 10.0

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


func _process(_delta: float) -> void:
	if view == null or hook == null or hook.fight == null:
		return
	var r: Vector2 = hook.rivet_pos()
	var b: Vector2 = hook.fight.body.pos
	var at: Vector2 = r if r.distance_to(b) > FAR_M else r.lerp(b, FRAME_K)
	var half: Vector2 = _half_m()
	var hud_m: float = HUD_PX * half.y / maxf(view.get_viewport_rect().size.y * 0.5, 1.0)
	view.focus = clamp_focus(at, half, hook.bounds.grow_side(SIDE_TOP, hud_m))


## Half the screen in metres at the view's zoom now.
func _half_m() -> Vector2:
	var ppm: float = view.px_per_m
	if view.print_stage != null:
		ppm = view.print_stage.zoom * SimConst.PX_PER_M
	return view.get_viewport_rect().size * 0.5 / maxf(ppm, 1.0)
