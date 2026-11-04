class_name WeaponMagView
extends Node2D
## weapon-art (rivet-arsenal REQUEST 8): the reload magazine in Rivet's off claw (render only).
## RivetHeldView writes the rig's reload phase (`reload_k`: 0..1 the old magazine comes out to the
## hip, 1..2 a fresh one goes in, 2..3 the rack). Through 0..2 the gun's `mag` part (WeaponArt
## parts, cut from the gun's own art) rides the off claw, feed end along the claw; when the old one
## reaches the hip it drops and lies on the floor (the last SPENT_KEEP stay, like the brass).
## Guns with no `mag` part (tubes, the flamethrower) show nothing. Writes nothing to the sim.

const GRIP_U: float = 0.62  # where a claw closes along its cell (RivetHeldView.GRIP_U)
## Where the claw closes along a forearm cell that carries its own claw (Rivet's right arm).
const FORE_CLAW_U: float = 0.86
const SPENT_KEEP: int = 8
## The dropped one lands turned a little off the claw's line, so it reads as dropped, not placed.
const SPENT_TURN_RAD: float = 0.7

var rigs: CharacterRigs = null
var pilot: StagePilot = null
var rivet_id: int = 0
var art: WeaponArt = WeaponArt.new()
var arsenal: ArsenalTable = ArsenalTable.shipped()
var _shown: StringName = &""
var _mag: Sprite2D = null
var _last_k: float = -1.0
var _floor: Node2D = Node2D.new()
var _spent: Array[Sprite2D] = []


func _ready() -> void:
	process_priority = 11  # after RivetHeldView wrote this frame's reload_k
	_floor.z_index = -61  # under the rigs (the view itself sits above every rig part)
	add_child(_floor)


func _process(_delta: float) -> void:
	var rig: CutRig = rigs.rig_for(rivet_id) if rigs != null else null
	var weapon: StringName = pilot.hold.held if pilot != null else &""
	var id: StringName = arsenal.art_id(weapon)
	var k: float = rig.reload_k if rig != null and rig.plan.gun_arm >= 0 else -1.0
	if id != _shown:
		_swap(id, weapon)
	if _mag == null or k < 0.0 or k >= 2.0:
		if _mag != null:
			_mag.visible = false
		_last_k = k
		return
	var off: RigLimbs = rig.sides[1 - rig.plan.gun_arm]
	var claw: Sprite2D = off.hand if off.hand != null else off.fore  # Rivet's right: in the fore
	var u: float = GRIP_U if off.hand != null else FORE_CLAW_U
	var tex: Vector2 = claw.texture.get_size()
	_mag.global_position = claw.global_transform * (Vector2(tex.x * u, tex.y * 0.5) + claw.offset)
	_mag.global_rotation = claw.global_rotation
	_mag.visible = true
	if _last_k >= 0.0 and _last_k < 1.0 and k >= 1.0:
		_drop()
	_last_k = k


## The spent magazine left where the off claw let it go.
func _drop() -> void:
	var s: Sprite2D = _mag.duplicate() as Sprite2D
	_floor.add_child(s)
	s.global_position = _mag.global_position
	var side: float = 1.0 if _spent.size() % 2 == 0 else -1.0
	s.global_rotation = _mag.global_rotation + SPENT_TURN_RAD * side
	_spent.append(s)
	if _spent.size() > SPENT_KEEP:
		var old: Sprite2D = _spent.pop_front()
		old.queue_free()


func _swap(id: StringName, weapon: StringName) -> void:
	if _mag != null:
		_mag.queue_free()
	_mag = art.make_held(id, "mag") if art.has(id) else null
	_shown = id
	if _mag == null:
		return
	var grip: ArsenalTable.Grip = arsenal.grip_of(weapon)
	_mag.scale *= grip.held_scale if grip != null else 1.0
	_mag.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_mag.material = PartMaterials.get_mat(PartMaterials.PartKind.PART, false, 0)
	_mag.visible = false
	add_child(_mag)
