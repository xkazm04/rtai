class_name PlayerMotionDashView
extends Node2D
## Short, world-anchored exposures of Rivet's posed card. The texture supplies the metal
## and collar colours, including the current grip, pitch and facing.

const META: StringName = &"rivet_dash_trail"
const LIFE: int = 5
const SPACING: int = 2

var _rigs: CharacterRigs
var _tick: int
var _frame: int
var _last_tick: int = -1
var _copies: Array[Sprite2D] = []
var _born: Array[int] = []
var _next: int = 0


static func feed(rigs: CharacterRigs, motion: PlayerMotion, tick: int) -> void:
	var frame: int = motion.dash.frame if motion != null else -1
	var host: PlayerMotionDashView
	if rigs.has_meta(META):
		host = rigs.get_meta(META)
	elif frame >= 0:
		host = PlayerMotionDashView.new()
		host._rigs = rigs
		host.process_priority = 103  # sample the final posed and depth-sorted card
		rigs.add_child(host)
		rigs.set_meta(META, host)
	else:
		return
	host._frame = frame
	host._tick = tick
	if frame >= 0:
		var vel: Vector2 = rigs.feed.vel[0]
		if vel != Vector2.ZERO:
			var run_speed: float = motion.sprint_mps * CharacterRigs.PX_PER_M
			rigs.feed.vel[0] = vel.normalized() * maxf(vel.length(), run_speed)
		host.set_process(true)


func _ready() -> void:
	for i: int in ceili(float(LIFE) / SPACING):
		var copy: Sprite2D = Sprite2D.new()
		copy.hide()
		add_child(copy)
		_copies.append(copy)
		_born.append(-LIFE)


func _process(_delta: float) -> void:
	if _tick == _last_tick:
		return
	_last_tick = _tick
	var rig: CutRig = _rigs.rig_for(_rigs.feed.ids[0])
	if _frame >= 0 and _frame % SPACING == 0 and rig != null and not rig.dead:
		_expose(rig)
	var any: bool = false
	for i: int in _copies.size():
		var age: int = _tick - _born[i]
		var visible_copy: bool = age > 0 and age < LIFE and rig != null and not rig.dead
		_copies[i].visible = visible_copy
		_copies[i].self_modulate.a = 0.5 * clampf(1.0 - float(age) / LIFE, 0.0, 1.0)
		any = any or visible_copy
	if _frame < 0 and not any:
		set_process(false)


func _expose(rig: CutRig) -> void:
	var card: Sprite2D = rig.head_card
	if card == null or card.texture == null or not card.is_visible_in_tree():
		return
	var copy: Sprite2D = _copies[_next]
	copy.texture = card.texture
	copy.hframes = card.hframes
	copy.vframes = card.vframes
	copy.frame = card.frame
	copy.centered = card.centered
	copy.offset = card.offset
	copy.flip_h = card.flip_h
	copy.flip_v = card.flip_v
	copy.texture_filter = card.texture_filter
	copy.global_transform = card.global_transform
	copy.z_index = rig.z_index - 1
	_born[_next] = _tick
	_next = (_next + 1) % _copies.size()
