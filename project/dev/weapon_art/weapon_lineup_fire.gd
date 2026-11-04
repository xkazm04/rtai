class_name WeaponLineupFire
extends RefCounted
## Weapon-art lineup, the firing beat (dev): puts each weapon's muzzle-flash frames on its muzzle
## and its projectile cell ahead of the muzzle, as children of the held sprite, so the FX art
## shows where gunplay will spawn it (WeaponArt.muzzle_px / fx_anchor). FX cells are authored in
## rig part px (320 per m), the held part in its own art px, hence the scale conversion.

const FX_WORLD_SCALE: float = 0.2  # 2x the part scale (32 world px per m / 320 part px per m = 0.1)
const AHEAD_M: float = 1.4


## Adds the flash (cycling frames) and the projectile to `held`; returns the flash sprite or null.
static func arm(art: WeaponArt, id: StringName, held: Sprite2D) -> Sprite2D:
	var frames: Array[Texture2D] = art.fx_frames(art.muzzle_fx(id))
	if frames.is_empty():
		return null
	var ws: float = art.world_scale(id)
	var at: Vector2 = art.muzzle_px(id) - art.grip_px(id)
	var flash: Sprite2D = _cell(frames[0], art.fx_anchor(art.muzzle_fx(id)), ws)
	flash.position = at
	flash.set_meta(&"frames", frames)
	held.add_child(flash)
	var shots: Array[Texture2D] = art.fx_frames(art.projectile_fx(id))
	if not shots.is_empty() and art.projectile_fx(id) != art.muzzle_fx(id):
		var shot: Sprite2D = _cell(shots[0], art.fx_anchor(art.projectile_fx(id)), ws)
		shot.position = at + Vector2(AHEAD_M * WeaponArt.WORLD_PX_PER_M / ws, 0.0)
		held.add_child(shot)
	return flash


## Steps the flash through its frames, 3 ticks each.
static func tick(flash: Sprite2D, t: int) -> void:
	if flash == null:
		return
	var frames: Array = flash.get_meta(&"frames", [])
	if not frames.is_empty():
		flash.texture = frames[(t / 3) % frames.size()]


static func _cell(tex: Texture2D, anchor: Vector2, held_scale: float) -> Sprite2D:
	var s: Sprite2D = Sprite2D.new()
	s.texture = tex
	s.centered = false
	s.offset = -anchor
	s.scale = Vector2.ONE * FX_WORLD_SCALE / maxf(held_scale, 0.0001)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return s
