class_name HeldLod
extends Sprite2D
## A held part that draws its `small` cell (weapon_art.json parts.small: the part re-toned for
## gameplay scale) while the parts print small, and its full art from `below_view_px` up. Reads
## PartMaterials.view_px (the screen px per rig part px the print shader uses, set once a frame by
## CharacterRigs), so the swap follows the same zoom as the print's posterize. The rim sprites
## (WeaponArt's paper halo, children named Rim*) swap with it. Render only.

## `--held-small=off` keeps the full art at every zoom (same-tick A/B evidence).
static var enabled: bool = not OS.get_cmdline_user_args().has("--held-small=off")

var full: Texture2D = null
var small: Texture2D = null
var below_view_px: float = 0.0


func _ready() -> void:
	_pick()


func _process(_delta: float) -> void:
	_pick()


func is_small() -> bool:
	return enabled and small != null and PartMaterials.view_px < below_view_px


func _pick() -> void:
	var tex: Texture2D = small if is_small() else full
	if tex == texture or tex == null:
		return
	texture = tex
	for child: Node in get_children():
		if child is Sprite2D and String(child.name).begins_with("Rim"):
			(child as Sprite2D).texture = tex
