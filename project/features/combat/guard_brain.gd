class_name GuardBrain
extends RefCounted
## A dock contractor with an assault rifle (mechanic assault-rifle): walk at Rivet until inside
## engage_m, then spray bursts of weak rounds (burst, burst_gap, cooldown) with a seeded spread.
## Sense, decide and apply in one small step per tick; the arena owns the shots it returns.


static func step(
	g: Fighter, target: Vector2, tuning: CombatTuning, rng: RandomNumberGenerator
) -> Shot:
	if approach(g, target, tuning):
		return null
	return trigger(g, tuning, rng)


## Resolve body penetration on the moving partner. Wave guards keep their own movement.
static func space_partner(g: Fighter, hostiles: Array[Fighter]) -> void:
	if g.pursuit == null:
		return
	for other: Fighter in hostiles:
		if other == g or not other.alive():
			continue
		var side: float = 1.0 if g.id > other.id else -1.0
		var push: Vector2 = EnemyMotor.repel(g.pos, other.pos, g.station_spacing_m, side)
		if push != Vector2.ZERO:
			g.pursuit.push_body(g, push)


## A street squad reads the optional weapon setting once when its firing line is installed.
static func street_rifle_lead() -> float:
	var table: DataTable = DataTable.open(CombatTuning.TABLE, CombatTuning.SCHEMA)
	var row: Dictionary = table.object(table.object(table.raw, "weapons"), "assault-rifle")
	return table.num(row, "aim_lead") if row.has("aim_lead") else 0.0


## Track until the first round, then keep that firing line through the four-round burst.
## A returning shooter acquires a fresh line after a sight or squad-slot interruption.
static func street_aim(
	g: Fighter, w: CombatTuning.Weapon, mind: SquadMind, pit: EnemyPit, share: float
) -> Vector2:
	if share <= 0.0:
		return g.facing
	if g.burst_left == 0 or g.burst_left == w.burst or mind.paused_rounds > 0:
		var to: Vector2 = pit.rivet_pos - g.pos
		var flight_s: float = to.length() / maxf(w.speed_mps, 1.0)
		var predicted: Vector2 = EnemyBrain.led_offset(to, pit.rivet_vel, flight_s, share)
		mind.agent.aim = g.facing.rotated(to.angle_to(predicted))
	return mind.agent.aim


static func trigger(g: Fighter, tuning: CombatTuning, rng: RandomNumberGenerator) -> Shot:
	var w: CombatTuning.Weapon = tuning.weapon(g.weapon)
	if g.burst_left > 0:
		if g.burst_gap > 0:
			g.burst_gap -= 1
			return null
		g.burst_left -= 1
		g.burst_gap = w.burst_gap_ticks
		var spread: float = rng.randf_range(-w.spread_rad, w.spread_rad)
		return Shot.fire(g, g.facing.rotated(spread), w)
	if g.cooldown > 0:
		g.cooldown -= 1
		return null
	g.burst_left = w.burst
	g.cooldown = w.cooldown_ticks
	return null


## Both rifle brains share the approach. On open ground the original speed and range apply.
static func approach(g: Fighter, target: Vector2, tuning: CombatTuning) -> bool:
	var speed: float = tuning.human["walk_mps"]
	if g.pursuit != null and g.pursuit.advance(g, target, speed):
		return true
	var to: Vector2 = target - g.pos
	if to.length() > 0.01:
		g.facing = to.normalized()
	if to.length() <= tuning.human["engage_m"]:
		return false
	g.pos += g.facing * speed * SimClock.TICK_DT
	return true
