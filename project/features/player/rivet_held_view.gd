class_name RivetHeldView
extends Node2D
## rivet-arsenal: the weapon in Rivet's claw on the live rig (render only). Each frame, after
## CharacterRigs posed him, the held part (weapon-art's WeaponArt.make_held: origin on the grip,
## +x along the barrel) sits on the gun claw's closing point along the claw, and the claw cell
## switches from the drawn-in pistol to the closed claw. Hidden while the gun is away (a claw
## hit, a roll, a stow past halfway; a thrown bottle from its release until the next one comes
## up at reload phase 1). Reads StagePilot.hold; writes nothing to the sim.

## A melee weapon's blade sweeps either side of the aim line during a swing by the hit's own arc
## (acos of its cone_dot: the katana's slash 1.27 rad, its thrust 0.72, the plasma spin a full
## turn), never less than SWEEP_MIN; the combo's hits alternate the side.
const SWEEP_MIN: float = 0.35
## The chainsaw's grind: the blade judders this far (radians) while the bite holds.
const GRIND_JUDDER: float = 0.07
## Where the claw closes along the claw cell (weapon-art's lineup measured it).
const GRIP_U: float = 0.62
## Grip classes whose reload is not a magazine (the molotov's next bottle, the flamer's tank).
const NO_MAG: Array[StringName] = [&"thrown", &"backpack_hose", &"hip_belt"]
## Grip classes with a part on Rivet's back (weapon-art's `tank`): the flamer's tank, the
## gatling's belt box (n5-look); the line from it to the weapon is the hose or the belt.
const ON_BACK: Array[StringName] = [&"backpack_hose", &"hip_belt"]
## The flamethrower's tank rides this far behind the torso's centre (m), across the shoulders.
const TANK_BACK_M: float = 0.22
## The flamer's reload is a tank swap (the gatling's box too): the spent tank slides this far
## back off him and fades a little (reload phase 0), the fresh one slides in (phase 1); the hose
## follows the tank.
const TANK_SWAP_M: float = 0.45
const HOSE_POINTS: int = 8

var rigs: CharacterRigs = null
var pilot: StagePilot = null
## The fight whose GunHand reloads (null: no reload pantomime).
var arena: CombatArena = null
var rivet_id: int = 0
var art: WeaponArt = WeaponArt.new()
var arsenal: ArsenalTable = ArsenalTable.shipped()
var _shown: StringName = &""
var _shown_size: float = 0.0
var _sprite: Sprite2D = null
var _sweep_arc: float = 1.2
var _mag: RivetMagView = null
var _tank: Sprite2D = null
## The tank's hose to the wand: an ink line with a cream core.
var _hose: Array[Line2D] = []
var _hose_belt: bool = false
var _rag: RagLight = null
var _carry: RivetCarryAngle = RivetCarryAngle.new()
var _smear: MeleeSmearView = null


func _ready() -> void:
	process_priority = 10  # after CharacterRigs poses this frame
	warm()


## perf-city: loads the art of every gun Rivet carries now, behind the load. WeaponArt loads a
## texture from disk on its first use, so the first draw of a gun mid-fight cost an 8-19 ms
## frame. The same calls as _swap and the reload views make, so the sprites and pixels are the same.
func warm() -> void:
	if pilot == null or pilot.carry == null:
		return
	for weapon: StringName in pilot.carry.slots:
		var id: StringName = arsenal.art_id(weapon) if weapon != &"" else &""
		if art.has(id):
			art.make_held(id).free()
			for part: String in ["mag", "tank"]:
				@warning_ignore("return_value_discarded")
				art.part_texture(id, part)


