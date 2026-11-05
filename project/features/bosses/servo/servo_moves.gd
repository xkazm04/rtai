class_name ServoMoves
extends BossMoves
## Servo on the shared boss framework (docs/bosses/servo.md): he keeps his distance (a hub, not a
## brawler), and his attacks launch his own drone swarm (ServoSwarm). The framework's tell tracks
## Rivet and locks; the spot Rivet stood on at the lock is the MARK every drone attack drops on,
## so moving after the lock dodges. The parcels land after the attack window, so their damage
## comes through tick() (BossFight calls it every tick in every state), not active_step.

const KEEP_M: float = 9.0
## The idle band round KEEP_M he walks to hold.
const BAND_M: float = 2.0
## Package carpet: drop points along the lane through the mark, this far apart.
const CARPET_STEP_M: float = 1.5
## A bay hop never jumps further than this.
const HOP_MAX_M: float = 18.0
## A player's read of a new drop ring (BossBot.REACT_TICKS: about 0.3 s).
const SEEN_TICKS: int = 18

var swarm: ServoSwarm = ServoSwarm.new()
## The live drones as arena bodies (shootable, seizable; BossHook keeps them in the hostiles).
var drone_bodies: ServoDroneBodies = ServoDroneBodies.new()
## Where Rivet stood when the tell locked (the drop target); follows him until the lock.
var mark: Vector2 = Vector2.ZERO
var marks_made: int = 0
## Parcel blasts that caught the target (the bot's hit table).
var blast_hits: int = 0
## Of those, the kamikaze dives' (the rest are parcels), and the dives flown.
var dive_hits: int = 0
var dives: int = 0
## The bay hop's landing ring once its tell locked (the bot's read), else none.
## The arena record's centre (the depot's dressing is laid round it): set once by bind().
var depot_origin: Vector2 = Vector2.ZERO
var _hop_locked: bool = false
var _hop_r: float = 0.0
var _armed: bool = false


func _init() -> void:
	keep_m = KEEP_M


## Between attacks he holds a band round keep_m: closes in when far, and backs off when a dash
## left him on top of Rivet (the default walk only closes in, which stranded him inside every
## attack's min_m: a dead zone, measured in test_servo_moves).
func idle_step(f: BossFight, target: Vector2) -> void:
	var d: Vector2 = target - f.body.pos
	var dist: float = d.length()
	if dist > 0.01:
		f.body.facing = d / dist
	var step: float = f.spec.move_mps * SimClock.TICK_DT
	if dist > keep_m + BAND_M:
		f.body.pos += d / dist * step
	elif dist < keep_m - BAND_M and dist > 0.01:
		f.body.pos -= d / dist * step


## BossHook binds once: the swarm takes its own named stream (`ServoSwarm.STREAM`).
func bind(f: BossFight, rng: RngRegistry) -> void:
	depot_origin = f.body.pos - f.spec.arena.boss_at
	setup_swarm(rng.stream(ServoSwarm.STREAM))


## The swarm's own stream. Without it the rack never launches: no hidden unseeded dice.
func setup_swarm(rng: RandomNumberGenerator, tuning: ServoTuning = null) -> void:
	swarm.setup(tuning if tuning != null else ServoTuning.shipped(), rng)
	drone_bodies.hp = swarm.tuning.drone_hp
	drone_bodies.radius_m = swarm.tuning.radius_m
	_armed = true


## Every tick, every state: the mark follows Rivet until the tell locks, the rack follows the body,
## the swarm flies, and each bomb that lands on the target returns its damage.
func tick(f: BossFight, target: Vector2, target_r: float) -> float:
	if f.state == BossFight.State.WINDUP and not f.locked:
		mark = target
	_hop_locked = f.state == BossFight.State.WINDUP and f.locked and f.attack.id == &"bay_hop"
	_hop_r = f.attack.range_m if _hop_locked else 0.0
	if not _armed:
		return 0.0
	swarm.rack.origin = f.body.pos
	swarm.rack.facing = f.body.facing.angle()
	swarm.aim_at = target
	swarm.step()
	drone_bodies.sync(swarm)
	var dealt: float = 0.0
	for b: ServoParcels.Blast in swarm.parcels.blasts:
		if b.pos.distance_to(target) <= b.radius_m + target_r:
			dealt += b.damage
			blast_hits += 1
			dive_hits += 1 if b.radius_m == swarm.tuning.dive_blast_m else 0
	return dealt


