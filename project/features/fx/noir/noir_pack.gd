class_name NoirPack
extends RefCounted
## Small static helpers of the noir blood FX (lane noir): the counter hash, colours from data,
## zero-filled packed pools.


## A counter hash in [0, 1) (no RNG stream: the blood is render only and repeats exactly).
static func hash01(i: int) -> float:
	var x: int = (i * 1103515245 + 12345) & 0x7fffffff
	x = ((x >> 13) ^ x) * 1274126177 & 0x7fffffff
	return float(x % 100003) / 100003.0


## [r, g, b] from a JSON table -> Color.
static func rgb(v: Variant) -> Color:
	var a: Array = v
	var r: float = a[0]
	var g: float = a[1]
	var b: float = a[2]
	return Color(r, g, b)


## Zero-filled pools of n slots.
static func vec2s(n: int) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	@warning_ignore("return_value_discarded")
	out.resize(n)
	return out


static func floats(n: int) -> PackedFloat32Array:
	var out: PackedFloat32Array = PackedFloat32Array()
	@warning_ignore("return_value_discarded")
	out.resize(n)
	return out


static func ints(n: int) -> PackedInt32Array:
	var out: PackedInt32Array = PackedInt32Array()
	@warning_ignore("return_value_discarded")
	out.resize(n)
	return out
