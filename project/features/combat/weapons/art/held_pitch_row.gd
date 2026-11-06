class_name HeldPitchRow
extends RefCounted
## d8-weapons: one weapon's raised-camera held part (weapon_held_pitch.json, read by HeldPitchArt).

var art: String = ""
var grip: Vector2 = Vector2.ZERO
var muzzle: Vector2 = Vector2.ZERO
var length_px: float = 1.0
## Draw size against weapon_art length_m (the side body adds the grip's height, so a
## three-quarter pistol at full length reads bigger than the top-down one).
var size_k: float = 1.0
## The part re-toned for gameplay scale (same canvas), drawn below held_small_below_ppm.
var small: String = ""
## A tube's empty part (warhead cut away) and its small cell, same canvas (HeldTube).
var empty: String = ""
var empty_small: String = ""


static func from_row(t: DataTable, w: Dictionary) -> HeldPitchRow:
	var r: HeldPitchRow = HeldPitchRow.new()
	r.art = t.text(w, "art")
	r.grip = t.vec(w, "grip_px")
	r.muzzle = t.vec(w, "muzzle_px")
	r.length_px = maxf(t.num(w, "length_px"), 1.0)
	r.size_k = t.num(w, "size_k") if w.has("size_k") else 1.0
	r.small = _opt(t, w, "small")
	r.empty = _opt(t, w, "empty")
	r.empty_small = _opt(t, w, "empty_small")
	return r


static func _opt(t: DataTable, w: Dictionary, key: String) -> String:
	return t.text(w, key) if w.has(key) else ""
