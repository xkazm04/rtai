class_name KillCrushFx
extends Node2D
## Tonnage's press-slam kill (lane ghost-powers, style `crush`), render only: the victim is
## flattened where he stood. Seen straight down a body pressed into the street spreads: over
## SQUASH_TICKS after the hit-stop the whole-body copy widens to SPREAD (an overshoot at the
## impact, then it settles) and darkens toward PRESSED (the ink of a body pressed flat), and it
## stays (CorpseDecay's sink still multiplies in: KillView sets the scale first, pose() after).
## Reduced motion: the body is flat at once (no overshoot). No RNG.

const SQUASH_TICKS: int = 6
const SPREAD: Vector2 = Vector2(1.28, 1.5)
const OVERSHOOT: float = 0.18
const PRESSED: Color = Color(0.72, 0.68, 0.68)


class Crush:
	var serial: int = 0
	var body: Node2D = null
	var born: int = 0


var kills: SignatureKills = null
var ppm: float = 32.0
var reduced_motion: bool = false
var _crushes: Array[Crush] = []


func add(serial: int, body: Node2D) -> void:
	if body == null or kills == null:
		return
	var c: Crush = Crush.new()
	c.serial = serial
	c.body = body
	c.born = kills.tick + kills.hold
	_crushes.append(c)


func pose() -> void:
	for c: Crush in _crushes:
		if not is_instance_valid(c.body):
			continue
		var k: float = squash_k(kills.tick - c.born, reduced_motion)
		c.body.scale *= Vector2.ONE.lerp(SPREAD, k)
		c.body.modulate = Color.WHITE.lerp(PRESSED, clampf(k, 0.0, 1.0))


func forget(serial: int) -> void:
	_crushes = _crushes.filter(func(c: Crush) -> bool: return c.serial != serial)


## The spread at `age` ticks after the hit-stop: 0 before, 1 + OVERSHOOT at the impact's peak,
## settling to 1 by SQUASH_TICKS (1 at once under reduced motion).
static func squash_k(age: int, reduced: bool) -> float:
	if age < 0:
		return 0.0
	if reduced or age >= SQUASH_TICKS:
		return 1.0
	var t: float = float(age) / float(SQUASH_TICKS)
	return 1.0 + OVERSHOOT * sin(t * PI)
