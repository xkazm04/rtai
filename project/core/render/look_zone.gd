class_name LookZone
extends RefCounted
## A stage-local print override (core/render/README.md): world-pass uniforms (look_d4) that a
## close-up stage sets for its own floor, blended over the resolved look profile by where the
## camera's focus sits. Weight 1 inside `rect_m`, falling to 0 at `fade_m` metres outside it, so
## walking out of the stage eases back to the profile with no pop. Render only.

## The stage's floor in sim metres.
var rect_m: Rect2 = Rect2()
## Metres outside rect_m over which the override fades out (0 = a hard edge).
var fade_m: float = 6.0
## look_d4 world uniform -> value at weight 1 (floats only).
var world: Dictionary[StringName, float] = {}


static func create(rect: Rect2, fade: float, uniforms: Dictionary) -> LookZone:
	var z: LookZone = LookZone.new()
	z.rect_m = rect
	z.fade_m = fade
	for k: String in uniforms:
		var v: float = uniforms[k]
		z.world[StringName(k)] = v
	return z


func weight(focus_m: Vector2) -> float:
	if rect_m.has_point(focus_m):
		return 1.0
	var near: Vector2 = focus_m.clamp(rect_m.position, rect_m.end)
	if fade_m <= 0.0:
		return 0.0
	return clampf(1.0 - near.distance_to(focus_m) / fade_m, 0.0, 1.0)


## `p` with this zone's uniforms mixed in at weight `w` (a copy; `p` is shared and stays as is).
func apply_to(p: LookParams, w: float) -> LookParams:
	if w <= 0.0 or world.is_empty() or not p.printed:
		return p
	var out: LookParams = p.duplicate_params()
	for k: StringName in world:
		var base: float = p.world.get(k, world[k])
		out.world[k] = lerpf(base, world[k], w)
	return out
