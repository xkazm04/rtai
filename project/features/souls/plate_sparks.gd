class_name PlateSparks
extends RefCounted
## n7-melee: Tonnage's plates made to read (the 48 px/m audit, 2026-11-05 22:27: the cops' rounds
## drew on through the press body with no mark, so the armour read as rounds passing through him).
## While the form is on, an enemy round's tracer stops at the plate edge (plate_r_m from Rivet's
## spot) and on the first contact a small cream glance spark edged in ink prints there, with a
## short streak off along the round's bounce from the plate. At most plate_sparks_per_tick new
## sparks a tick (a Gatling cop must not blur the press; a capped round still stops at the edge).
## FxView asks `edge()` per round and draws `draw()` on the print layer. Data: ghost_attacks.json
## tonnage plate_r_m, plate_spark_ticks (0 = none), plate_sparks_per_tick; --feel=off = none (the
## rounds draw through as before). View only: never read by the sim, no RNG (turns from the tick).
## Only once the press is drawn (Tonnage settled, or the transformation into it PRESS_K through,
## and the tank grown in: morph_k >= MORPH_MIN): the city film printed the first sparks round the
## teal morph disc before the press was drawn.

const INK: Color = SlamDebris.INK
const CREAM: Color = SlamDebris.CREAM
const VERMILION: Color = Ink.VERMILION
const KEEP: int = 12
const RAYS: int = 5
const SPARK_M: float = 0.32
const GLANCE_M: float = 0.7
const TRACER_PX: float = 9.0
const CORE_PX: float = 4.0
## FxView's plain enemy dash (no table gun): its tail behind the head.
const DASH_M: float = 0.25
## The tank's grow (HaulerForm.morph_k) from which the plates stop rounds: the press is drawn.
const MORPH_MIN: float = 0.95
## How far through the transformation into Tonnage the press is drawn (GhostForms.k).
const PRESS_K: float = 0.8

var hauler: HaulerStage
## The ghost forms' pilot (null: the morph gate alone): no plates until Tonnage has settled in.
var pilot: GhostPilot = null
var enabled: bool = true
var r_m: float = 1.2
var spark_ticks: int = 6
var per_tick: int = 2
## (x, y, glance angle, tick) per spark, oldest first.
var marks: Array[Vector4] = []
var _stopped: Dictionary[Shot, bool] = {}
var _count_tick: int = -1
var _count: int = 0


static func make(p_hauler: HaulerStage, attacks: GhostAttacks = null) -> PlateSparks:
	var g: GhostAttacks = attacks if attacks != null else GhostAttacks.shipped()
	var p: PlateSparks = PlateSparks.new()
	p.hauler = p_hauler
	p.r_m = g.num(&"tonnage", &"plate_r_m")
	p.spark_ticks = int(g.num(&"tonnage", &"plate_spark_ticks"))
	p.per_tick = int(g.num(&"tonnage", &"plate_sparks_per_tick"))
	p.enabled = HitFeel.feel_flag() != "off" and p.spark_ticks > 0 and p.r_m > 0.0
	return p


## Where round `s` (its drawn tail `tail_m` behind the head) meets the plates around `c`, or
## Vector2.INF when the plates do not stop it (off, Rivet's own round, the form off, not reached).
## The first contact prints a spark (within the per-tick cap) at stage tick `tick`.
func edge(s: Shot, c: Vector2, tail_m: float, tick: int) -> Vector2:
	if not enabled or s.from_rivet or hauler == null or not hauler.form.on:
		return Vector2.INF
	if not _stopped.has(s) and not _plated():
		return Vector2.INF  # still morphing in: no press drawn yet, so no plates to stop it
	var dir: Vector2 = s.vel.normalized()
	var tail: Vector2 = s.pos - dir * tail_m
	var t: float = PlateSparks.enter(tail, dir, c, r_m)
	if _stopped.has(s):  # stays stopped: past the plates (a miss through the form) draws nothing
		return tail + dir * t if t <= tail_m else tail
	if t > tail_m:
		return Vector2.INF
	var at: Vector2 = tail + dir * t
	_stopped[s] = true
	_spark(at, dir, c, tick)
	return at


