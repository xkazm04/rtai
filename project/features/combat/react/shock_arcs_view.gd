class_name ShockArcsView
extends Node2D
## The electro gun's marks on a stunned human, drawn above the rigs (the fight's fx layer sits
## under them, where arcs on the body were hidden): arcs crawling over the body (ShockJolt.arcs)
## centred on the rig's drawn torso so they ride its convulsion, and the pistol his fingers let go
## (the rig's hand cell drops the gun while he convulses): tossed out of the gun hand on the first
## stun tick, it lies beside him until the stun ends; an electro corpse keeps it, and it inks out
## and sinks with the body (CorpseDecay via ArenaRigs.decay), gone with it. Reads the
## arena's stun state on its tick; render only, no RNG.

## The toss: ticks in the air, how far it lands from the torso (m, ahead and to the gun side),
## its spin while flying (rad per tick) and the pistol's size (m).
const TOSS_TICKS: int = 8
const TOSS_AHEAD_M: float = 0.4
const TOSS_SIDE_M: float = 0.3
const TOSS_SPIN: float = 0.55
const GUN_LONG_M: float = 0.24
const GUN_WIDE_M: float = 0.06

var arena: CombatArena = null
var rigs: CharacterRigs = null
var host: ArenaRigs = null
## Fighter id -> [from px, to px, the stun's first tick, rest angle, px per metre].
var _drops: Dictionary[int, Array] = {}


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if arena == null or arena.areas == null or rigs == null:
		return
	var light: Dictionary[int, bool] = StunCrowd.light_of(arena)  # n7-melee: the crowd cap
	for h: Fighter in arena.hostiles:
		var rig: CutRig = rigs.rig_for(h.id)
		if rig == null or rig.torso == null:
			if h.alive() or not _drops.has(h.id):  # a cut corpse (the charged kill) keeps it
				@warning_ignore("return_value_discarded")
				_drops.erase(h.id)
			else:
				_gun(_drops[h.id], h.id)
			continue
		var e: FighterFx = arena.areas.effect(h)
		var stunned: bool = e != null and h.alive() and e.stun_ticks > 0
		var c: Vector2 = to_local(rig.torso.global_position)
		var ppm: float = Ink.PX_PER_M * rig.global_transform.get_scale().x / CutRig.SC
		if stunned:
			var cap: Vector4i = StunCrowd.cap()
			var n: Vector2i = Vector2i(cap.y, cap.z) if light.has(h.id) else Vector2i(9, 9)
			ShockJolt.arcs(self, c, ppm, arena.tick + h.id, n)
			if not _drops.has(h.id) and ShockJolt.hard:
				_drops[h.id] = _toss(c, ppm, rig.facing, h.id)
		elif h.alive():
			@warning_ignore("return_value_discarded")
			_drops.erase(h.id)
		if _drops.has(h.id):
			_gun(_drops[h.id], h.id)


func _toss(c: Vector2, ppm: float, facing: float, id: int) -> Array:
	var fwd: Vector2 = Vector2.from_angle(facing)
	var side: Vector2 = fwd.orthogonal() * (1.0 if id % 2 == 0 else -1.0)
	var to: Vector2 = c + (fwd * TOSS_AHEAD_M + side * TOSS_SIDE_M) * ppm
	return [c + fwd * 0.2 * ppm, to, arena.tick, facing + 0.9 * float(id % 3 - 1), ppm]


## The pistol in flight (a little hop, spinning) or lying where it landed.
func _gun(d: Array, id: int) -> void:
	var decay: CorpseDecay = host.decay if host != null else null
	if host != null and host.gone.has(id):
		return
	var t0: int = d[2]
	var ppm: float = d[4] * (decay.sink_of(id) if decay != null else 1.0)
	var rest: float = d[3]
	var k: float = clampf(float(arena.tick - t0) / float(TOSS_TICKS), 0.0, 1.0)
	var from: Vector2 = d[0]
	var to: Vector2 = d[1]
	var at: Vector2 = from.lerp(to, k) + Vector2(0.0, -sin(PI * k) * 0.15 * ppm)
	var ang: float = rest + (1.0 - k) * TOSS_SPIN * TOSS_TICKS
	var fwd: Vector2 = Vector2.from_angle(ang)
	var nrm: Vector2 = fwd.orthogonal()
	var l: float = GUN_LONG_M * ppm
	var w: float = GUN_WIDE_M * ppm
	var body: PackedVector2Array = [
		at - fwd * l * 0.5 - nrm * w * 0.5,
		at + fwd * l * 0.5 - nrm * w * 0.5,
		at + fwd * l * 0.5 + nrm * w * 0.5,
		at - fwd * l * 0.1 + nrm * w * 0.5,
		at - fwd * l * 0.2 + nrm * w * 1.9,
		at - fwd * l * 0.45 + nrm * w * 1.9,
		at - fwd * l * 0.5 + nrm * w * 0.5,
	]
	if not Geometry2D.triangulate_polygon(body).is_empty():  # a degenerate one logs an error
		draw_colored_polygon(body, Ink.INK)
	var rim: PackedVector2Array = body.duplicate()
	@warning_ignore("return_value_discarded")
	rim.append(body[0])
	var ink: float = decay.ink_of(id) if decay != null else 0.0
	draw_polyline(rim, Ink.CREAM.lerp(Ink.INK, ink), 1.5, true)
