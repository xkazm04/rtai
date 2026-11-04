class_name RivetHeldView
extends Node2D
## rivet-arsenal: the weapon in Rivet's claw on the live rig (render only). Each frame, after
## CharacterRigs posed him, the held part (weapon-art's WeaponArt.make_held: origin on the grip,
## +x along the barrel) sits on the gun claw's closing point along the claw, and the claw cell
## switches from the drawn-in pistol to the closed claw. Hidden while the gun is away (a claw
## hit, a roll, a stow past halfway). Reads StagePilot.hold; writes nothing to the sim.

## Where the claw closes along the claw cell (weapon-art's lineup measured it).
const GRIP_U: float = 0.62

var rigs: CharacterRigs = null
var pilot: StagePilot = null
var rivet_id: int = 0
var art: WeaponArt = WeaponArt.new()
var arsenal: ArsenalTable = ArsenalTable.shipped()
var _shown: StringName = &""
var _sprite: Sprite2D = null


func _ready() -> void:
	process_priority = 10  # after CharacterRigs poses this frame


func _process(_delta: float) -> void:
	var rig: CutRig = rigs.rig_for(rivet_id) if rigs != null else null
	var id: StringName = arsenal.art_id(pilot.hold.held) if pilot != null else &""
	if rig != null and pilot != null:
		var grip: ArsenalTable.Grip = arsenal.grip_of(pilot.hold.held)
		rig.grip = RigGrip.kind_of(grip.id) if grip != null else RigGrip.Kind.ONE_HAND
	if rig == null or not rig.gun_out or not art.has(id):
		if _sprite != null:
			_sprite.visible = false
		return
	if id != _shown:
		_swap(id, pilot.hold.held)
	rig.plan.hand_pistol = rig.plan.hand_closed
	var hand: Sprite2D = rig.sides[rig.plan.gun_arm].hand
	var tex: Vector2 = hand.texture.get_size()
	var local: Vector2 = Vector2(tex.x * GRIP_U, tex.y * 0.5) + hand.offset
	_sprite.global_position = hand.global_transform * local
	_sprite.global_rotation = hand.global_rotation
	if rig.aiming and rig.grip != RigGrip.Kind.ONE_HAND:  # the barrel on the aim line
		_sprite.global_rotation = (rig.aim_at - _sprite.global_position).angle()
	_sprite.visible = true


func _swap(id: StringName, weapon: StringName) -> void:
	if _sprite != null:
		_sprite.queue_free()
	_sprite = art.make_held(id)
	var grip: ArsenalTable.Grip = arsenal.grip_of(weapon)
	_sprite.scale *= grip.held_scale if grip != null else 1.0
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_sprite.material = PartMaterials.get_mat(PartMaterials.PartKind.PART, false, 0)
	add_child(_sprite)
	_shown = id