func _plated() -> bool:
	if pilot != null and not pilot.settled_in(&"tonnage"):
		var f: GhostForms = pilot.forms
		if f.to_id != &"tonnage" or f.phase == GhostForms.EXITING or f.k() < PRESS_K:
			return false
	return hauler.form.morph_k() >= MORPH_MIN


## The distance along `dir` from `p` to where it enters the circle (`c`, `r`); 0 when `p` is
## inside, INF when the line misses or the circle is behind.
static func enter(p: Vector2, dir: Vector2, c: Vector2, r: float) -> float:
	var f: Vector2 = p - c
	var cc: float = f.dot(f) - r * r
	if cc <= 0.0:
		return 0.0
	var b: float = f.dot(dir)
	var disc: float = b * b - cc
	if b >= 0.0 or disc < 0.0:
		return INF
	return -b - sqrt(disc)


## Forget rounds that are gone (call once a frame with the arena's live rounds).
func prune(shots: Array[Shot]) -> void:
	for s: Shot in _stopped.keys():
		if not shots.has(s):
			@warning_ignore("return_value_discarded")
			_stopped.erase(s)


## The stopped round's visible part: tail to the plate edge `at`, in the style FxView draws it
## with (`inked`: a table gun's ink tracer with a vermilion core; else the plain vermilion dash);
## nothing once the tail is inside.
static func tracer(ci: CanvasItem, s: Shot, at: Vector2, tail_m: float, inked: bool) -> void:
	var tail: Vector2 = s.pos - s.vel.normalized() * tail_m
	if tail.distance_to(at) < 0.02:
		return
	if not inked:
		ci.draw_line(Ink.px(tail), Ink.px(at), VERMILION, CORE_PX)
		return
	ci.draw_line(Ink.px(tail), Ink.px(at), INK, TRACER_PX)
	ci.draw_line(Ink.px(tail.lerp(at, 0.3)), Ink.px(at), VERMILION, CORE_PX)


func draw(ci: CanvasItem, tick: int) -> void:
	for m: Vector4 in marks:
		var age: int = tick - int(m.w)
		if age < 0 or age >= spark_ticks:
			continue
		var t: float = float(age) / float(spark_ticks)
		var at: Vector2 = Vector2(m.x, m.y)
		_glance(ci, at, Vector2.from_angle(m.z), t)
		_burst(ci, at, m.z + float(int(m.w) % 7) * 0.4, t)


func _spark(at: Vector2, dir: Vector2, c: Vector2, tick: int) -> void:
	if tick != _count_tick:
		_count_tick = tick
		_count = 0
	if _count >= per_tick:
		return
	_count += 1
	var n: Vector2 = (at - c).normalized() if at != c else -dir
	marks.append(Vector4(at.x, at.y, dir.bounce(n).angle(), tick))
	if marks.size() > KEEP:
		marks.remove_at(0)


## A small starburst, long and short spikes by turns, full on the contact frame, then shrinking.
func _burst(ci: CanvasItem, at: Vector2, turn: float, t: float) -> void:
	var r: float = SPARK_M * (1.0 - 0.5 * t)
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in RAYS * 2:
		var k: float = 1.0 if i % 2 == 0 else 0.4
		@warning_ignore("return_value_discarded")
		pts.push_back(Ink.px(at + Vector2.from_angle(turn + TAU * i / (RAYS * 2)) * r * k))
	var ring: PackedVector2Array = pts.duplicate()
	@warning_ignore("return_value_discarded")
	ring.push_back(pts[0])
	ci.draw_colored_polygon(pts, Color(CREAM, 1.0 - t * t))
	ci.draw_polyline(ring, Color(INK, 1.0 - t), 2.0, true)


## The bounce: a short cream line edged in ink leaving the plate, its tail catching up.
func _glance(ci: CanvasItem, at: Vector2, off: Vector2, t: float) -> void:
	var head: Vector2 = at + off * GLANCE_M * minf(1.0, t * 2.5 + 0.3)
	var tail: Vector2 = at + off * GLANCE_M * t
	var a: float = 1.0 - t * t
	ci.draw_line(Ink.px(tail), Ink.px(head), Color(INK, a), 5.0, true)
	ci.draw_line(Ink.px(tail), Ink.px(head), Color(CREAM, a), 2.0, true)
