class_name RivetHeldView
extends Node2D
## rivet-arsenal: the weapon in Rivet's claw on the live rig (render only). Each frame, after
## CharacterRigs posed him, the held part (weapon-art's WeaponArt.make_held: origin on the grip,
## +x along the barrel) sits on the gun claw's closing point along the claw, and the claw cell
## switches from the drawn-in pistol to the closed claw. Hidden while the gun is away (a claw
## hit, a roll, a stow past halfway). Reads StagePilot.hold; writes nothing to the sim.

## A melee weapon's blade sweeps either side of the aim line during a swing by the hit's own arc
## (acos of its cone_dot: the katana's slash 1.27 rad, its thrust 0.72, the plasma spin a full
## turn), never less than SWEEP_MIN; the combo's hits alternate the side.
const SWEEP_MIN: float = 0.35
## The chainsaw's grind: the blade judders this far (radians) while the bite holds.
const GRIND_JUDDER: float = 0.07
## Where the claw closes along the claw cell (weapon-art's lineup measured it).
const GRIP_U: float = 0.62

var rigs: CharacterRigs = null
var pilot: StagePilot = null
## The fight whose GunHand reloads (null: no reload pantomime).
var arena: CombatArena = null
var rivet_id: int = 0
var art: WeaponArt = WeaponArt.new()
var arsenal: ArsenalTable = ArsenalTable.shipped()
var _shown: StringName = &""
var _sprite: Sprite2D = null
var _sweep_arc: float = 1.2


func _ready() -> void:
	process_priority = 10  # after CharacterRigs poses this frame


func _process(_delta: float) -> void:
	var rig: CutRig = rigs.rig_for(rivet_id) if rigs != null else null
	var id: StringName = arsenal.art_id(pilot.hold.held) if pilot != null else &""
	if rig != null and pilot != null:
		var grip: ArsenalTable.Grip = arsenal.grip_of(pilot.hold.held)
		rig.grip = RigGrip.kind_of(grip.id) if grip != null else RigGrip.Kind.ONE_HAND
		rig.reload_k = _reload_k()
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
	if pilot.wielding() and pilot.melee.combo.ground > 0:
		_grind(rig)
	elif pilot.wielding() and rig.clips.strike_t >= 0.0:
		_sweep_arc = _arc()
		_sprite.global_rotation += _sweep(rig.clips)
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


## The gun's reload as the rig's phase + fraction (rivet_arsenal.json out/in/cock), or -1.
func _reload_k() -> float:
	var gun: GunHand = arena.gun if arena != null else null
	if gun == null or not gun.trigger.reloading() or gun.trigger.spec.reload_ticks <= 0:
		return -1.0
	var t: float = 1.0 - float(gun.trigger.reload_left) / float(gun.trigger.spec.reload_ticks)
	if t < arsenal.out_k:
		return t / arsenal.out_k
	t -= arsenal.out_k
	if t < arsenal.in_k:
		return 1.0 + t / arsenal.in_k
	return 2.0 + minf((t - arsenal.in_k) / maxf(arsenal.cock_k, 0.001), 0.999)


## The blade's angle off the aim line during a strike: wound back to one side over the windup,
## across to the other through the active ticks, easing back over the recovery.
func _sweep(clips: RigClips) -> float:
	var ph: Vector3 = clips.strike_ph
	var t: float = clips.strike_t
	var side: float = 1.0 if pilot.melee.combo.last_index % 2 == 1 else -1.0
	var arc: float = _sweep_arc
	if t < ph.x:
		return side * arc * smoothstep(0.0, 1.0, t / maxf(ph.x, 0.001))
	if t < ph.x + ph.y:
		var k: float = (t - ph.x) / maxf(ph.y, 0.001)
		return side * arc * (1.0 - 2.0 * k)
	var r: float = (t - ph.x - ph.y) / maxf(ph.z, 0.001)
	return -side * arc * (1.0 - smoothstep(0.0, 1.0, r))


## The current (or just ended) hit's sweep half-angle from its cone.
func _arc() -> float:
	var c: MeleeCombo = pilot.melee.combo
	var h: MeleeHit = c.current()
	if h == null and c.last_index > 0 and c.last_index <= c.table.hits.size():
		h = c.table.hits[c.last_index - 1]
	return maxf(SWEEP_MIN, acos(clampf(h.cone_dot, -1.0, 1.0))) if h != null else _sweep_arc


## The chainsaw's held bite: the arm stays at full reach (the strike clip parked at the end of its
## active phase) and the blade judders on the aim line, a tick-locked three-step shake.
func _grind(rig: CutRig) -> void:
	var ph: Vector3 = rig.clips.strike_ph
	if rig.clips.strike_t >= 0.0:
		rig.clips.strike_t = ph.x + ph.y * 0.95
	var step3: int = pilot.melee.combo.ground % 3 - 1
	_sprite.global_rotation += GRIND_JUDDER * float(step3)
	_sprite.global_position += Vector2.from_angle(_sprite.global_rotation + PI * 0.5) * float(step3)