func _process(_delta: float) -> void:
	var rig: CutRig = rigs.rig_for(rivet_id) if rigs != null else null
	var id: StringName = arsenal.art_id(pilot.hold.held) if pilot != null else &""
	if rig != null and pilot != null:
		var grip: ArsenalTable.Grip = arsenal.grip_of(pilot.hold.held)
		var hold: HeldTable.Hold = HeldTable.shipped().hold_of(pilot.hold.held)
		rig.hold = hold.id if hold != null else &""
		rig.grip = hold.kind if hold != null else RigGrip.Kind.ONE_HAND
		rig.reload_k = arsenal.reload_phase(arena.gun if arena != null else null)
		var mag: bool = grip != null and not NO_MAG.has(grip.id)  # a bottle or a tank: no magazine
		mag = mag and not (art.has(id) and art.part_texture(id, "mag") != null)  # weapon-art's own
		var now: int = arena.tick if arena != null else 0
		_mag_view().feed(rig, rig.reload_k if mag else -1.0, now, id)
		_back_tank(rig, grip != null and ON_BACK.has(grip.id))
	if rig == null or not rig.gun_out or not art.has(id):
		if _sprite != null:
			_sprite.visible = false
		if _rag != null:
			_rag.visible = false
		return
	if id != _shown or rig.plan.size_k != _shown_size:
		_swap(id, pilot.hold.held, rig.plan.size_k)
	if arena != null and arena.gun != null and arena.gun.trigger.spec.id == pilot.hold.held:
		var t: Trigger = arena.gun.trigger
		HeldTube.apply(_sprite, art, id, HeldTube.is_empty(t.ammo, t.spec.magazine, rig.reload_k))
	rig.plan.hand_pistol = rig.plan.hand_closed
	var hand: Sprite2D = rig.sides[rig.plan.gun_arm].hand
	var tex: Vector2 = hand.texture.get_size()
	var local: Vector2 = Vector2(tex.x * GRIP_U, tex.y * 0.5) + hand.offset
	_sprite.global_position = hand.global_transform * local
	_sprite.global_rotation = _held_angle(rig, hand)
	_place_long(rig)
	_pose_melee(rig)
	_feed_smear(rig)
	_sprite.visible = rig.grip != RigGrip.Kind.THROWN or rig.reload_k < 0.0 or rig.reload_k >= 1.0
	_light_rag(rig, id)


func _swap(id: StringName, weapon: StringName, size_k: float) -> void:
	if _sprite != null:
		_sprite.queue_free()
	_sprite = art.make_held(id)
	_sprite.scale *= arsenal.held_k(weapon, size_k)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_sprite.material = PartMaterials.get_mat(PartMaterials.PartKind.PART, false, 0)
	add_child(_sprite)
	_shown = id
	_shown_size = size_k


## The held weapon's angle: along the claw; a two-claw weapon's barrel on the aim line; a blade
## on the guard's line, turned in at the wrist (d7-held).
func _held_angle(rig: CutRig, hand: Sprite2D) -> float:
	if rig.grip == RigGrip.Kind.BLADE:
		return RigGrip.blade_angle(rig)
	if rig.aiming and rig.grip != RigGrip.Kind.ONE_HAND:
		return (rig.aim_at - _sprite.global_position).angle()
	return hand.global_rotation


## A long gun or a tube: carried across the front of the body, and always beside the helmet.
func _place_long(rig: CutRig) -> void:
	var across: bool = RivetCarryAngle.applies(rig.grip) and not rig.aiming and not pilot.wielding()
	var fwd: Vector2 = rig.torso.global_transform.x.normalized()
	var g: Vector2 = _sprite.global_position
	_sprite.global_rotation += _carry.step(
		across, fwd, g, rig.torso.global_position, _sprite.global_rotation
	)
	if RivetCarryAngle.applies(rig.grip) and not pilot.wielding():
		_sprite.global_position += _beside(rig)


## The shift that puts a long gun or a tube beside Rivet's helmet (RivetCarryAngle.beside_head).
func _beside(rig: CutRig) -> Vector2:
	var head: Sprite2D = rig.head_spr
	var head_half: float = head.texture.get_width() * absf(head.global_scale.x) * 0.5
	var gun_half: float = _sprite.texture.get_height() * absf(_sprite.global_scale.y) * 0.5
	var at: Vector2 = _sprite.global_position
	var rot: float = _sprite.global_rotation
	return RivetCarryAngle.beside_head(at, rot, head.global_position, head_half, gun_half)


## The blade's angle off the aim line during a strike (MeleeSwing: anticipation, the cut,
## the follow-through; combat-notes); the combo's hits alternate the side.
func _sweep(clips: RigClips) -> float:
	var side: float = 1.0 if pilot.melee.combo.last_index % 2 == 1 else -1.0
	return MeleeSwing.angle(clips.strike_t, clips.strike_ph, side, _sweep_arc)


## A melee weapon's pose this frame: the chainsaw's bite, a strike's swing, the idle judder.
func _pose_melee(rig: CutRig) -> void:
	if pilot.wielding() and pilot.melee.combo.ground > 0:
		_grind(rig)
	elif pilot.wielding() and rig.clips.strike_t >= 0.0:
		_sweep_arc = _arc()
		_sprite.global_rotation += _sweep(rig.clips)
	elif pilot.hold.held == &"chainsaw" and arena != null:  # combat-notes: the engine runs
		var j: Vector2 = MeleeSwing.idle_judder(arena.tick)
		_sprite.global_rotation += j.x
		_sprite.global_position += Vector2.from_angle(_sprite.global_rotation + PI * 0.5) * j.y


