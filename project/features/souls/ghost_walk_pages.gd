class_name GhostWalkPages
extends RefCounted
## Shared timing for a set of walk rows. Pages divide wide grids at column boundaries.

var windows: Array[Vector2] = []
var pages: Array[GhostSheet] = []


func show(spr: Sprite2D, oct: int, phase: float) -> bool:
	var col: int = col_at(phase)
	if col < 0:
		return false
	@warning_ignore("integer_division")
	var page: GhostSheet = pages[col / pages[0].cols]
	var local_col: int = col % page.cols
	if GhostSheet.LEFT_ROW[oct] >= 0 and not page.drawn_left(oct, local_col):
		return false
	page.show(spr, oct, local_col)
	return true


## Search sorted half-open windows, continuing the last transition through phase zero.
func col_at(phase: float) -> int:
	if phase < 0.0:
		return -1
	var at: float = phase + 1.0 if phase < windows[0].x else phase
	for i: int in windows.size():
		var w: Vector2 = windows[i]
		if at < w.x:
			break
		if at < w.y:
			return i
	return -1
