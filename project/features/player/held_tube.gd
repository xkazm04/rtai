class_name HeldTube
extends RefCounted
## rivet-arsenal: a tube weapon (rocket launcher, mini-nuke) is drawn empty from the shot until
## the next rocket goes in. weapon-art's `empty` part (the tube with the warhead cut away, same
## canvas and grip) replaces the loaded art while the magazine is spent and the reload has not
## reached phase 2 (out 0..1, in 1..2, cock 2..3: RivetMagView's rocket rides the claw through
## phase 1 and is in the tube at 2). Render only; reads the trigger, writes nothing to the sim.

## The phase at which the new rocket sits in the tube.
const LOADED_AT: float = 2.0


## True when the tube shows no warhead: a spent magazine before the reload's load phase ends.
static func is_empty(ammo: int, magazine: int, reload_k: float) -> bool:
	if magazine <= 0:
		return false
	if reload_k >= 0.0:
		return reload_k < LOADED_AT
	return ammo <= 0


## Puts the empty or loaded art on the held sprite (and on its paper rim copies). No-op for a
## weapon without an `empty` part.
static func apply(sprite: Sprite2D, art: WeaponArt, id: StringName, empty: bool) -> void:
	var hollow: Texture2D = art.part_texture(id, "empty")
	if sprite == null or hollow == null:
		return
	var tex: Texture2D = hollow if empty else art.held_texture(id)
	if sprite.texture == tex:
		return
	sprite.texture = tex
	for child: Node in sprite.get_children():
		if child is Sprite2D:
			(child as Sprite2D).texture = tex
