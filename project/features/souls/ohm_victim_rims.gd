class_name OhmVictimRims
extends Node2D
## One mark per actual strike notification. A new bolt can leave earlier stuns on screen.

const CLEARANCE_M: float = 0.15
const FADE_TICKS: int = 18
const SPARK_TICKS: int = 12


class Mark:
	extends RefCounted
	var fighter: Fighter
	var appear: int
	var end: int
	var died: bool
	var rig: CutRig
	var offset: Vector2


## The two shared electro renderers yield their body sparks while this specific victim has a rim.
static var _marked: Dictionary[int, Mark] = {}
var stage: CollectCallStage
var calm: bool
var ppm: float
var _active: Array[Mark] = []
var _cast: Array[Mark] = []
var _cast_tick: int = -1


func _enter_tree() -> void:
	z_as_relative = false
	# A car card can sit behind the raised torso but above the ground actor band.
	z_index = RenderLayers.z(&"vehicles") + 1
	@warning_ignore("return_value_discarded")
	stage.arena.struck.connect(_struck)


func _exit_tree() -> void:
	stage.arena.struck.disconnect(_struck)
	for mark: Mark in _active:
		_forget(mark)
	_active.clear()
	_cast.clear()
	_cast_tick = -1


static func marked(fighter: Fighter) -> bool:
	return _marked.has(fighter.get_instance_id()) and GhostLook.spectral(OhmStage.ID)


static func arcs(fighter: Fighter, count: Vector2i) -> Vector2i:
	return Vector2i.ZERO if marked(fighter) else count


static func sparks(fighter: Fighter, count: int) -> int:
	return 0 if marked(fighter) else count


func _struck(fighter: Fighter, _dir: Vector2, lethal: bool, weapon: StringName) -> void:
	if weapon != OhmStage.WEAPON:
		return
	var ohm: OhmStage = stage.pilot.ohm
	if _cast_tick != ohm.bolt_tick:
		_cast.clear()
		_cast_tick = ohm.bolt_tick
	var mark: Mark = Mark.new()
	mark.fighter = fighter
	mark.died = lethal
	mark.rig = _rig_for(fighter)
	mark.offset = _pose_offset(mark)
	mark.appear = _cast_tick + OhmBoltDraw.delay(_cast.size(), calm)
	mark.end = (
		mark.appear + FADE_TICKS if lethal else _cast_tick + PowerDef.ticks(ohm.num(&"stun_s"))
	)
	var key: int = fighter.get_instance_id()
	if _marked.has(key):
		_active.erase(_marked[key])
	_marked[key] = mark
	_cast.append(mark)
	_active.append(mark)


func _forget(mark: Mark) -> void:
	var key: int = mark.fighter.get_instance_id()
	if _marked.get(key) == mark:
		@warning_ignore("return_value_discarded")
		_marked.erase(key)


func _process(_delta: float) -> void:
	for i: int in range(_active.size() - 1, -1, -1):
		var mark: Mark = _active[i]
		if remaining(mark) <= 0:
			_forget(mark)
			_active.remove_at(i)
	queue_redraw()


func remaining(mark: Mark) -> int:
	var left: int = mark.end - stage.tick
	if not mark.died:
		if not mark.fighter.alive():
			return 0
		if stage.arena.areas != null:
			var fx: FighterFx = stage.arena.areas.effect(mark.fighter)
			return mini(left, fx.stun_ticks) if fx != null else 0
	return left


## The path's ground contact plus the torso's projected height. Cars use their recorded contact.
func target(ohm: OhmStage, index: int) -> Vector2:
	var at: Vector2 = ohm.bolt_path[index] * ppm
	return at + _pose_offset(_cast[index - 1]) if _body(ohm, index) != null else at


func radius(ohm: OhmStage, index: int) -> float:
	var f: Fighter = _body(ohm, index)
	return ((f.radius_m + CLEARANCE_M) if f != null else 0.25) * ppm


func car_contact(ohm: OhmStage) -> bool:
	return ohm.bolt_path.size() == 2 and _body(ohm, 1) == null


func _body(ohm: OhmStage, index: int) -> Fighter:
	if _cast_tick != ohm.bolt_tick or index < 1 or index > _cast.size():
		return null
	return _cast[index - 1].fighter


func _rig_for(fighter: Fighter) -> CutRig:
	var layer: CanvasLayer = get_canvas_layer_node()
	var sorter: RigDepthSort = RigDepthSort.on(layer) if layer != null else null
	if sorter != null:
		for rig: CutRig in sorter.frame_rigs:
			if is_instance_valid(rig) and rig.actor_id == fighter.id:
				return rig
	return null


## Follow the same visible card/torso as the arena's squad overlay. Keep the last pose when
## the signature kill exchanges the living rig for its falling copy.
func _pose_offset(mark: Mark) -> Vector2:
	var rig: CutRig = mark.rig
	if is_instance_valid(rig) and rig.actor_id == mark.fighter.id and rig.is_visible_in_tree():
		var card: Sprite2D = rig.head_card
		var centre: Vector2 = rig.torso.global_position
		if card != null and card.is_visible_in_tree():
			centre = card.to_global(card.get_rect().get_center())
		mark.offset = to_local(centre) - mark.fighter.pos * ppm
	elif not mark.died or mark.offset == Vector2.ZERO:
		mark.offset = ViewMode.shared().lift_px(1.35)
	return mark.offset


func _draw() -> void:
	for mark: Mark in _active:
		var age: int = stage.tick - mark.appear
		if age < 0:
			continue
		var centre: Vector2 = mark.fighter.pos * ppm + _pose_offset(mark)
		var r: float = (mark.fighter.radius_m + CLEARANCE_M) * ppm
		var fade: float = clampf(float(remaining(mark)) / FADE_TICKS, 0.0, 1.0)
		ring(self, centre, r, fade)
		if not mark.died and age < SPARK_TICKS and not calm:
			for i: int in 4:
				var ray: PackedVector2Array = spark(r, age, i, mark.fighter.id)
				var alpha: float = 1.0 - float(age) / SPARK_TICKS
				draw_line(centre + ray[0], centre + ray[1], Color(OhmView.INK, alpha), 2.4, true)
				draw_line(centre + ray[0], centre + ray[1], Color(OhmView.WHITE, alpha), 1.1, true)


static func ring(ink: CanvasItem, centre: Vector2, r: float, fade: float) -> void:
	ink.draw_arc(centre, r, 0.0, TAU, 42, Color(OhmView.INK, 0.85 * fade), 2.6, true)
	ink.draw_arc(centre, r, 0.0, TAU, 42, Color(Color("#abfff1"), fade), 1.2, true)


static func spark(r: float, age: int, i: int, id: int) -> PackedVector2Array:
	var t: float = float(age) / SPARK_TICKS
	var dir: Vector2 = Vector2.from_angle(i * TAU / 4.0 + id * 1.73 + sin(i * 4.3) * 0.16)
	var start: float = r * (1.08 + t * 0.54)
	return PackedVector2Array([dir * start, dir * (start + r * (0.32 - 0.12 * t))])
