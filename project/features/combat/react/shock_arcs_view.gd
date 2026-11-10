class_name ShockArcsView
extends Node2D
## The electro gun's marks on a stunned human, drawn above the rigs (the fight's fx layer sits
## under them, where arcs on the body were hidden): arcs crawling over the body (ShockJolt.arcs)
## centred on the rig's drawn torso so they ride its convulsion, and the pistol his fingers let go
## (the rig's hand cell drops the gun while he convulses): tossed out of the gun hand on the first
## stun tick, it lies beside him until the stun ends; an electro corpse keeps it, and it inks out
## and sinks with the body (CorpseDecay via RigHost.decay), gone with it. Reads the
## arena's stun state on its tick; render only, no RNG. n13: the gun is the pistol's drawn pickup
## cell (the side view lying on the floor) re-toned and cut small (weapon_art.json parts.dropped,
## tools/art/dropped_gun.py) inside an ink outline, loaded at _ready (behind the load);
## `--dropped-gun=polygon` draws the n7 placeholder (the before).

## The toss: ticks in the air, how far it lands from the torso (m, ahead and to the gun side),
## its spin while flying (rad per tick) and the pistol's size (m).
const TOSS_TICKS: int = 8
const TOSS_AHEAD_M: float = 0.4
const TOSS_SIDE_M: float = 0.3
const TOSS_SPIN: float = 0.55
const GUN_LONG_M: float = 0.24
const GUN_WIDE_M: float = 0.06
## n12 D1: the dropped pistol lies on the ground band, under every body (it drew over Rivet's arm
## as a cream bracket floating at his shoulder); the arcs stay above. false = the before.
const GUN_ON_FLOOR: bool = true
## n13: the drawn cell's span across its longer side (m), its ink outline (world px: the pickups'
## 2 px fattened a 12 px cell into a blob), and the weapon and part the cell is.
## Its drop angle is folded to lie muzzle-sideways (mirrored, never upside down) and its tilt off
## the horizontal kept at CELL_TILT_K: at 15 screen px a pistol turned 35 deg or more read as a
## blob in the offline sims and on film; lying near flat its L (barrel, grip) reads.
const CELL_SPAN_M: float = 0.48
const CELL_TILT_K: float = 0.5
const CELL_INK_PX: float = 1.5
const CELL_WEAPON: StringName = &"pistol"
const CELL_PART: String = "dropped"

var arena: CombatArena = null
var rigs: CharacterRigs = null
var host: RigHost = null
## n13: the drawn gun cell (null = the placeholder polygon).
var cell: Texture2D = null
## Fighter id -> [from px, to px, the stun's first tick, rest angle, px per metre].
var _drops: Dictionary[int, Array] = {}
## The pistols to draw this frame on the floor: [toss, fighter id].
var _lying: Array[Array] = []
var _floor: Node2D = null


func _ready() -> void:
	if ArenaArgs.parse().text("--dropped-gun") != "polygon":
		cell = WeaponArt.new().part_texture(CELL_WEAPON, CELL_PART)
	if not GUN_ON_FLOOR:
		return
	_floor = Node2D.new()
	_floor.z_as_relative = false  # just over the bodies' cast shadows, under every body
	_floor.z_index = RenderLayers.z(&"actors") - 1 + RigDepthSort.ground_dz()
	_floor.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS  # n13: the cell at 1/25
	add_child(_floor)
	@warning_ignore("return_value_discarded")
	_floor.draw.connect(_draw_floor)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	_lying.clear()
	if _floor != null:
		_floor.queue_redraw()
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
				_lay(_drops[h.id], h.id)
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
			_lay(_drops[h.id], h.id)


func _toss(c: Vector2, ppm: float, facing: float, id: int) -> Array:
	var fwd: Vector2 = Vector2.from_angle(facing)
	var side: Vector2 = fwd.orthogonal() * (1.0 if id % 2 == 0 else -1.0)
	var to: Vector2 = c + (fwd * TOSS_AHEAD_M + side * TOSS_SIDE_M) * ppm
	return [c + fwd * 0.2 * ppm, to, arena.tick, facing + 0.9 * float(id % 3 - 1), ppm]


func _lay(d: Array, id: int) -> void:
	if _floor == null:
		_gun(self, d, id)
	else:
		_lying.append([d, id])


func _draw_floor() -> void:
	for g: Array in _lying:
		var d: Array = g[0]
		var id: int = g[1]
		_gun(_floor, d, id)


## The pistol in flight (a little hop, spinning) or lying where it landed, drawn on `ci`.
func _gun(ci: CanvasItem, d: Array, id: int) -> void:
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
	var ink: float = decay.ink_of(id) if decay != null else 0.0
	if cell != null:
		_cell(ci, at, ang, ppm, ink)
		return
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
		ci.draw_colored_polygon(body, Ink.INK)
	var rim: PackedVector2Array = body.duplicate()
	@warning_ignore("return_value_discarded")
	rim.append(body[0])
	ci.draw_polyline(rim, Ink.CREAM.lerp(Ink.INK, ink), 1.5, true)


## n13: how the cell lies for a drop angle `ang`: x = its rotation (folded so the muzzle points
## sideways, tilt scaled by CELL_TILT_K), y = 1, or -1 when the cell is mirrored (pointing left).
static func lie_of(ang: float) -> Vector2:
	var a: float = wrapf(ang, -PI, PI)
	if absf(a) <= PI * 0.5:
		return Vector2(a * CELL_TILT_K, 1.0)
	return Vector2(wrapf(a - PI, -PI, PI) * CELL_TILT_K, -1.0)


## n13: the pickup cell lying at `at`, turned to `ang`, CELL_SPAN_M across its longer side, inside
## an ink outline of CELL_INK_PX world px (the pickups' edge, PickupLook), inking out with the body.
func _cell(ci: CanvasItem, at: Vector2, ang: float, ppm: float, ink: float) -> void:
	var size: Vector2 = cell.get_size()
	var k: float = CELL_SPAN_M * ppm / maxf(size.x, size.y)
	var reach: float = CELL_INK_PX / k
	var lie: Vector2 = lie_of(ang)
	ci.draw_set_transform(at, lie.x, Vector2(k * lie.y, k))
	for i: int in PickupLook.OUTLINE_DIRS:
		var off: Vector2 = Vector2.from_angle(TAU * i / PickupLook.OUTLINE_DIRS) * reach
		ci.draw_texture(cell, off - size * 0.5, Ink.INK)
	ci.draw_texture(cell, -size * 0.5, Color.WHITE.lerp(Ink.INK, ink))
	ci.draw_set_transform(Vector2.ZERO)
