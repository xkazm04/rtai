class_name PickupsView
extends Node2D
## rivet-arsenal: the guns on the ground (RivetCarry.ground) in the print: weapon-art's pickup
## side view on a paper disc with an ink ring, slowly turning so it reads as loot, not decor.
## Render only: reads the sim each frame, writes nothing back.

const DISC_M: float = 0.55
const RING_PX: float = 2.0
const TURN_RAD_S: float = 0.6

var carry: RivetCarry = null
var art: WeaponArt = WeaponArt.new()
var _sprites: Array[Sprite2D] = []
var _shown: Array[StringName] = []
var _paper: Color = PaletteTokens.shared().color(&"paper")
var _ink: Color = PaletteTokens.shared().color(&"ink")
var _t: float = 0.0


func _process(_delta: float) -> void:
	_t += SimClock.TICK_DT  # a render frame's turn step (the view runs at the sim's 60 Hz)
	var items: Array[WeaponPickups.Item] = carry.ground.items if carry != null else []
	var ids: Array[StringName] = []
	for it: WeaponPickups.Item in items:
		ids.append(it.id)
	if ids != _shown:
		_rebuild(ids)
	for i: int in items.size():
		_sprites[i].position = items[i].pos * SimConst.PX_PER_M
		_sprites[i].rotation = sin(_t * TURN_RAD_S + i) * 0.5
	queue_redraw()


func _draw() -> void:
	if carry == null:
		return
	var r: float = DISC_M * SimConst.PX_PER_M
	for it: WeaponPickups.Item in carry.ground.items:
		var at: Vector2 = it.pos * SimConst.PX_PER_M
		draw_circle(at, r, _paper)
		draw_arc(at, r, 0.0, TAU, 32, _ink, RING_PX, true)


func _rebuild(ids: Array[StringName]) -> void:
	for s: Sprite2D in _sprites:
		s.queue_free()
	_sprites.clear()
	for id: StringName in ids:
		var s: Sprite2D = Sprite2D.new()
		s.texture = art.pickup_texture(id) if art.has(id) else null
		var w: float = s.texture.get_width() if s.texture != null else 1.0
		s.scale = Vector2.ONE * art.length_m(id) * SimConst.PX_PER_M / maxf(w, 1.0)
		s.material = PartMaterials.get_mat(PartMaterials.PartKind.PART, false, 0)
		add_child(s)
		_sprites.append(s)
	_shown = ids
