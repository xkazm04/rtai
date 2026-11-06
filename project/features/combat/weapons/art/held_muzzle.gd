class_name HeldMuzzle
extends RefCounted
## n7-ranged (it11): where Rivet's drawn barrel ends, this frame. RivetHeldView publishes the held
## sprite's bore tip (WeaponArt.muzzle_px) each process frame; WeaponFxArt.muzzle and
## WeaponFxSpin.tip print the flash and the whirl there, so they follow whatever hold the owner
## picks (one hand, two-hand long, shoulder, hip) instead of a fixed spot beside the aim line.
## The held view sits on the rigs' CanvasLayer and the FX on the print stage's, so the point is
## kept in canvas (viewport) px and turned into the drawing item's space on read.
## Stale (no held view this frame: quest 1's cast rig, a hidden gun) or `--flash-at=side` = the
## caller's fallback, the GUN_SIDE_M spot (the before). View only: reads nodes, writes no sim.

static var on: bool = not OS.get_cmdline_user_args().has("--flash-at=side")
static var _canvas_px: Vector2 = Vector2.ZERO
static var _frame: int = -1


## The held `sprite`'s point `local_px` (sprite space, offset included) is the muzzle this frame.
static func publish(sprite: Sprite2D, local_px: Vector2) -> void:
	if sprite == null or not sprite.is_visible_in_tree():
		return
	_canvas_px = sprite.get_global_transform_with_canvas() * local_px
	_frame = Engine.get_process_frames()


## The muzzle in `ci`'s metres (Ink.px space) if published this frame, else `fallback`.
static func at_m(ci: CanvasItem, fallback: Vector2) -> Vector2:
	if not fresh() or ci == null or not ci.is_inside_tree():
		return fallback
	var local: Vector2 = ci.get_global_transform_with_canvas().affine_inverse() * _canvas_px
	return local / Ink.PX_PER_M


## True while a point was published in this process frame (and the flag is on).
static func fresh() -> bool:
	return on and _frame == Engine.get_process_frames()


## Forget the point (a test).
static func reset() -> void:
	_frame = -1
	_canvas_px = Vector2.ZERO
