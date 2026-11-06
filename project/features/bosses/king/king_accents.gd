class_name KingAccents
extends Node2D
## The wealth drawn over the rigs at game zoom (render only): at 32 px/m the rig prints flat
## stickers, so the gold in the part art is lost. King's jewelled gold crown sits over his head
## (on the throne and on foot); every gang bot, riding the car or brawling, wears a gold chain
## across its chest.
## Drawn after KingRigs (a later sibling), in the cast's px like KingBodyView.

const GOLD: Color = Color("#D9A933")
const GOLD_HI: Color = Color("#F6D678")
## King's head sits this far forward of the body centre on the rig (metres, at KingRigs' size).
const HEAD_FWD_M: float = 0.12
## Over every rig part (CutRig parts sit at their own z_index under the rig).
const OVER_RIG_Z: int = 40
## The jewelled crown's radius (m): the target's 90-degree panel reads King by it first.
const CROWN_M: float = 0.42
## The ermine collar round his shoulders (the target's white fur ring with black tails), m.
const ERMINE_R_M: float = 0.5
const ERMINE_W_M: float = 0.16
const FUR: Color = Color("#EFE6D2")
## The decree's windup arc (it10, see _shout); false = the it2-it9 faint pulses.
const SHOUT_ARC: bool = true
const SHOUT_ARC_M: float = 1.15
## The slam tell's raised plates either side of the crown (it10, see _raised_plates).
const RAISED_PLATES: bool = true
const PLATE_OUT_M: float = 0.62
## The gang's gold chain (it14): a rope this wide (m) round the chest at CHAIN_R_M, links and a
## medallion at the front, on the car's riders too. CHAIN_W_M 0 = the it2-it13 3 px arc on the
## brawlers only (a 2 px line at 32 px/m, lost under the buff ring).
const CHAIN_W_M: float = 0.11
const CHAIN_R_M: float = 0.3
const MEDAL_M: float = 0.075

var view: KingBodyView = null
var rigs: KingRigs = null
var _down_at: int = -1


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if view == null or view.fight == null:
		return
	var f: BossFight = view.fight
	var at: Vector2 = KingBeats.king_px(f, view.windup_px())
	at += f.body.facing * HEAD_FWD_M * Ink.PX_PER_M
	if f.state != BossFight.State.DEFEATED:
		_down_at = -1
		_ermine(at, f.body.facing)
		_crown(at, CROWN_M * Ink.PX_PER_M, 0.0)
		_raised_plates(f, at)
	else:  # the defeat beat: the crown falls off his head and rolls away
		_down_at = f.now() if _down_at < 0 else _down_at
		var fall: Vector3 = KingBeats.crown_fall(f, _down_at)
		_crown(at + Vector2(fall.x, fall.y), CROWN_M * Ink.PX_PER_M, fall.z)
	_shout(f, at)
	var buffed: bool = view.adds != null and view.adds.buffed(f.now())
	for g: BossFight in view.standing_adds():
		var c: Vector2 = Ink.px(g.body.pos)
		if buffed:  # the decree's buff: a danger ring on every gang bot until it ends
			draw_arc(c, 0.52 * Ink.PX_PER_M, 0.0, TAU, 20, Ink.VERMILION, 2.5)
		_chain(c, g.body.facing.angle())
	if CHAIN_W_M > 0.0 and rigs != null:
		for mark: Vector3 in rigs.rider_marks():
			_chain(Vector2(mark.x, mark.y), mark.z)


## A gang bot's gold chain round the front of its chest, facing angle `a`.
func _chain(c: Vector2, a: float) -> void:
	var r: float = CHAIN_R_M * Ink.PX_PER_M
	if CHAIN_W_M <= 0.0:
		draw_arc(c, r, a - 1.0, a + 1.0, 10, Ink.INK, 5.0)
		draw_arc(c, r, a - 0.95, a + 0.95, 10, GOLD, 3.0)
		return
	var w: float = CHAIN_W_M * Ink.PX_PER_M
	draw_arc(c, r, a - 1.05, a + 1.05, 12, Ink.INK, w + 3.0)
	draw_arc(c, r, a - 1.0, a + 1.0, 12, GOLD, w)
	for i: int in 5:  # the links catch the light
		draw_circle(c + Vector2.from_angle(a - 0.8 + 0.4 * float(i)) * r, w * 0.22, GOLD_HI)
	var medal: Vector2 = c + Vector2.from_angle(a) * (r + w * 0.6)
	draw_circle(medal, MEDAL_M * Ink.PX_PER_M + 1.5, Ink.INK)
	draw_circle(medal, MEDAL_M * Ink.PX_PER_M, GOLD_HI)