## Away from every drop ring that would catch a body at `at` (radius r): the rings of carried
## parcels once a player has seen them for SEEN_TICKS (a drone's age), and every falling parcel.
func threat_away(at: Vector2, r: float) -> Vector2:
	if not _armed:
		return Vector2.ZERO
	var ring: float = swarm.tuning.ring_m + r
	var out: Vector2 = Vector2.ZERO
	var spots: Array[Vector2] = []
	for d: ServoDrone in swarm.drones:
		if d.carrying() and d.age >= SEEN_TICKS:
			spots.append(d.goal)
	for p: ServoParcels.Parcel in swarm.parcels.falling:
		spots.append(p.pos)
	if _hop_locked and at.distance_to(mark) < _hop_r + r:
		out += (at - mark).normalized() if at.distance_to(mark) > 0.05 else Vector2.UP
	var dive_r: float = swarm.tuning.dive_blast_m + r
	for d: ServoDrone in swarm.drones:  # a locked dive's blast ring
		if ServoDive.locked(swarm, d) and at.distance_to(d.strike) < dive_r:
			out += (at - d.strike).normalized() if at.distance_to(d.strike) > 0.05 else Vector2.UP
	for spot: Vector2 in spots:
		var off: Vector2 = at - spot
		if off.length() < ring:
			out += off.normalized() if off.length() > 0.05 else Vector2.RIGHT
	return out.normalized() if out.length() > 0.01 else Vector2.ZERO


## Servo's own numbers for the bot's table (BossHook puts them under `moves`).
func telemetry() -> Dictionary:
	return {
		"marks": marks_made,
		"drones_launched": swarm.launched_total if _armed else 0,
		"drones_shot": drone_bodies.shot,
		"parcels_landed": swarm.parcels.landed_total if _armed else 0,
		"parcel_hits": blast_hits - dive_hits,
		"dives": dives,
		"dive_hits": dive_hits,
	}


func bodies() -> Array[Fighter]:
	return drone_bodies.list()


func active_step(f: BossFight, target: Vector2, target_r: float) -> bool:
	var first: bool = f.t == 1
	match f.attack.id:
		&"scan_drop":
			if first and _armed:
				_launched(swarm.launch_wave(mark))
			return false
		&"kamikaze":
			if first and _armed:
				var n: int = swarm.launch_dives(mark)
				dives += n
				_launched(n)
			return false
		&"package_carpet":
			if first and _armed:
				var n: int = swarm.tuning.phase(swarm.phase).wave
				_launched(swarm.launch_to(carpet(mark, f.aim, n)))
			return false
		&"bay_hop":
			if first:
				f.body.pos += (mark - f.body.pos).limit_length(HOP_MAX_M)
			return f.body.pos.distance_to(target) <= f.attack.range_m + target_r
	return super.active_step(f, target, target_r)


func _launched(n: int) -> void:
	marks_made += 1
	if n == 0:
		Log.info("bosses", "servo: rack empty or capped, no wave")


## The carpet's drop points: n along the aim through the mark, CARPET_STEP_M apart.
static func carpet(at: Vector2, dir: Vector2, n: int) -> Array[Vector2]:
	var out: Array[Vector2] = []
	for k: int in n:
		out.append(at + dir * (k - (n - 1) * 0.5) * CARPET_STEP_M)
	return out


func phase_entered(_f: BossFight, phase: int) -> void:
	swarm.phase = phase + 1
	if phase >= 2 and _armed:
		swarm.rack.break_wing()


func write_state(out: StreamPeerBuffer) -> void:
	super.write_state(out)
	out.put_float(mark.x)
	out.put_float(mark.y)
	if _armed:
		swarm.write_state(out)
