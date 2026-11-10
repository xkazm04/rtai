class_name FightBurnArt
extends RefCounted
## A burning human's flames in the real fight (lane gunplay, moved out of FightAreasArt at n11
## combat it32): small fire loops trailing off his back, set on his drawn body under a tilt.
## Render only: reads the sim, writes nothing.
## A burning human runs trailing small flames off his back (human-reactions NEXT 4: one 2.1 m
## flame centred on him hid the body): BURN_FLAMES of BURN_SCALE x the fire loop, the nearest
## BURN_BACK_M behind him, spaced BURN_STEP_M back and fanned BURN_FAN_M to the sides.
const BURN_FLAMES: int = 3
const BURN_SCALE: float = 0.3
const BURN_BACK_M: float = 0.42
const BURN_STEP_M: float = 0.22
const BURN_FAN_M: float = 0.2
## n11 combat it32: under a tilted view (combo) those flames sat on the pavement up to a metre
## off his boots, so a man on fire read as a fire on the floor beside a calm man. Under any tilt
## each flame is pulled in to BURN_TIGHT of its trail and raised BURN_UP_M up the screen, on the
## drawn figure (a standing card is about 1.4 m of screen at 70 degrees, measured with the film
## probe: waist, chest, head). Straight down nothing moves. BURN_LIFT false = the before.
const BURN_LIFT: bool = true
const BURN_TIGHT: float = 0.35
const BURN_UP_M: PackedFloat32Array = [0.55, 0.85, 1.15]
## it32: the fight's FX layer sits under the rigs, so lifted flames showed only at the figure's
## edges. OVER: a fighter with a drawn rig burns over it (ShockArcsView, from the torso: the
## flames at BURN_UP_M less the torso's height, a little behind him), and the FX layer skips
## him. OVER false = the under-layer flames only (the before).
const OVER: bool = true
const TORSO_M: float = 0.45
## Fighter id -> the sim tick its flames were last drawn over the rig (render only).
static var over_ids: Dictionary[int, int] = {}


## Where a burning human's flames sit: behind him against his run (`flee`), off the body.
static func burn_flames(pos: Vector2, flee: Vector2) -> PackedVector2Array:
	var back: Vector2 = -flee.normalized() if flee.length_squared() > 0.0 else Vector2.DOWN
	var side: Vector2 = back.orthogonal()
	var out: Array[Vector2] = []
	for k: int in BURN_FLAMES:
		var fan: float = BURN_FAN_M * float(k - 1)
		out.append(pos + back * (BURN_BACK_M + BURN_STEP_M * float(k)) + side * fan)
	return PackedVector2Array(out)


## The burn flames of a man at `pos` set on his drawn body under a tilt (unchanged straight down).
static func lifted(pos: Vector2, flames: PackedVector2Array) -> PackedVector2Array:
	if not BURN_LIFT or ViewMode.shared().is_flat():
		return flames
	var out: PackedVector2Array = flames.duplicate()
	for k: int in out.size():
		var up: float = BURN_UP_M[mini(k, BURN_UP_M.size() - 1)]
		out[k] = pos + (flames[k] - pos) * BURN_TIGHT + Vector2(0.0, -up)
	return out


static func _burning(ci: CanvasItem, flames: PackedVector2Array, tick: int) -> void:
	for k: int in flames.size():
		var size: float = BURN_SCALE * (1.0 - 0.15 * float(k)) + 0.03 * float((tick / 4 + k) % 2)
		FightAreasArt.fire(ci, flames[k], size, tick + k * 7, 1.0 - 0.2 * float(k))


## Draws the flames of a man at `pos` running along `flee` (metres).
static func draw(ci: CanvasItem, pos: Vector2, flee: Vector2, tick: int) -> void:
	_burning(ci, lifted(pos, burn_flames(pos, flee)), tick)


## True when fighter `id`'s flames were drawn over its rig on `tick` or the tick before.
static func drawn_over(id: int, tick: int) -> bool:
	return OVER and over_ids.get(id, -9) >= tick - 1


## The flames over a burning rig whose torso is at `torso` (the canvas's px, `ppm` px a metre),
## running along `flee`; marks fighter `id` drawn over on `tick`.
static func over(
	ci: CanvasItem, torso: Vector2, ppm: float, flee: Vector2, id: int, tick: int
) -> void:
	over_ids[id] = tick
	var drop: float = 0.0 if ViewMode.shared().is_flat() else TORSO_M  # top: the torso is the spot
	var feet: Vector2 = torso / ppm + Vector2(0.0, drop)
	var flames: PackedVector2Array = lifted(feet, burn_flames(feet, flee))
	for k: int in flames.size():
		flames[k] = flames[k] * ppm / Ink.PX_PER_M
	_burning(ci, flames, tick + id * 3)