## The decree's tell (it10): an ink-backed vermilion windup arc fills round King over the tell
## (the enemy-ai windup-arc rule), then the shout bursts in full rings. The it2-it9 tell was
## half-alpha 3 px pulses, a faint ring at 48 px/m (SHOUT_ARC = false brings it back).
func _shout(f: BossFight, at: Vector2) -> void:
	if f.attack == null or f.attack.buff_ticks <= 0:
		return
	if f.state != BossFight.State.WINDUP and f.state != BossFight.State.ACTIVE:
		return
	var loud: float = 1.0 if f.state == BossFight.State.ACTIVE else 0.5
	if SHOUT_ARC and f.state == BossFight.State.WINDUP:
		var p: float = 1.0 - float(f.tell_left()) / float(maxi(f.attack.windup, 1))
		var r0: float = SHOUT_ARC_M * Ink.PX_PER_M
		draw_arc(at, r0, 0.0, TAU, 40, Color(Ink.VERMILION, 0.25), 4.0)
		draw_arc(at, r0, -PI / 2.0, -PI / 2.0 + TAU * p, 40, Ink.INK, 9.0)
		draw_arc(at, r0, -PI / 2.0, -PI / 2.0 + TAU * p, 40, Ink.VERMILION, 5.0)
		loud = 0.8
	var w: float = 6.0 if SHOUT_ARC and f.state == BossFight.State.ACTIVE else 3.0
	for i: int in 3:
		var k: float = fposmod(float(f.now()) / 30.0 + float(i) / 3.0, 1.0)
		var r: float = (0.7 + 2.6 * k * loud) * Ink.PX_PER_M
		draw_arc(at, r, 0.0, TAU, 32, Color(Ink.VERMILION, (1.0 - k) * loud), w)


## The slam's tell (it10): the rig lifts both plates over the head, under the crown from straight
## above, so two gold plates are drawn either side of the crown, growing as they rise (render only;
## RAISED_PLATES false = the it8 read, plates hidden).
func _raised_plates(f: BossFight, at: Vector2) -> void:
	if not RAISED_PLATES or f.state != BossFight.State.WINDUP or f.attack == null:
		return
	if not KingRigs.RAISE_IN_TELL.has(f.attack.id):
		return
	var p: float = 1.0 - float(f.tell_left()) / float(maxi(f.attack.windup, 1))
	var side: Vector2 = f.body.facing.orthogonal() * PLATE_OUT_M * Ink.PX_PER_M
	var half: Vector2 = Vector2(0.17, 0.21) * Ink.PX_PER_M * (0.8 + 0.45 * p)
	for s: float in [-1.0, 1.0]:
		var c: Vector2 = at + side * s
		draw_rect(Rect2(c - half - Vector2(3, 3), half * 2.0 + Vector2(6, 6)), Ink.INK)
		draw_rect(Rect2(c - half, half * 2.0), GOLD)
		draw_rect(Rect2(c - half * 0.6, half * 0.7), GOLD_HI)


## The ermine collar: a cream fur ring open at the front, with ink tail spots.
func _ermine(at: Vector2, facing: Vector2) -> void:
	var r: float = ERMINE_R_M * Ink.PX_PER_M
	var w: float = ERMINE_W_M * Ink.PX_PER_M
	var a: float = facing.angle()
	draw_arc(at, r, a + 0.7, a + TAU - 0.7, 24, Ink.INK, w + 3.0)
	draw_arc(at, r, a + 0.75, a + TAU - 0.75, 24, FUR, w)
	for i: int in 7:
		draw_circle(at + Vector2.from_angle(a + 1.0 + float(i) * 0.71) * r, w * 0.18, Ink.INK)


## A gold star crown with an ink edge and a dark jewel (vermilion stays the cape's alone).
func _crown(at: Vector2, r: float, spin: float) -> void:
	var pts: Array[Vector2] = []
	for i: int in 10:
		var rr: float = r if i % 2 == 0 else r * 0.6
		pts.append(at + Vector2.from_angle(TAU * float(i) / 10.0 + spin) * rr)
	var poly: PackedVector2Array = PackedVector2Array(pts)
	draw_colored_polygon(poly, GOLD)
	draw_polyline(poly + PackedVector2Array([pts[0]]), Ink.INK, 2.0)
	draw_circle(at, r * 0.32, Ink.INK)
	draw_circle(at + Vector2(-r * 0.08, -r * 0.08), r * 0.12, GOLD_HI)
