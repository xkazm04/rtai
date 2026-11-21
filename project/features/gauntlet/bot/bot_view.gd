class_name BotView
extends RefCounted
## One tick of simulation observations. Adapters refresh before the brain samples.
## Positions and Rect2 solids are world metres. IDs stay stable for a body's or round's lifetime.


class Player:
	var pos: Vector2
	var facing: Vector2 = Vector2.RIGHT
	var radius: float = 0.45
	var hp: float = 1.0
	## A positive value enables repair decisions on a street with a cleared approach.
	var street_max_hp: float = 0.0
	var form: StringName = &"base"
	var selected: StringName = &""
	var settled: bool = true
	var forms: Array[StringName] = []
	var current_slot: int = -1
	var can_roll: bool = false
	var can_guard: bool = false
	var shots_fired: int = 0
	var rolls_started: int = 0
	var car_pos: Vector2 = Vector2.INF
	var seized_car_pos: Vector2 = Vector2.INF


class Hostile:
	var id: int
	var pos: Vector2
	var archetype: StringName
	var alive: bool = true
	var facing: Vector2
	var hp: float
	var tier: int
	var robot: bool
	var shooter: bool
	## Empty while idle, otherwise small, large or melee.
	var tell: StringName = &""


class Round:
	var id: int
	var pos: Vector2
	var vel: Vector2
	var size: StringName = &"small"
	var remaining_m: float = INF


class Slot:
	var action: StringName
	var index: int
	var reach: float
	var melee: bool


var _player: Player = Player.new()
var _hostiles: Array[Hostile] = []
var _rounds: Array[Round] = []
var _solids: Array[Rect2] = []
var _slots: Array[Slot] = []


func refresh() -> void:
	pass


func player() -> Player:
	return _player


func hostiles() -> Array[Hostile]:
	return _hostiles


func incoming() -> Array[Round]:
	return _rounds


func solid_props() -> Array[Rect2]:
	return _solids


func held_slots() -> Array[Slot]:
	return _slots


func wave_active() -> bool:
	return not _hostiles.is_empty()


## Movement intent between waves, including approach waypoints if the scene has them.
func forward() -> Vector2:
	return Vector2.RIGHT


func retreat() -> Vector2:
	return Vector2.LEFT


func chase(foe: Hostile) -> Vector2:
	var dir: Vector2 = _player.pos.direction_to(foe.pos)
	if clear_line(_player.pos, foe.pos):
		return dir
	var flank: float = 1.0 if foe.id % 2 == 0 else -1.0
	return (dir * 0.4 + dir.orthogonal() * flank).normalized()


func clear_line(a: Vector2, b: Vector2) -> bool:
	for box: Rect2 in solid_props():
		if crosses(box, a, b):
			return false
	return true


static func crosses(box: Rect2, a: Vector2, b: Vector2) -> bool:
	var slab: AABB = AABB(
		Vector3(box.position.x, box.position.y, -1), Vector3(box.size.x, box.size.y, 2)
	)
	return slab.intersects_segment(Vector3(a.x, a.y, 0), Vector3(b.x, b.y, 0)) != null
