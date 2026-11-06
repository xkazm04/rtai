class_name ServoDive
extends RefCounted
## Phase 3's kamikaze drones (docs/bosses/servo.md, `kamikaze`): the broken rack spits drones that
## fly out to a standoff ring round the mark, then each one's own dive tell: its strike point
## TRACKS the target (thin dive line) for track_ticks, LOCKS for lock_ticks (thick line, the blast
## ring on the ground), then the drone dives at dive_mps to the locked point and blows (blast_m,
## damage) and is spent. Moving after the lock dodges, as every tell in the game. Stepped by
## ServoSwarm; the numbers are servo.json `kamikaze`.


## Kamikaze drones out to a standoff ring round `mark` (turned by the swarm's stream).
static func launch(s: ServoSwarm, mark: Vector2, n: int, turn: float) -> int:
	var points: Array[Vector2] = []
	for k: int in n:
		points.append(
			mark + Vector2.from_angle(turn + TAU * k / maxf(n, 1)) * s.tuning.dive_standoff_m
		)
	var before: int = s.drones.size()
	@warning_ignore("return_value_discarded")
	s.launch_to(points)
	for i: int in range(before, s.drones.size()):
		var d: ServoDrone = s.drones[i]
		d.dive = true
		d.parcel = &""
	return s.drones.size() - before


## The tell over the standoff point: track, then lock, then dive.
static func hover(s: ServoSwarm, d: ServoDrone) -> void:
	if d.timer <= s.tuning.dive_track_ticks:
		d.strike = s.aim_at
	if d.timer >= s.tuning.dive_track_ticks + s.tuning.dive_lock_ticks:
		d.state = ServoDrone.State.DIVE
		d.timer = 0


## Straight down the locked line; on arrival the blast (one Blast this tick) and the drone is spent.
static func dive(s: ServoSwarm, d: ServoDrone) -> void:
	var to: Vector2 = d.strike - d.pos
	var step: float = s.tuning.dive_mps * SimClock.TICK_DT
	d.height = maxf(d.height - s.tuning.fly_h_m * step / maxf(to.length(), step), 0.0)
	if to.length() <= step:
		d.pos = d.strike
		var b: ServoParcels.Blast = ServoParcels.Blast.new()
		b.pos = d.strike
		b.radius_m = s.tuning.dive_blast_m
		b.damage = s.tuning.dive_damage
		s.parcels.blasts.append(b)
		d.state = ServoDrone.State.GONE
		d.gone_by = &"spent"
		s.rack.lost(d.cell)
		return
	d.vel = to.normalized() * s.tuning.dive_mps
	d.pos += d.vel * SimClock.TICK_DT


## True once the drone's strike point is locked (the thick line, the ring): the player's cue.
static func locked(s: ServoSwarm, d: ServoDrone) -> bool:
	return (
		d.dive
		and (
			d.state == ServoDrone.State.DIVE
			or (d.state == ServoDrone.State.HOVER and d.timer > s.tuning.dive_track_ticks)
		)
	)
