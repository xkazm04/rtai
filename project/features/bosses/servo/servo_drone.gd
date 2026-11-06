class_name ServoDrone
extends RefCounted
## One delivery drone: plain state, stepped by ServoSwarm. Ground-plane metres; `height` is how
## far above its shadow it flies (the view draws the shadow at `pos`, the drone up by height).

enum State { LAUNCH, TRANSIT, HOVER, RETURN, GONE, DIVE }

var id: int = 0
var cell: int = -1
var state: int = State.LAUNCH
var pos: Vector2 = Vector2.ZERO
var vel: Vector2 = Vector2.ZERO
var height: float = 0.0
## The drop point (its ring on the ground) while it carries a parcel.
var goal: Vector2 = Vector2.ZERO
## &"" once released.
var parcel: StringName = &""
## Ticks in the current state, and alive in total (the fail-safe despawn).
var timer: int = 0
var age: int = 0
## A kamikaze (phase 3, ServoDive): no parcel, it dives at `strike` and is spent.
var dive: bool = false
var strike: Vector2 = Vector2.ZERO
## Why it went: &"docked", &"shot", &"expired", &"spent".
var gone_by: StringName = &""


func carrying() -> bool:
	return parcel != &""


func alive() -> bool:
	return state != State.GONE
