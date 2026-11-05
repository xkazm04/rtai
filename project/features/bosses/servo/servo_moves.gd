class_name ServoMoves
extends BossMoves
## Servo on the shared boss framework (docs/bosses/servo.md): he keeps his distance (a hub, not a
## brawler), and his attacks launch his own drone swarm (ServoSwarm). The framework's tell tracks
## Rivet and locks; the spot Rivet stood on at the lock is the MARK every drone attack drops on,
## so moving after the lock dodges. The parcels land after the attack window, so their damage
## comes through tick() (n7-servo REQUEST 2: the per-tick hook every state), not active_step.

const KEEP_M: float = 9.0
## The idle band round KEEP_M he walks to hold.
const BAND_M: float = 2.0
## Package carpet: drop points along the lane through the mark, this far apart.
const CARPET_STEP_M: float = 1.5
## A bay hop never jumps further than this.
const HOP_MAX_M: float = 18.0

var swarm: ServoSwarm = ServoSwarm.new()
## Where Rivet stood when the tell locked (the drop target); follows him until the lock.
var mark: Vector2 = Vector2.ZERO
var marks_made: int = 0
## Parcel blasts that caught the target (the bot's hit table).
var blast_hits: int = 0
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


## The swarm's own stream (`ServoSwarm.STREAM`, from the world's RngRegistry). Without it the
## rack never launches (logged once): no hidden unseeded dice.
func setup_swarm(rng: RandomNumberGenerator, tuning: ServoTuning = null) -> void:
	swarm.setup(tuning if tuning != null else ServoTuning.shipped(), rng)
	_armed = true


## Every tick, every state: the mark follows Rivet until the tell locks, the rack follows the body,
## the swarm flies, and each bomb that lands on the target returns its damage.
func tick(f: BossFight, target: Vector2, target_r: float) -> float:
	if f.state == BossFight.State.WINDUP and not f.locked:
		mark = target
	if not _armed:
		return 0.0
	swarm.rack.origin = f.body.pos
	swarm.rack.facing = f.body.facing.angle()
	swarm.step()
	var dealt: float = 0.0
	for b: ServoParcels.Blast in swarm.parcels.blasts:
		if b.pos.distance_to(target) <= b.radius_m + target_r:
			dealt += b.damage
			blast_hits += 1
	return dealt


func active_step(f: BossFight, target: Vector2, target_r: float) -> bool:
	var first: bool = f.t == 1
	match f.attack.id:
		&"scan_drop", &"kamikaze":
			if first and _armed:
				_launched(swarm.launch_wave(mark))
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
	out.put_float(mark.x)
	out.put_float(mark.y)
	if _armed:
		swarm.write_state(out)
