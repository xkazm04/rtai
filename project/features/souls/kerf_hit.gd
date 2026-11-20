class_name KerfHit
extends RefCounted
## A spectral cutter has no hit cell. Close its lens briefly and tip the complete assembly.

const FLINCH_TICKS: int = 6

var flinch: bool = false
var lean: float = 0.0


func read(arena: CombatArena, facing: float) -> void:
	var rivet: Fighter = arena.rivet
	var age: int = arena.tick - rivet.hurt_tick
	flinch = age >= 0 and age < FLINCH_TICKS
	lean = GhostRecoil.tilt(age, facing, GhostRecoil.lean_of("kerf"), rivet.hurt_dir)


## Rotate the already posed rig about its centre in screen space, carrying the beam sockets.
func apply(body: Node2D) -> void:
	if lean == 0.0:
		return
	var centre: Vector2 = body.global_position
	var projection: Vector2 = Vector2(1.0, ViewMode.shared().ground_k())
	var screen: Transform2D = body.global_transform.scaled(projection)
	body.global_transform = screen.rotated(lean).scaled(Vector2.ONE / projection)
	body.global_position = centre
