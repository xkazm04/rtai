class_name EnemySquad
extends RefCounted
## The squad layer: attack tokens. At most max_shooters fire and max_melee swing at once, so
## Rivet is never shredded from every side; the rest reposition (cover, flank, orbit). A holder
## keeps its token through its windup and shot, then for token_hold ticks at most; free tokens
## go to whoever waited longest, then the nearest, then the lowest id (deterministic).


static func assign(agents: Array[EnemyAgent], target: Vector2, roster: EnemyRoster) -> void:
	var shooters: int = 0
	var swingers: int = 0
	var want: Array[EnemyAgent] = []
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
			swingers += 1 if e.melee() else 0
			shooters += 0 if e.melee() else 1
			continue
		e.waited += 1
		if e.sees or e.arch.uses_cover:
			want.append(e)
	want.sort_custom(func(a: EnemyAgent, b: EnemyAgent) -> bool: return _before(a, b, target))
	for e: EnemyAgent in want:
		if e.melee() and swingers < roster.max_melee:
			swingers += 1
			_grant(e)
		elif not e.melee() and shooters < roster.max_shooters:
			shooters += 1
			_grant(e)


static func holders(agents: Array[EnemyAgent], melee: bool) -> int:
	var n: int = 0
	for e: EnemyAgent in agents:
		n += 1 if e.token and e.melee() == melee else 0
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
