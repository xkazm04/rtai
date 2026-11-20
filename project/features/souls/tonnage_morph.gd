class_name TonnageMorph
extends RefCounted
## Unfold is the golem's half of the existing in/out transition. Both views use the same reach.

const RIVET_SCALE: float = 1.0 / 3.0
const TUCK: Vector2 = Vector2(-0.05, 0.48)

var size_k: float = 1.0
var reach: float = 1.0
var _progress: float = 1.0
var _reveal: ShaderMaterial = ShaderMaterial.new()


func _init() -> void:
	_reveal.shader = preload("res://features/souls/tonnage_morph.gdshader")


func set_progress(k: float, body: Node2D, cell: Sprite2D, light: Sprite2D) -> void:
	if k == _progress:
		return
	_progress = k
	size_k = lerpf(RIVET_SCALE, 1.0, smoothstep(0.0, 1.0, k))
	reach = smoothstep(2.0 / 3.0, 0.95, k)
	body.modulate.a = smoothstep(0.0, 0.78, k)
	cell.material = _reveal if k < 1.0 else null
	_reveal.set_shader_parameter(&"emerge", k)
	_reveal.set_shader_parameter(&"reach", reach)
	# The additive copy can reappear once its unwarped fists coincide with the ink.
	light.self_modulate.a = TonnageGlow.GLOW_FILL_ALPHA * smoothstep(0.95, 1.0, k)


func hand(at: Vector3, side: float) -> Vector3:
	if reach == 1.0:
		return at
	return Vector3(TUCK.x, side * TUCK.y, TonnagePose.CHEST_H).lerp(at, reach)
