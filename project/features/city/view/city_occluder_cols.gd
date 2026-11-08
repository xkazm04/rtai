class_name CityOccluderCols
extends RefCounted
## CityOccluders' column index of one chunk's buildings (perf L20c): each building's list index sits
## under every COL_PX screen column its ground rect's x-span touches, so a body box (~2.4 m) reads
## the one or two columns it meets instead of the chunk's ~300 buildings.

## The column width (px).
const COL_PX: float = 128.0

var by: Dictionary[int, PackedInt32Array] = {}


func at(c: int) -> PackedInt32Array:
	return by[c] if by.has(c) else PackedInt32Array()


## Puts building k under every column its ground rect's x-span touches.
func add(k: int, r: Rect2) -> void:
	for c: int in range(floori(r.position.x / COL_PX), floori(r.end.x / COL_PX) + 1):
		var ks: PackedInt32Array = at(c)
		@warning_ignore("return_value_discarded")
		ks.append(k)
		by[c] = ks


## The buildings (indices, ascending, once each) under the columns from x0 to x1 (px).
func between(x0: float, x1: float) -> PackedInt32Array:
	var c0: int = floori(x0 / COL_PX)
	var c1: int = floori(x1 / COL_PX)
	if c0 == c1:
		return at(c0)
	var all: PackedInt32Array = PackedInt32Array()
	for c: int in range(c0, c1 + 1):
		all.append_array(at(c))
	all.sort()
	var ks: PackedInt32Array = PackedInt32Array()
	for k: int in all:
		if ks.is_empty() or ks[ks.size() - 1] != k:
			@warning_ignore("return_value_discarded")
			ks.append(k)
	return ks
