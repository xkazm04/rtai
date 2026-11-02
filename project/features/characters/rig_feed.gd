class_name RigFeed
extends RefCounted
## What a host (the city sim's people, the player, a test) hands CharacterRigs each tick: one row
## per person in parallel packed arrays (no per-actor objects, GDS-09). Positions are world px
## (32 px = 1 m on foot). A clip column starts an authored clip on that row this tick.
## look = a RigVariant.crowd() index, or LOOK_AUTO for a stable pick from the actor id.

enum Flag { DEAD = 1, AIMING = 2, GUN_OUT = 4, FLEE = 8 }

const LOOK_AUTO: int = 255

var count: int = 0
var ids: PackedInt32Array = PackedInt32Array()
var kinds: PackedByteArray = PackedByteArray()
var looks: PackedByteArray = PackedByteArray()
var pos: PackedVector2Array = PackedVector2Array()
var vel: PackedVector2Array = PackedVector2Array()
var face: PackedFloat32Array = PackedFloat32Array()
var aim: PackedVector2Array = PackedVector2Array()
var flags: PackedByteArray = PackedByteArray()
var clip: PackedByteArray = PackedByteArray()
var clip_arg: PackedFloat32Array = PackedFloat32Array()


func _init(capacity: int = 0) -> void:
	reserve(capacity)


func reserve(capacity: int) -> void:
	@warning_ignore_start("return_value_discarded")
	ids.resize(capacity)
	kinds.resize(capacity)
	looks.resize(capacity)
	pos.resize(capacity)
	vel.resize(capacity)
	face.resize(capacity)
	aim.resize(capacity)
	flags.resize(capacity)
	clip.resize(capacity)
	clip_arg.resize(capacity)
	@warning_ignore_restore("return_value_discarded")
	count = mini(count, capacity)


## Overwrites row i (grows the arrays when needed); returns i.
func put(i: int, id: int, kind: BodyPlan.Kind, at: Vector2, velocity: Vector2) -> int:
	if i >= ids.size():
		reserve(maxi(i + 1, ids.size() * 2))
	ids[i] = id
	kinds[i] = kind
	looks[i] = LOOK_AUTO
	pos[i] = at
	vel[i] = velocity
	face[i] = velocity.angle() if velocity.length_squared() > 1.0 else 0.0
	aim[i] = at
	flags[i] = 0
	clip[i] = RigClips.Clip.NONE
	clip_arg[i] = 0.0
	count = maxi(count, i + 1)
	return i


func has_flag(i: int, f: Flag) -> bool:
	return (flags[i] & f) != 0


func look_of(i: int) -> int:
	if looks[i] != LOOK_AUTO:
		return looks[i]
	return RigVariant.crowd_index_for(ids[i], kinds[i] as BodyPlan.Kind)
