class_name HeldLod
extends Sprite2D
## A held part that draws its `small` cell (weapon_art.json parts.small: the part re-toned for
## gameplay scale) while the parts print small, and its full art from `below_view_px` up. Reads
## PartMaterials.view_px (the screen px per rig part px the print shader uses, set once a frame by
## CharacterRigs), so the swap follows the same zoom as the print's posterize. The rim sprites
## (WeaponArt's paper halo, children named Rim*) swap with it. Render only.
## A view may set `texture` to any full art in `small_of` (rivet-arsenal's HeldTube puts the empty
## tube on, from a priority-10 parent): this runs after it and maps that art to its small cell.

## `--held-small=off` keeps the full art at every zoom (same-tick A/B evidence).
static var enabled: bool = not OS.get_cmdline_user_args().has("--held-small=off")

var full: Texture2D = null
var small: Texture2D = null
var below_view_px: float = 0.0
## Full art -> its small cell (the held part and, for a tube, the empty one).
var small_of: Dictionary[Texture2D, Texture2D] = {}
var _full_of: Dictionary[Texture2D, Texture2D] = {}


func _ready() -> void:
	process_priority = 20  # after RivetHeldView (10) and anything it swaps in
	_pick()


func _process(_delta: float) -> void:
	_pick()


func is_small() -> bool:
	return enabled and small != null and PartMaterials.view_px < below_view_px


## The full art a view last asked for (the loaded or the empty tube), whatever is drawn now.
func shown_full() -> Texture2D:
	if _full_of.size() != small_of.size():
		_full_of.clear()
		for k: Texture2D in small_of:
			_full_of[small_of[k]] = k
	return _full_of.get(texture, texture) if texture != null else full


func _pick() -> void:
	var base: Texture2D = shown_full()
	var tex: Texture2D = small_of.get(base, base) if is_small() else base
	if tex == texture or tex == null:
		return
	texture = tex
	for child: Node in get_children():
		if child is Sprite2D and String(child.name).begins_with("Rim"):
			(child as Sprite2D).texture = tex
