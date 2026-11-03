class_name D5HeroGround
extends RefCounted
## d5-close hero scene: the D5 road tiles' original bold cracks as a world-locked
## overlay that fades in with the zoom (0 at FADE_ON px/m, full at FADE_FULL).
## The thinned cracks of the D5 tiles vanish at 32-48 px/m like the mock's clean
## street; the grime comes back up close (the 96-128 px/m kill-cam). Overlays:
## features/city/art/d5/ground/<tile>_cracks.png (masters tools/build_cracks.py).
## A proposal for the city lane; dev evidence only.

const D5_GROUND: String = "res://features/city/art/d5/ground/"
const FADE_ON: float = 56.0
const FADE_FULL: float = 96.0


## One hidden overlay child per ground tile sprite that has a <tile>_cracks.png; returns them.
static func overlays(world: Node) -> Array[Sprite2D]:
	var out: Array[Sprite2D] = []
	for n: Node in world.get_children():
		var spr: Sprite2D = n as Sprite2D
		if spr == null or spr.texture == null:
			continue
		var base: String = spr.texture.resource_path.get_file().get_basename()
		var path: String = D5_GROUND + base + "_cracks.png"
		if not ResourceLoader.exists(path):
			continue
		var o: Sprite2D = Sprite2D.new()
		o.texture = load(path) as Texture2D
		o.texture_filter = spr.texture_filter
		o.visible = false
		spr.add_child(o)
		out.append(o)
	return out


## Shows the overlays in the "d5" tier only, alpha from the zoom (screen px per metre).
static func fade(list: Array[Sprite2D], tier: String, ppm: float) -> void:
	var a: float = clampf((ppm - FADE_ON) / (FADE_FULL - FADE_ON), 0.0, 1.0)
	for o: Sprite2D in list:
		o.visible = tier == "d5" and a > 0.0
		o.modulate.a = a
