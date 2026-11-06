class_name ServoParcels
extends RefCounted
## The parcels Servo's drones drop: each falls fall_ticks onto its drop ring, then a bomb blasts
## (one Blast this tick, the caller applies it to Rivet and the crowd) or a CS crate lands and
## stays as an obstacle and cover until shot apart (crate_hp hits) or crate_life_ticks pass.

const BOMB: StringName = &"bomb"
const CRATE: StringName = &"crate"


class Parcel:
	extends RefCounted
	var kind: StringName = BOMB
	var pos: Vector2 = Vector2.ZERO
	## Ticks until it lands (> 0 = falling; the ring is drawn while falling).
	var fall_left: int = 0
	var fall_total: int = 1
	var hp: int = 0
	var life_left: int = 0


class Blast:
	extends RefCounted
	var pos: Vector2 = Vector2.ZERO
	var radius_m: float = 0.0
	var damage: float = 0.0
	## A bomb's or dive's fireball (false: a crate's landing hit, no boom drawn).
	var fire: bool = true
	## Render only (booms): ticks of its fireball left.
	var life_left: int = 0


## How long a smashed crate's cardboard burst shows.
const DEBRIS_TICKS: int = 30
## How long a bomb's or a dive's fireball shows (0.45 s, as Dent's car bomb).
const BOOM_TICKS: int = 27

var falling: Array[Parcel] = []
var crates: Array[Parcel] = []
## Crates the dash smashed (telemetry).
var smashed_total: int = 0
## Where crates were smashed, life_left counting down DEBRIS_TICKS (render only: the view's
## cardboard burst; not in write_state).
var debris: Array[Parcel] = []
## The blasts of the last BOOM_TICKS, life_left counting down (render only: the view's fireball;
## not in write_state). A blast lives one step in `blasts`; this keeps it on screen.
var booms: Array[Blast] = []
## The bombs that went off on the last step (cleared at the start of each step).
var blasts: Array[Blast] = []
var landed_total: int = 0
var _tuning: ServoTuning = null


func setup(tuning: ServoTuning) -> void:
	_tuning = tuning


func drop(pos: Vector2, kind: StringName, fall_ticks: int) -> void:
	var p: Parcel = Parcel.new()
	p.kind = kind
	p.pos = pos
	p.fall_left = maxi(fall_ticks, 1)
	p.fall_total = p.fall_left
	falling.append(p)


func step() -> void:
	for b: Blast in blasts:
		if b.fire:
			b.life_left = BOOM_TICKS
			booms.append(b)
	booms = booms.filter(func(b: Blast) -> bool: return b.life_left > 1)
	for b: Blast in booms:
		b.life_left -= 1
	blasts.clear()
	var still: Array[Parcel] = []
	for p: Parcel in falling:
		p.fall_left -= 1
		if p.fall_left > 0:
			still.append(p)
		else:
			_land(p)
	falling = still
	var kept: Array[Parcel] = []
	for c: Parcel in crates:
		c.life_left -= 1
		if c.life_left > 0 and c.hp > 0:
			kept.append(c)
	crates = kept
	debris = debris.filter(func(d: Parcel) -> bool: return d.life_left > 0)
	for d: Parcel in debris:
		d.life_left -= 1


func _land(p: Parcel) -> void:
	landed_total += 1
	if p.kind == BOMB:
		var b: Blast = Blast.new()
		b.pos = p.pos
		b.radius_m = _tuning.ring_m
		b.damage = _tuning.bomb_damage
		blasts.append(b)
		return
	if _tuning.crate_damage > 0.0:  # the owner call: a crate landing on Rivet hurts
		var hit: Blast = Blast.new()
		hit.pos = p.pos
		hit.radius_m = _tuning.crate_m * 0.5
		hit.damage = _tuning.crate_damage
		hit.fire = false
		blasts.append(hit)
	p.hp = _tuning.crate_hp
	p.life_left = _tuning.crate_life_ticks
	crates.append(p)


## Everything still falling lands at once and harmless (the defeat): crates stay, bombs are duds.
func settle() -> void:
	for p: Parcel in falling:
		if p.kind == CRATE:
			_land(p)
	falling = []
	blasts.clear()


## The landed crates as solid boxes (ServoMoves.solids: they block bodies and shots).
func solids() -> Array[Rect2]:
	var out: Array[Rect2] = []
	var half: Vector2 = Vector2.ONE * _tuning.crate_m * 0.5
	for c: Parcel in crates:
		if c.hp > 0:
			out.append(Rect2(c.pos - half, half * 2.0))
	return out


## A hit on whatever crate covers `pos`; true if one took it.
func hit_crate(pos: Vector2, damage: int) -> bool:
	for c: Parcel in crates:
		if c.hp > 0 and _covers(c, pos, 0.0):
			c.hp -= damage
			return true
	return false


## Every crate a body of `radius_m` at `pos` overlaps is smashed (the rotor dash ploughs its lane
## clear); returns how many.
func smash(pos: Vector2, radius_m: float) -> int:
	var n: int = 0
	for c: Parcel in crates:
		if c.hp > 0 and _covers(c, pos, radius_m):
			c.hp = 0
			n += 1
			var d: Parcel = Parcel.new()
			d.pos = c.pos
			d.life_left = DEBRIS_TICKS
			debris.append(d)
	smashed_total += n
	return n


## True if a body of `radius_m` at `pos` overlaps a landed crate (crates block paths).
func blocked(pos: Vector2, radius_m: float) -> bool:
	for c: Parcel in crates:
		if c.hp > 0 and _covers(c, pos, radius_m):
			return true
	return false


func _covers(c: Parcel, pos: Vector2, radius_m: float) -> bool:
	var half: float = _tuning.crate_m * 0.5 + radius_m
	return absf(pos.x - c.pos.x) <= half and absf(pos.y - c.pos.y) <= half


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(falling.size())
	for p: Parcel in falling:
		out.put_float(p.pos.x)
		out.put_float(p.pos.y)
		out.put_32(p.fall_left)
	out.put_32(crates.size())
	for c: Parcel in crates:
		out.put_float(c.pos.x)
		out.put_float(c.pos.y)
		out.put_32(c.hp)
