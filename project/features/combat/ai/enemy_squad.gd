class_name EnemySquad
extends RefCounted
## The squad layer: attack tokens. At most shooter_slots() fire (a share of the ranged
## alive, or the fixed max_shooters) and max_melee swing at once, so
## Rivet is never shredded from every side; the rest reposition (cover, flank, orbit). A holder
## keeps its token through its windup and shot, then for token_hold ticks at most; free tokens
## go to whoever waited longest, then the nearest, then the lowest id (deterministic).


## `ranged_alive` < 0 counts the ranged members of `agents`; a caller that passes only the
## agents free to attack passes the whole squad's count.
static func assign(
	agents: Array[EnemyAgent], target: Vector2, roster: EnemyRoster, ranged_alive: int = -1
) -> void:
	var slots: int = shooter_slots(roster, ranged_alive if ranged_alive >= 0 else ranged(agents))
	var shooters: int = 0
	var swingers: int = 0
	var want: Array[EnemyAgent] = []
	var wants_melee: bool = false
	var wants_ranged: bool = false
	for e: EnemyAgent in agents:
		if not e.engaged():
			e.token = false
			continue
		if e.token:
			e.token_ticks += 1
			var attacking: bool = e.state == EnemyAgent.State.WINDUP
			attacking = attacking or e.state == EnemyAgent.State.FIRE
			var hold: int = roster.token_hold_ticks if e.sees else roster.token_hold_ticks / 3
			if not attacking and e.token_ticks > hold:
				e.token = false
		if e.token:
			if e.melee():
				swingers += 1
			else:
				shooters += 1
			continue
		e.waited += 1
		if e.sees or e.arch.uses_cover:
			want.append(e)
			if e.melee():
				wants_melee = true
			else:
				wants_ranged = true
	if (
		(not wants_melee or swingers >= roster.max_melee)
		and (not wants_ranged or shooters >= slots)
	):
		return
	_grant_waiters(want, target, roster, Vector2i(shooters, swingers), slots)


static func _grant_waiters(
	want: Array[EnemyAgent], target: Vector2, roster: EnemyRoster, held: Vector2i, slots: int
) -> void:
	var shooters: int = held.x
	var swingers: int = held.y
	want.sort_custom(func(a: EnemyAgent, b: EnemyAgent) -> bool: return _before(a, b, target))
	for e: EnemyAgent in want:
		if e.melee() and swingers < roster.max_melee:
			swingers += 1
			_grant(e)
		elif not e.melee() and shooters < slots:
			shooters += 1
			_grant(e)


static func holders(agents: Array[EnemyAgent], melee: bool) -> int:
	var n: int = 0
	for e: EnemyAgent in agents:
		n += 1 if e.token and e.melee() == melee else 0
	return n


## Ranged attack tokens for `ranged_alive` non-melee squad members alive: a share of them, at
## least max_shooters_min (n31 foes lever 1); the fixed max_shooters when no share is set. A
## stage or test that writes its own max_shooters (prologue, arena pit rules) turns the share off.
static func shooter_slots(roster: EnemyRoster, ranged_alive: int) -> int:
	if roster.max_shooters_share <= 0.0:
		return roster.max_shooters
	return maxi(roster.max_shooters_min, ceili(roster.max_shooters_share * ranged_alive))


## Non-melee agents alive among `agents`.
static func ranged(agents: Array[EnemyAgent]) -> int:
	var n: int = 0
	for e: EnemyAgent in agents:
		n += 1 if e.alive() and not e.melee() else 0
	return n


static func _grant(e: EnemyAgent) -> void:
	e.token = true
	e.token_ticks = 0
	e.waited = 0


static func _before(a: EnemyAgent, b: EnemyAgent, target: Vector2) -> bool:
	if a.waited != b.waited:
		return a.waited > b.waited
	var da: float = a.pos.distance_squared_to(target)
	var db: float = b.pos.distance_squared_to(target)
	if not is_equal_approx(da, db):
		return da < db
	return a.id < b.id
