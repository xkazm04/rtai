class_name GuardTell
extends RefCounted
## Lane gunplay: a dock contractor's READABLE burst (the owner's "enemy shots must be readable and
## dodgeable"). Same walk and rifle as GuardBrain, but every burst is announced: the contractor
## stops, raises the rifle and tracks Rivet for the TELL (the view draws the aim line), holds the
## aim still for the last lock ticks (the dodge window), then fires the whole burst down the
## locked line, rounds slowed by weapons.json enemy_fire.speed_scale. Wired only when a table gun
## is (CombatArena.guard_tell); null keeps quest 1's GuardBrain and its goldens.

var tell_ticks: int = 21
var lock_ticks: int = 10
var speed_scale: float = 1.0
## The locked burst's spread as a share of the rifle's (a told line that sprays a cone lies).
var spread_scale: float = 1.0
## Planted fault and A/B switch: keep tracking through the lock (no dodge window).
var track_through_lock: bool = false
## A/B switch (off = every gunner tells on its own clock): one attack slot, so only one
## contractor tells or bursts at a time (no crossfire of two locked lines).
var one_slot: bool = false
## Telemetry: enemy rounds fired under a tell.
var rounds: int = 0
var _holder: Fighter = null


static func from_table(table: WeaponTable) -> GuardTell:
	var t: GuardTell = GuardTell.new()
	t.tell_ticks = maxi(table.enemy_tell_ticks, 1)
	t.lock_ticks = clampi(table.enemy_lock_ticks, 0, t.tell_ticks)
	t.speed_scale = table.enemy_speed_scale
	t.spread_scale = table.enemy_lock_spread
	return t


## True while `g` shows its tell (tracking or locked).
static func telling(g: Fighter) -> bool:
	return g.tell_left > 0


## True in the tell's last lock ticks: the aim no longer follows Rivet.
func locked(g: Fighter) -> bool:
	return g.tell_left > 0 and g.tell_left <= lock_ticks


## One tick for one contractor; returns the round it fires, if any.
func step(g: Fighter, target: Vector2, tuning: CombatTuning, rng: RandomNumberGenerator) -> Shot:
	var to: Vector2 = target - g.pos
	var w: CombatTuning.Weapon = tuning.weapon(g.weapon)
	if g.tell_left > 0:
		if (track_through_lock or not locked(g)) and to.length() > 0.01:
			g.facing = to.normalized()
		g.tell_left -= 1
		if g.tell_left == 0:
			g.burst_left = w.burst
			g.burst_gap = 0
		return null
	if g.burst_left > 0:
		return _burst(g, w, rng)
	if to.length() > 0.01:
		g.facing = to.normalized()
	if to.length() > tuning.human["engage_m"]:
		g.pos += g.facing * tuning.human["walk_mps"] * SimClock.TICK_DT
		return null
	if g.cooldown > 0:
		g.cooldown -= 1
		return null
	if one_slot and not _slot_free(g):
		return null
	_holder = g
	g.tell_left = tell_ticks
	g.cooldown = w.cooldown_ticks
	return null


func _slot_free(g: Fighter) -> bool:
	var h: Fighter = _holder
	return h == null or h == g or not h.alive() or (h.tell_left == 0 and h.burst_left == 0)


## The burst goes down the locked facing (no re-aim), slowed so a strafe beats it.
func _burst(g: Fighter, w: CombatTuning.Weapon, rng: RandomNumberGenerator) -> Shot:
	if g.burst_gap > 0:
		g.burst_gap -= 1
		return null
	g.burst_left -= 1
	g.burst_gap = w.burst_gap_ticks
	var cone: float = w.spread_rad * spread_scale
	var spread: float = rng.randf_range(-cone, cone)
	var s: Shot = Shot.fire(g, g.facing.rotated(spread), w)
	s.vel *= speed_scale
	rounds += 1
	return s
