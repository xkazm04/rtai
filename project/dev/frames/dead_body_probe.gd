class_name DeadBodyProbe
extends Node
## n11 combat (dev `--body-probe=<json>`): measures the owner's three corpse notes on the live game.
## Every frame, after the rigs posed: each dead hostile's sim point, its drawn lying sprite (on the
## rig or kept by StreetDeadRest), and how far either moved once settled; a marker on the actors
## canvas against one on the ground canvas (a body that slides against the road shows here); and
## the lying sprite's drawn size against the same person's standing card. Writes one JSON on exit.

const PRIORITY: int = 40
## A body is settled this many ticks after it is first seen dead (the fall and its slide are over).
const SETTLE_TICKS: int = 60
const WORST_KEPT: int = 12
const TRACKED: int = 40
const MOVE_PX: float = 0.1


class Body:
	extends RefCounted
	var id: int = 0
	var first: int = 0
	var sim: Vector2 = Vector2.ZERO
	var sim_max: float = 0.0
	var draw: Vector2 = Vector2.INF
	var draw_max: float = 0.0
	var pops: int = 0
	var size_px: Vector2 = Vector2.ZERO
	var standing_px: float = 0.0
	var track: PackedFloat32Array = PackedFloat32Array()
	var last_at: Vector2 = Vector2.INF


var out_path: String = ""
var stage: ArenaStage = null
var rigs: ArenaRigs = null
var ground_parent: Node = null
var actor_layer: CanvasLayer = null
var _ground: Node2D = Node2D.new()
var _actor: Node2D = Node2D.new()
var _bodies: Dictionary[int, Body] = {}
var _standing: Dictionary[int, float] = {}
var _max_layer_px: float = 0.0
var _written: bool = false


static func attach(parent: Node, args: ArenaArgs, game_stage: ArenaStage, cast: ArenaRigs) -> void:
	if not args.has("--body-probe") or cast == null:
		return
	var p: DeadBodyProbe = DeadBodyProbe.new()
	p.out_path = args.text("--body-probe")
	p.stage = game_stage
	p.rigs = cast
	p.actor_layer = cast.rigs.get_parent() as CanvasLayer
	p.ground_parent = parent
	parent.add_child(p)


func _ready() -> void:
	process_priority = PRIORITY
	ground_parent.add_child(_ground)
	if actor_layer != null:
		actor_layer.add_child(_actor)


func _process(_delta: float) -> void:
	if stage == null:
		return
	if actor_layer != null:
		var a: Vector2 = _actor.get_global_transform_with_canvas().origin
		var g: Vector2 = _ground.get_global_transform_with_canvas().origin
		_max_layer_px = maxf(_max_layer_px, a.distance_to(g))
	for h: Fighter in stage.arena.hostiles:
		_sample(h)


func _sample(h: Fighter) -> void:
	var rig: CutRig = rigs.rigs.rig_for(h.id)
	if h.alive():
		if rig != null and rig.head_card != null and rig.head_card.visible:
			_standing[h.id] = _used_px(rig.head_card).y
		return
	if not _bodies.has(h.id):
		var fresh: Body = Body.new()
		fresh.id = h.id
		fresh.first = stage.tick
		fresh.sim = h.pos
		_bodies[h.id] = fresh
	var b: Body = _bodies[h.id]
	_track(b, _lying(h.id, rig))
	if stage.tick - b.first < SETTLE_TICKS:
		b.sim = h.pos
		return
	b.sim_max = maxf(b.sim_max, b.sim.distance_to(h.pos))
	var drawn: Sprite2D = _lying(h.id, rig)
	if drawn == null:
		return
	var at: Vector2 = drawn.global_position
	if b.draw == Vector2.INF:
		b.draw = at
		b.size_px = _used_px(drawn)
		b.standing_px = _standing.get(h.id, 0.0)
		return
	var moved: float = b.draw.distance_to(at)
	b.draw_max = maxf(b.draw_max, moved)
	if moved > 0.5:
		b.pops += 1


## Appends (age, x, y) whenever the drawn body moved by more than MOVE_PX since its last entry.
func _track(b: Body, drawn: Sprite2D) -> void:
	if drawn == null or b.id >= TRACKED:
		return
	var at: Vector2 = drawn.global_position
	if b.last_at == Vector2.INF or b.last_at.distance_to(at) > MOVE_PX:
		b.last_at = at
		b.track.append_array(PackedFloat32Array([stage.tick - b.first, at.x, at.y]))


## The sprite drawing `id`'s body now: on its rig's card, or kept by StreetDeadRest.
func _lying(id: int, rig: CutRig) -> Sprite2D:
	if rig != null and rig.head_card != null:
		var on: Sprite2D = rig.head_card.get_node_or_null(StreetDeadPlan.NODE) as Sprite2D
		if on != null:
			return on
	return rigs.rigs.rest.top_sprite(id)


## The drawn (opaque) size of `s`'s current cell in world px.
func _used_px(s: Sprite2D) -> Vector2:
	if s.texture == null:
		return Vector2.ZERO
	var img: Image = s.texture.get_image()
	if img.is_compressed() and img.decompress() != OK:
		return Vector2.ZERO
	var cw: int = img.get_width() / maxi(s.hframes, 1)
	var ch: int = img.get_height() / maxi(s.vframes, 1)
	var cell: Rect2i = Rect2i(s.frame_coords.x * cw, s.frame_coords.y * ch, cw, ch)
	return Vector2(img.get_region(cell).get_used_rect().size) * s.global_scale.abs()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		_write()


func _write() -> void:
	if _written or out_path == "":
		return
	_written = true
	var rows: Array[Dictionary] = []
	for id: int in _bodies:
		if _bodies[id].draw != Vector2.INF:
			rows.append(_row(_bodies[id]))
	rows.sort_custom(
		func(a: Dictionary, c: Dictionary) -> bool:
			var am: float = a["draw_m"]
			var cm: float = c["draw_m"]
			return am > cm
	)
	var out: Dictionary = {
		"bodies": _bodies.size(),
		"settled_drawn": rows.size(),
		"max_layer_px": _max_layer_px,
		"worst": rows.slice(0, WORST_KEPT),
		"tracks": _tracks(),
	}
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	if f != null:
		@warning_ignore("return_value_discarded")
		f.store_string(JSON.stringify(out, "\t"))
		f.close()
	Log.info("probe", "dead body probe -> %s (%d bodies)" % [out_path, _bodies.size()])


func _tracks() -> Dictionary:
	var out: Dictionary = {}
	for id: int in _bodies:
		if not _bodies[id].track.is_empty():
			out[str(id)] = Array(_bodies[id].track)
	return out


func _row(b: Body) -> Dictionary:
	return {
		"id": b.id,
		"sim_m": b.sim_max,
		"draw_m": b.draw_max / SimConst.PX_PER_M,
		"pops": b.pops,
		"lying_w": b.size_px.x,
		"lying_h": b.size_px.y,
		"standing_h": b.standing_px,
	}