## combat-notes: the cut's smear under the blade (MeleeSmearView), fed every shown frame.
func _feed_smear(rig: CutRig) -> void:
	if _smear == null:
		_smear = MeleeSmearView.new()
		add_child(_smear)
	move_child(_smear, 0)  # under the held weapon
	var t: float = rig.clips.strike_t
	var on: bool = pilot.wielding() and pilot.melee.combo.ground == 0 and t >= 0.0
	on = on and MeleeSwing.cutting(t, rig.clips.strike_ph)
	_smear.tint = MeleeSmearView.tint_of(pilot.hold.held)
	var len_px: float = _sprite.get_rect().end.x * absf(_sprite.global_scale.x)
	_smear.feed(_sprite.global_position, _sprite.global_rotation, len_px, on)


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


func _mag_view() -> RivetMagView:
	if _mag == null:
		_mag = RivetMagView.new()
		add_child(_mag)
	return _mag


## weapon-art's `tank` part on Rivet's back while a backpack weapon (the flamethrower) is carried in
## the claw: across the shoulders, TANK_BACK_M behind the torso, turning with it.
func _back_tank(rig: CutRig, on: bool) -> void:
	var id: StringName = arsenal.art_id(pilot.hold.held)
	if on and _tank == null:
		var tex: Texture2D = art.part_texture(id, "tank") if art.has(id) else null
		if tex == null:
			return
		_tank = Sprite2D.new()
		_tank.texture = tex
		_tank.scale = Vector2.ONE * art.world_scale(id)
		_tank.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		_tank.material = PartMaterials.get_mat(PartMaterials.PartKind.PART, false, 0)
		add_child(_tank)
	if _tank == null:
		return
	_tank.visible = on
	for line: Line2D in _hose:
		line.visible = on and _sprite != null and _sprite.visible
	if on:
		var fwd: Vector2 = rig.torso.global_transform.x.normalized()
		var k: float = rig.reload_k
		var swap: float = clampf(k if k < 1.0 else 2.0 - k, 0.0, 1.0) if k >= 0.0 else 0.0
		_tank.modulate.a = 1.0 - 0.25 * swap
		var back_px: float = (TANK_BACK_M + TANK_SWAP_M * swap) * WeaponArt.WORLD_PX_PER_M
		_tank.global_position = rig.torso.global_position - fwd * back_px
		_tank.global_rotation = fwd.angle() + PI * 0.5
		if _sprite != null and _sprite.visible:
			_route_hose(fwd)


## The hose leaves the tank's end nearest the wand, curves out past the body and meets the grip.
func _route_hose(fwd: Vector2) -> void:
	var belt: bool = arsenal.grip_of(pilot.hold.held).id == &"hip_belt"
	if _hose.is_empty() or belt != _hose_belt:
		for line: Line2D in _hose:
			line.queue_free()
		_hose = HeldFeedLine.make(self, belt)  # the flamer's hose or the gatling's belt
		_hose_belt = belt
	var side: Vector2 = fwd.orthogonal() * _tank.texture.get_width() * _tank.scale.x * 0.45
	var to: Vector2 = _sprite.global_position
	var from: Vector2 = _tank.global_position + side
	if (_tank.global_position - side).distance_to(to) < from.distance_to(to):
		from = _tank.global_position - side
	var mid: Vector2 = (from + to) * 0.5
	var out: Vector2 = (mid - _tank.global_position - fwd * side.length()).normalized()
	var sag: Vector2 = mid + out * side.length() * 0.7
	var pts: PackedVector2Array = PackedVector2Array()
	for k: int in HOSE_POINTS:
		var t: float = float(k) / float(HOSE_POINTS - 1)
		@warning_ignore("return_value_discarded")
		pts.append(to_local(from.lerp(sag, t).lerp(sag.lerp(to, t), t)))
	for line: Line2D in _hose:
		line.points = pts


## The molotov's draw lights the rag at the bottle's muzzle point (RagLight), and so does each
## next bottle as it comes up after a throw (reload phase 1); hidden otherwise.
func _light_rag(rig: CutRig, id: StringName) -> void:
	var k: float = -1.0
	if rig.grip == RigGrip.Kind.THROWN and pilot.hold.state == WeaponHold.State.DRAWING:
		k = pilot.hold.progress()
	elif rig.grip == RigGrip.Kind.THROWN and rig.reload_k >= 1.0 and rig.reload_k < 2.0:
		k = rig.reload_k - 1.0
	if _rag == null:
		_rag = RagLight.new()
		_rag.z_index = 2
		add_child(_rag)
	_rag.visible = k >= 0.0 and _sprite.visible
	if _rag.visible:
		var at: Vector2 = _sprite.to_global(art.muzzle_px(id) + _sprite.offset)
		_rag.light(at, k, Engine.get_process_frames())
