class_name HumanReact
extends RefCounted
## One cutout rig's running reaction or death (README.md here). The rig calls pre() after its
## springs and post() after its pose each step (CutRig.react); a family (ReactPose, DeathPose)
## writes the clip envelopes in pre and the drawn offsets below in post. A death holds its last
## frame as the corpse. Render-side only: no RNG (the jitter phase comes from the actor id),
## never sim state, never hashed.

## Part px per metre (CutRig.SC 0.1 at 32 world px per metre).
const PX_M: float = 320.0
const CHAR: Color = Color(0.34, 0.31, 0.3)

var kind: StringName = &""
var t: float = 0.0
var length: float = 0.3
var travel: float = 0.0
## The hit direction in rig space (+x = the way the body faced when hit), unit length.
var dir: Vector2 = Vector2.LEFT
var side: float = 1.0
var phase: float = 0.0
var dying: bool = false
## How far the whole rig is carried along the hit this step (part px, rig space). It moves the
## rig node, so the world-planted feet follow; the host must set the rig's position every tick
## (RigInput does), else the carry accumulates.
var slide: Vector2 = Vector2.ZERO
## Scales the carry: 1 where the sim does not move the body (the board), lower where the host's
## knockback already slides it (HitLink), so the two do not add up.
var carry: float = 1.0
## What post() draws: body offset (part px), body turn, body scale, head turn/offset/scale.
var off: Vector2 = Vector2.ZERO
var rot: float = 0.0
var scl: Vector2 = Vector2.ONE
var head_rot: float = 0.0
var head_off: Vector2 = Vector2.ZERO
var head_s: float = 1.0
var tint: float = 0.0


## The rig's reaction slot (made on first use).
static func on(rig: CutRig) -> HumanReact:
	if rig.react == null:
		rig.react = HumanReact.new()
		rig.react.phase = float(rig.actor_id % 97) * 0.61
	return rig.react


## Starts family `p_kind` on `rig`, hit along `world_dir` (the way the blow travels).
func play(rig: CutRig, p_kind: StringName, world_dir: Vector2, table: ReactTable) -> void:
	if dying:
		return
	kind = p_kind
	dying = p_kind.begins_with("death_")
	t = 0.0
	length = maxf(table.length(p_kind), 0.05)
	travel = table.travel(p_kind) * PX_M
	var d: Vector2 = world_dir.normalized().rotated(-rig.facing)
	dir = d if d != Vector2.ZERO else Vector2.LEFT
	side = 1.0 if dir.y >= 0.0 else -1.0


func active() -> bool:
	return kind != &""


## 0..1 through the family (a death stays at 1).
func progress() -> float:
	return clampf(t / length, 0.0, 1.0)


## Jumps to the family's last frame (a corpse redrawn on a fresh rig).
func settle() -> void:
	t = length


func clear() -> void:
	kind = &""
	dying = false
	t = 0.0
	_rest()


func pre(rig: CutRig, dt: float) -> void:
	if kind == &"":
		return
	t += dt
	if not dying and t >= length:
		clear()
		rig.modulate = Color.WHITE
		return
	_rest()
	if dying:
		DeathPose.pre(self, rig)
	else:
		ReactPose.pre(self, rig)
	if slide != Vector2.ZERO:
		rig.position += rig.transform.basis_xform(slide * carry)


func post(rig: CutRig) -> void:
	if kind == &"":
		return
	var b: Transform2D = Transform2D(rot, scl, 0.0, off)
	rig.body.transform = b * rig.body.transform
	var h: Transform2D = (
		rig.head.transform * Transform2D(head_rot, Vector2(head_s, head_s), 0.0, Vector2.ZERO)
	)
	h.origin += head_off
	rig.head.transform = h
	rig.modulate = Color.WHITE.lerp(CHAR, tint)


func _rest() -> void:
	slide = Vector2.ZERO
	off = Vector2.ZERO
	rot = 0.0
	scl = Vector2.ONE
	head_rot = 0.0
	head_off = Vector2.ZERO
	head_s = 1.0
	tint = 0.0
