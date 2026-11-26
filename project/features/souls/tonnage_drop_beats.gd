class_name TonnageDropBeats
extends RefCounted
## n31 ghost 03: Tonnage's drop deploy drawn in beats (P = press, D = the dump tick, P + charge).
## Row 0 (toward the camera) of art/view/p70/tonnage_spectral_drop.png, cols below; -1 = the
## shipped spectral cells (pose CARRY while he falls, act LIFT after the slam).
## - arrival: P..P+5 he falls from DROP_FROM_M (shipped CARRY), P+6..P+9 SQUASH;
## - charge: P+10..D-1 GATHER for the first half, PEAK for the second (fists up);
## - dump: D..D+4 SLAM; D+5..D+14 the shipped LIFT;
## - aftermath: D+15.. AWAY, rising AWAY_RISE_M over AWAY_RISE_TICKS under the deploy's fade.

enum Col { SQUASH, GATHER, PEAK, SLAM, AWAY }

const DROP: Texture2D = preload("res://features/souls/art/view/p70/tonnage_spectral_drop.png")
const DROP_TICKS: int = 6
const SQUASH_TICKS: int = 4
const DROP_FROM_M: float = 3.0
const AWAY_RISE_M: float = 1.5
const AWAY_RISE_TICKS: int = 30


## The strip column `since` ticks after the press; `struck` = ticks since the dump (< 0 before).
static func col(since: int, charge: int, struck: int) -> int:
	var lift_end: int = GhostDrawn.CUT_TICKS + GhostDrawn.FOLLOW_TICKS
	if struck >= 0:
		if struck < GhostDrawn.CUT_TICKS:
			return Col.SLAM
		return -1 if struck < lift_end else Col.AWAY
	if since < DROP_TICKS:
		return -1
	var gather: int = DROP_TICKS + SQUASH_TICKS
	if since < gather:
		return Col.SQUASH
	return Col.GATHER if since < gather + ceili((charge - gather) / 2.0) else Col.PEAK


## Height above the spot (m): the fall (ease-in) before the landing, the rise after the lift.
static func lift_m(since: int, struck: int) -> float:
	if struck < 0:
		var t: float = clampf(float(since) / DROP_TICKS, 0.0, 1.0)
		return DROP_FROM_M * (1.0 - t * t)
	var away: int = struck - GhostDrawn.CUT_TICKS - GhostDrawn.FOLLOW_TICKS
	return AWAY_RISE_M * smoothstep(0.0, AWAY_RISE_TICKS, away)


## Paints column `column` of the drop strip over the rig's spectral cell and its light (after the
## rig's own advance picked a shipped cell); p70 art only, the strip has no p55 twin.
static func paint(rig: Node, column: int) -> void:
	var vm: ViewMode = ViewMode.shared()
	var p70: bool = vm.art == "p70" or (vm.art != "p55" and vm.pitch_deg >= 62.5)
	var cell: Sprite2D = rig.find_child("ghost_drawn", true, false) as Sprite2D
	if column < 0 or not p70 or cell == null:
		return
	_show(cell, column)
	for child: Node in cell.get_children():
		if child is Sprite2D:
			_show(child as Sprite2D, column)


static func _show(spr: Sprite2D, column: int) -> void:
	if spr.texture != DROP:
		spr.frame = 0
		spr.texture = DROP
		spr.hframes = Col.size()
		spr.vframes = 1
		spr.offset.x = -DROP.get_width() * 0.5 / spr.hframes
	spr.frame = column
	spr.flip_h = false


## The charge's wind-up (0..1) for the shipped RAISE fallback: 0 until the squash ends, 1 on D.
static func windup(since: int, charge: int, struck: int) -> float:
	var gather: int = DROP_TICKS + SQUASH_TICKS
	if struck >= 0 or charge <= gather:
		return 0.0
	return clampf(float(since - gather + 1) / (charge - gather), 0.0, 1.0)
