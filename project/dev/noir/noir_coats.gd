class_name NoirCoats
extends RefCounted
## Dev (lane noir): a long-coat tail on the showcase's cop rigs, as render-only secondary motion.
## The tail hangs from the torso's back (under the torso and its halo, with its own halo rim)
## and swings on a damped spring driven by the rig's own motion: sideways velocity and turning
## swing it, speed stretches it out behind, a hit kicks it. Stepped on the fixed tick only
## (SimClock.TICK_DT), reads rig state, writes nothing back. The art is one noir part.

const TEX: String = "res://features/characters/art/noir/cop/coat_tail.png"
## Where the tail hangs from, in torso part px (the torso faces +x; the back is -x).
const PIVOT_PART: Vector2 = Vector2(-50.0, 0.0)
const SPRING: float = 70.0
const DAMP: float = 7.0
const SWING: float = 0.006
const TURN: float = 0.05
const KICK: float = 0.004
const MAX_ANGLE: float = 0.7

var _coats: Dictionary[int, Sprite2D] = {}
var _ang: Dictionary[int, float] = {}
var _vel: Dictionary[int, float] = {}
var _tex: Texture2D = null


## One fixed tick for every listed rig that has a full body right now.
func step(rigs: CharacterRigs, ids: PackedInt32Array) -> void:
	for id: int in ids:
		var rig: CutRig = rigs.rig_for(id)
		if rig == null:
			continue
		var coat: Sprite2D = _coats.get(id, null)
		if coat == null or not is_instance_valid(coat) or coat.get_parent() != rig.torso:
			coat = _attach(rig)
			_coats[id] = coat
			_ang[id] = 0.0
			_vel[id] = 0.0
		_swing(id, rig, coat)


func _attach(rig: CutRig) -> Sprite2D:
	if _tex == null:
		_tex = load(TEX) as Texture2D
	var coat: Sprite2D = _sprite(rig.torso_spr.material, -2)
	var halo: Sprite2D = _sprite(PartMaterials.get_mat(PartMaterials.PartKind.HALO, false, 0), -1)
	coat.position = rig.torso_spr.position + PIVOT_PART
	rig.torso.add_child(coat)
	coat.add_child(halo)
	return coat


func _sprite(mat: Material, z: int) -> Sprite2D:
	var s: Sprite2D = Sprite2D.new()
	s.texture = _tex
	s.centered = false
	var size: Vector2 = _tex.get_size()
	s.offset = Vector2(-size.x, -size.y * 0.5)
	s.material = mat
	s.z_index = z
	return s


func _swing(id: int, rig: CutRig, coat: Sprite2D) -> void:
	var dt: float = SimClock.TICK_DT
	var v: Vector2 = rig.vel_in.rotated(-rig.facing)
	var kick: float = rig.shove_v.rotated(-rig.facing).y * KICK
	var target: float = -v.y * SWING - rig.face_w * TURN - kick
	if rig.clips.death_t >= 0.0:
		target = 0.0
	target = clampf(target, -MAX_ANGLE, MAX_ANGLE)
	_vel[id] += ((target - _ang[id]) * SPRING - _vel[id] * DAMP) * dt
	_ang[id] = clampf(_ang[id] + _vel[id] * dt, -MAX_ANGLE, MAX_ANGLE)
	coat.rotation = _ang[id]
	var run: float = clampf(rig.vel_in.length() / CutRig.RUN_SPEED, 0.0, 1.0)
	coat.scale = Vector2(0.85 + 0.3 * run, 1.0)
