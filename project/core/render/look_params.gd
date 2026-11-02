class_name LookParams
extends RefCounted
## One resolved look: the world print-pass uniforms (look_d4), the item-pass uniforms
## (look_d4_item) and the part flat-tint threshold. Built from a look_profiles.json row or as
## a blend of two; apply() pushes it into the two shared materials.

## True: the print passes run. False: the raw art (--look=off).
var printed: bool = true
var world: Dictionary[StringName, Variant] = {}
var item: Dictionary[StringName, Variant] = {}
var parts_flat_below: float = 0.13


static func from_row(row: Dictionary) -> LookParams:
	var p: LookParams = LookParams.new()
	p.printed = row.get("print", true)
	p.parts_flat_below = row.get("parts_flat_below", 0.13)
	var w: Dictionary = row["world"]
	for k: String in w:
		p.world[StringName(k)] = uniform_value(w[k])
	var it: Dictionary = row["item"]
	for k: String in it:
		p.item[StringName(k)] = uniform_value(it[k])
	return p


## a at t = 0, b at t = 1; floats and vectors interpolate, the print flag follows a.
static func lerp_params(a: LookParams, b: LookParams, t: float) -> LookParams:
	if t <= 0.0:
		return a
	if t >= 1.0:
		return b
	var p: LookParams = LookParams.new()
	p.printed = a.printed
	p.parts_flat_below = lerpf(a.parts_flat_below, b.parts_flat_below, t)
	for k: StringName in a.world:
		p.world[k] = _mix(a.world[k], b.world.get(k, a.world[k]), t)
	for k: StringName in a.item:
		p.item[k] = _mix(a.item[k], b.item.get(k, a.item[k]), t)
	return p


func duplicate_params() -> LookParams:
	var p: LookParams = LookParams.new()
	p.printed = printed
	p.parts_flat_below = parts_flat_below
	p.world = world.duplicate()
	p.item = item.duplicate()
	return p


## Pushes the uniforms into the world-pass and item-pass materials (either may be null).
func apply(world_mat: ShaderMaterial, item_mat: ShaderMaterial) -> void:
	if world_mat != null:
		for k: StringName in world:
			world_mat.set_shader_parameter(k, world[k])
	if item_mat != null:
		for k: StringName in item:
			item_mat.set_shader_parameter(k, item[k])


func equals(other: LookParams) -> bool:
	return (
		other != null
		and printed == other.printed
		and is_equal_approx(parts_flat_below, other.parts_flat_below)
		and world == other.world
		and item == other.item
	)


## A JSON value as a shader uniform: 2- and 3-arrays become vectors, numbers floats.
static func uniform_value(v: Variant) -> Variant:
	if v is Array:
		var a: Array = v
		var f: PackedFloat32Array = PackedFloat32Array(a)
		if f.size() == 2:
			return Vector2(f[0], f[1])
		if f.size() == 3:
			return Vector3(f[0], f[1], f[2])
	if v is float or v is int:
		var n: float = v
		return n
	return v


static func _mix(a: Variant, b: Variant, t: float) -> Variant:
	if a is float and b is float:
		var fa: float = a
		var fb: float = b
		return lerpf(fa, fb, t)
	if a is Vector2 and b is Vector2:
		var va: Vector2 = a
		var vb: Vector2 = b
		return va.lerp(vb, t)
	if a is Vector3 and b is Vector3:
		var wa: Vector3 = a
		var wb: Vector3 = b
		return wa.lerp(wb, t)
	return a
