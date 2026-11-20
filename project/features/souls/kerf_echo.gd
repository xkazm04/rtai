class_name KerfEcho
extends Node2D
## A hidden pose is refreshed from the sprites actually on screen. At a blink it trades places
## with the oldest echo, so none of the three hanging poses is re-posed by the live rig.

const POOL: int = 3
const ALPHA: float = 0.35
const WASH_COLOR: Color = Color("#2ec4b6")
const WASH_MIX: float = 0.6
const STRETCH: float = 0.12
const STRETCH_TICKS: int = 3


class Pose:
	extends CanvasGroup
	var born: int = -1
	var anchor: Vector2
	var axis: Vector2
	var sprites: Array[Sprite2D] = []

	func capture(sources: Array[Sprite2D], ground: Vector2) -> void:
		for i: int in sources.size():
			var src: Sprite2D = sources[i]
			if i == sprites.size():
				var copy: Sprite2D = Sprite2D.new()
				copy.material = KerfEcho._wash
				add_child(copy)
				sprites.append(copy)
			var dst: Sprite2D = sprites[i]
			dst.visible = src.is_visible_in_tree()
			if not dst.visible:
				continue
			dst.texture = src.texture
			dst.texture_filter = src.texture_filter
			dst.hframes = src.hframes
			dst.vframes = src.vframes
			dst.frame = src.frame
			dst.flip_h = src.flip_h
			dst.centered = src.centered
			dst.self_modulate = src.self_modulate
			dst.offset = src.offset
			dst.transform = src.global_transform
			dst.position -= ground

	func show_at(tick: int, hang_s: float) -> void:
		var age: int = tick - born
		var fade: float = KerfSlot.remaining(age, hang_s)
		visible = born >= 0 and age >= 0 and fade > 0.0
		if not visible:
			return
		var stretch: float = STRETCH * maxf(0.0, 1.0 - float(age) / STRETCH_TICKS)
		var along: Transform2D = Transform2D(axis.angle(), Vector2.ZERO)
		var elongate: Transform2D = Transform2D.IDENTITY.scaled(Vector2(1.0 + stretch, 1))
		global_transform = along * elongate * along.inverse()
		global_position = anchor
		# Fade the composite once. Inherited alpha also fades its children into the group.
		self_modulate = Color(Color.WHITE, ALPHA * fade)


static var _wash: ShaderMaterial = _wash_material()

var _sources: Array[Sprite2D] = []
var _pool: Array[Pose] = []
var _buffer: Pose
var _next: int = 0
var _sample_tick: int = -1


## Copy the original coverage into the group. The group composites its alpha once, even where
## the helmet and shoulder plates overlap.
static func _wash_material() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type canvas_item;
render_mode unshaded;
uniform vec4 wash : source_color;
varying vec3 tint;
void vertex() {
	tint = COLOR.rgb;
}
void fragment() {
	vec4 part = texture(TEXTURE, UV);
	COLOR = vec4(mix(part.rgb * tint, wash.rgb, wash.a), COLOR.a);
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter(&"wash", Color(WASH_COLOR, WASH_MIX))
	return mat


func bind(top: KerfRoninTop, tilted: KerfRoninDrawn) -> void:
	for sprite: Sprite2D in top.get_children():
		_sources.append(sprite)
		if sprite == top.slots.plate:
			_sources.append_array(top.slots.masks)
	_sources.append(tilted)
	_sources.append_array(tilted.slots.masks)
	_buffer = _new_pose()


func step(stage: CollectCallStage) -> void:
	var k: KerfStage = stage.pilot.kerf
	if not k.trail_tick.is_empty() and _sample_tick >= 0:
		var born: int = k.trail_tick[-1]
		if born > _sample_tick and born <= stage.tick:
			_leave(k, born)
	for p: Pose in _pool:
		p.show_at(stage.tick, k.num(&"cut_hang_s"))
	_sample_tick = stage.tick
	_buffer.capture(_sources, stage.arena.rivet.pos * SimConst.PX_PER_M)


func _leave(k: KerfStage, born: int) -> void:
	if _pool.size() < POOL:
		_pool.append(_new_pose())
	var spare: Pose = _pool[_next]
	_pool[_next] = _buffer
	_buffer.born = born
	_buffer.anchor = k.trail_from[-1] * SimConst.PX_PER_M
	_buffer.axis = k.trail_from[-1].direction_to(k.trail_to[-1])
	_buffer = spare
	_buffer.hide()
	_next = (_next + 1) % POOL


func _new_pose() -> Pose:
	var p: Pose = Pose.new()
	p.hide()
	add_child(p)
	return p
