class_name ServoSwarm
extends RefCounted
## Servo's delivery-drone swarm on the 60 Hz tick (docs/bosses/servo.md section 3): drones launch
## from the rack, fly a loose formation to their drop rings (seek with arrival + separation),
## hover hover_ticks over the ring, release the parcel, fly home and dock. A shot drone drops its
## parcel where it is and its cell refills later. The alive cap is per phase; every random choice
## (formation turn, bomb or crate) comes from the `servo_swarm` stream (SIM-02).

const STREAM: StringName = &"servo_swarm"

var tuning: ServoTuning = null
var rack: ServoRack = ServoRack.new()
var parcels: ServoParcels = ServoParcels.new()
var drones: Array[ServoDrone] = []
## The drones that went on the last step (the view drops a wreck for &"shot").
var gone: Array[ServoDrone] = []
var phase: int = 1
## Where the fight's target stands this tick (the kamikaze tells track it; ServoMoves sets it).
var aim_at: Vector2 = Vector2.ZERO
var launched_total: int = 0
var shot_total: int = 0
var _rng: RandomNumberGenerator = null
var _next_id: int = 1


func setup(t: ServoTuning, rng: RandomNumberGenerator) -> void:
	tuning = t
	_rng = rng
	rack.setup(t)
	parcels.setup(t)


func alive() -> int:
	return drones.size()


func cap() -> int:
	return tuning.phase(phase).max_alive


## A marked wave: the phase's wave size, a ring around `mark` (one drone on the mark, the rest
## spread_m out, the ring turned by the stream). Returns how many launched (cap, full cells).
func launch_wave(mark: Vector2) -> int:
	var p: ServoTuning.Phase = tuning.phase(phase)
	var n: int = mini(p.wave, cap() - alive())
	var points: Array[Vector2] = [mark]
	var turn: float = _rng.randf() * TAU
	for k: int in maxi(n - 1, 0):
		points.append(mark + Vector2.from_angle(turn + TAU * k / maxf(n - 1, 1)) * p.spread_m)
	return launch_to(points.slice(0, maxi(n, 0)))


## One drone per drop point, while the cap and the rack allow. Parcels from the stream.
func launch_to(points: Array[Vector2]) -> int:
	var n: int = 0
	for goal: Vector2 in points:
		if alive() >= cap():
			break
		var cell: int = rack.take()
		if cell < 0:
			break
		var d: ServoDrone = ServoDrone.new()
		d.id = _next_id
		_next_id += 1
		d.cell = cell
		d.pos = rack.cell_pos(cell)
		d.goal = goal
		var bomb: bool = _rng.randf() < tuning.bomb_share
		d.parcel = ServoParcels.BOMB if bomb else ServoParcels.CRATE
		drones.append(d)
		n += 1
	launched_total += n
	return n


func step() -> void:
	gone.clear()
	rack.step()
	parcels.step()
	for d: ServoDrone in drones:
		_advance(d)
	var kept: Array[ServoDrone] = []
	for d: ServoDrone in drones:
		if d.alive():
			kept.append(d)
		else:
			gone.append(d)
	drones = kept


func _advance(d: ServoDrone) -> void:
	d.timer += 1
	d.age += 1
	if d.age >= tuning.life_ticks:
		_finish(d, &"expired")
		return
	match d.state:
		ServoDrone.State.LAUNCH:
			d.height = tuning.fly_h_m * minf(float(d.timer) / maxi(tuning.launch_ticks, 1), 1.0)
			if d.timer >= tuning.launch_ticks:
				_enter(d, ServoDrone.State.TRANSIT)
		ServoDrone.State.TRANSIT:
			_fly(d, d.goal)
			if d.pos.distance_to(d.goal) <= tuning.arrive_m:
				_enter(d, ServoDrone.State.HOVER)
		ServoDrone.State.HOVER when d.dive:
			_fly(d, d.goal)
			ServoDive.hover(self, d)
		ServoDrone.State.DIVE:
			ServoDive.dive(self, d)
		ServoDrone.State.HOVER:
			_fly(d, d.goal)
			if d.timer >= tuning.hover_ticks:
				parcels.drop(d.goal, d.parcel, tuning.fall_ticks)
				d.parcel = &""
				_enter(d, ServoDrone.State.RETURN)
		ServoDrone.State.RETURN:
			var home: Vector2 = rack.cell_pos(d.cell)
			_fly(d, home)
			if d.pos.distance_to(home) <= tuning.arrive_m * 2.0:
				rack.dock(d.cell)
				_finish(d, &"docked")


func _enter(d: ServoDrone, state: int) -> void:
	d.state = state
	d.timer = 0


## Seek with arrival plus separation from the other drones; acceleration and speed clamped.
func _fly(d: ServoDrone, target: Vector2) -> void:
	var to: Vector2 = target - d.pos
	var dist: float = to.length()
	var want: Vector2 = Vector2.ZERO
	if dist > 0.001:
		want = to / dist * minf(tuning.cruise_mps, dist * 4.0)
	for o: ServoDrone in drones:
		if o == d or not o.alive():
			continue
		var away: Vector2 = d.pos - o.pos
		var gap: float = away.length()
		if gap > 0.001 and gap < tuning.sep_m:
			want += away / gap * (tuning.sep_m - gap) * tuning.cruise_mps
	var dv: Vector2 = (want - d.vel).limit_length(tuning.accel_mps2 * SimClock.TICK_DT)
	d.vel = (d.vel + dv).limit_length(tuning.cruise_mps)
	d.pos += d.vel * SimClock.TICK_DT


func _finish(d: ServoDrone, why: StringName) -> void:
	if why != &"docked":
		rack.lost(d.cell)
	d.state = ServoDrone.State.GONE
	d.gone_by = why


## Shoots down the drone; a carried parcel falls from where it is (its own short ring).
func kill(d: ServoDrone) -> void:
	if not d.alive():
		return
	if d.carrying():
		parcels.drop(d.pos, d.parcel, tuning.fall_ticks)
		d.parcel = &""
	shot_total += 1
	_finish(d, &"shot")


## Phase 3: kamikaze drones to a standoff ring round `mark` (the ring turned by the stream).
func launch_dives(mark: Vector2) -> int:
	return ServoDive.launch(self, mark, tuning.phase(phase).wave, _rng.randf() * TAU)


## Every live drone whose ground shadow is within `radius_m` of `pos` (Ohm's fork, a blast).
func near(pos: Vector2, radius_m: float) -> Array[ServoDrone]:
	var out: Array[ServoDrone] = []
	for d: ServoDrone in drones:
		if d.alive() and d.pos.distance_to(pos) <= radius_m:
			out.append(d)
	return out


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(drones.size())
	for d: ServoDrone in drones:
		out.put_32(d.id)
		out.put_32(d.state)
		out.put_float(d.pos.x)
		out.put_float(d.pos.y)
	parcels.write_state(out)
	for s: int in rack.state:
		out.put_8(s)
