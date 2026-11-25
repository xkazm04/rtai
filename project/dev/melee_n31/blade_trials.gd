class_name BladeTrials
extends RefCounted
## n31 melee 01a: the blade_volume plan and its record. Ring cells (12 angles x 5 distances, one
## standing dummy per swing), then movers crossing the swing at MOVER_X ahead at SPEED, on the
## aim line LAG ticks after the first ring swing's hit test (both directions). k counts ticks
## from the press (k 0). The first trial's drawn frames are kept (union) for the plot.

const DISTS: Array[float] = [0.8, 1.4, 2.0, 2.6, 3.2]
const ANGLES: int = 12
const LAGS: Array[int] = [-10, 0, 10, 20, 30, 45, 60]
const MOVER_X: float = 1.4
const SPEED: float = 1.4

var plan: Array[Dictionary] = []
var i: int = 0
## The hit-test tick of the first swing (k), -1000 until it is seen.
var land_k: int = -1000
var cells: Array[Dictionary] = []
var union: Array[Dictionary] = []
var cut_ks: Array[int] = []
var shown_ks: Array[int] = []
## Swing frames whose blade only the strip cell's pixels draw (no geometry to read).
var pixel_ks: Array[int] = []
var land_ks: Array[int] = []
var _drawn_ks: Array[int] = []
var _struck_k: int = -1
var _land_k: int = -1


func _init(single: bool) -> void:
	if single:
		plan.append({"kind": "ring", "angle_deg": 0.0, "dist_m": 1.4})
	else:
		for d: float in DISTS:
			for a: int in ANGLES:
				plan.append({"kind": "ring", "angle_deg": a * 360.0 / ANGLES, "dist_m": d})
		for dir: int in [1, -1]:
			for lag: int in LAGS:
				plan.append({"kind": "mover", "lag": lag, "dir": dir})
	_reset()


func done() -> bool:
	return i >= plan.size()


## The dummy's offset from Rivet's start (m) at tick k of the current trial.
func at(k: int) -> Vector2:
	var p: Dictionary = plan[i]
	if p["kind"] == "ring":
		var deg: float = p["angle_deg"]
		var dist: float = p["dist_m"]
		return Vector2.from_angle(deg_to_rad(deg)) * dist
	var lag: int = p["lag"]
	var dir: float = p["dir"]
	var ticks: int = maxi(land_k, 0) + lag - k
	return Vector2(MOVER_X, dir * SPEED * SimClock.TICK_DT * ticks)


## The current trial's first hit-test tick (-1 before it).
func land_now() -> int:
	return _land_k


func landed(k: int) -> void:
	if _land_k < 0:
		_land_k = k
	if i == 0:
		land_ks.append(k)


func struck(k: int) -> void:
	if _struck_k < 0:
		_struck_k = k


func frame(k: int, f: Dictionary, origin: Vector2, touch: bool, cutting: bool) -> void:
	if touch:
		_drawn_ks.append(k)
	if i != 0:
		return
	if cutting:
		cut_ks.append(k)
	var source: String = f["source"]
	var blade: PackedVector2Array = f["blade"]
	var crescent: PackedVector2Array = f["crescent"]
	if source == "pixels":
		pixel_ks.append(k)
	elif source != "" or not crescent.is_empty():
		shown_ks.append(k)
		union.append({"blade": _rel(blade, origin), "crescent": _rel(crescent, origin)})


func close(radius_m: float) -> void:
	var cell: Dictionary = plan[i].duplicate()
	cell.merge({"drawn": not _drawn_ks.is_empty(), "hit": _struck_k >= 0})
	cell.merge({"drawn_ks": _drawn_ks.duplicate(), "struck_k": _struck_k, "land_k": _land_k})
	cell["radius_m"] = radius_m
	if land_k < 0 and _land_k >= 0:
		land_k = _land_k
	cells.append(cell)
	i += 1
	_reset()


func result(weapon: StringName, table: MeleeTable) -> Dictionary:
	var ring: Array[Dictionary] = []
	var movers: Array[Dictionary] = []
	var touched: Dictionary = {}
	for c: Dictionary in cells:
		(ring if c["kind"] == "ring" else movers).append(c)
		var ks: Array = c["drawn_ks"]
		for k: int in ks:
			touched[k] = true
	var overlap_ks: Array = touched.keys()
	overlap_ks.sort()
	var h: MeleeHit = table.hits[0]
	var out: Dictionary = {"schema": "gtai.blade-volume/1", "weapon": weapon, "weapon_id": table.id}
	out.merge({"reach_m": h.reach_m, "cone_dot": h.cone_dot, "windup": h.windup})
	out.merge({"active": h.active, "recovery": h.recovery, "land_k": land_k, "land_ks": land_ks})
	out.merge({"cut_ks": cut_ks, "shown_ks": shown_ks, "overlap_ks": overlap_ks})
	out["pixel_ks"] = pixel_ks
	out.merge({"ring": BladeGeom.compare(ring), "cells": ring, "movers": movers})
	return out


func _rel(pts: PackedVector2Array, origin: Vector2) -> Array:
	var out: Array = []
	for p: Vector2 in pts:
		out.append([snappedf(p.x - origin.x, 0.001), snappedf(p.y - origin.y, 0.001)])
	return out


func _reset() -> void:
	_drawn_ks = []
	_struck_k = -1
	_land_k = -1
