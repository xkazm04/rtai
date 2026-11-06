class_name KingShock
extends RefCounted
## The press slam's impact (render only, no RNG): from the active window into the first
## TAIL_S of the recovery, an ink-and-gold shockwave ring runs out to the attack's radius (the
## hit zone the tell drew) and a shower of coins bursts from the plates, flies out and settles.

const TAIL_S: float = 0.55
const COINS: int = 22
const GOLD: Color = Color("#D9A933")
const GOLD_HI: Color = Color("#F6D678")


static func draw(ci: CanvasItem, fight: BossFight) -> void:
	var a: BossAttack = fight.attack
	if a == null or a.shape != BossAttack.Shape.CIRCLE:
		return
	var ticks: int = -1
	if fight.state == BossFight.State.ACTIVE:
		ticks = fight.t
	elif fight.state == BossFight.State.RECOVER:
		ticks = a.active + fight.t
	var span: float = float(a.active) + TAIL_S / SimClock.TICK_DT
	if ticks < 0 or float(ticks) > span:
		return
	var k: float = float(ticks) / span
	var at: Vector2 = Ink.px(fight.origin)
	var r: float = a.radius_m * Ink.PX_PER_M * (0.35 + 0.65 * sqrt(k))
	var fade: float = 1.0 - k
	ci.draw_arc(at, r, 0.0, TAU, 48, Color(Ink.INK, fade), 7.0 * fade + 2.0)
	ci.draw_arc(at, r - 3.0, 0.0, TAU, 48, Color(GOLD_HI, fade), 3.0 * fade + 1.0)
	for i: int in COINS:
		var ang: float = TAU * fposmod(float(i) * 0.618034, 1.0)
		var far: float = (0.5 + 0.7 * fposmod(float(i) * 0.381966, 1.0)) * a.radius_m
		var out: float = far * (1.0 - pow(1.0 - minf(k * 1.6, 1.0), 2.0))
		var c: Vector2 = at + Vector2.from_angle(ang) * out * Ink.PX_PER_M
		ci.draw_circle(c, 5.0, Ink.INK)
		ci.draw_circle(c, 3.8, GOLD)
