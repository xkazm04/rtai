class_name EnemyPitChecks
extends RefCounted
## The pit scenario's measured setups (flank, cover, panic) and its judge (scenario_enemy_pit).


static func flank_spread() -> Dictionary:
	var pit: EnemyPit = PitLayout.build(17, false)
	PitLayout.squad(pit, PitLayout.many(&"swat", 4))
	pit.rivet_hp = 100000.0
	var best: float = 0.0
	for t: int in 600:
		pit.step()
		var lo: float = INF
		var hi: float = -INF
		for e: EnemyAgent in pit.agents:
			var a: float = rad_to_deg((e.pos - pit.rivet_pos).angle())
			lo = minf(lo, a)
			hi = maxf(hi, a)
		best = maxf(best, _wrap_spread(lo, hi))
	return {"spread_deg": snappedf(best, 0.1)}


static func cover_hidden() -> Dictionary:
	var pit: EnemyPit = PitLayout.build(19)
	PitLayout.squad(pit, PitLayout.many(&"swat", 4))
	pit.rivet_hp = 100000.0
	var dummy: PitDummy = PitDummy.new(PitDummy.Mode.STAND, PitLayout.RIVET_START)
	var hidden: int = 0
	var idle: int = 0
	for t: int in 900:
		dummy.step(pit)
		pit.step()
		for e: EnemyAgent in pit.agents:
			if t < 240 or e.token:
				continue
			idle += 1
			hidden += 1 if EnemySenses.blocked(e.pos, pit.rivet_pos, pit.cover) else 0
	return {"hidden_frac": snappedf(float(hidden) / maxf(idle, 1.0), 0.001)}


static func panic() -> Dictionary:
	var out: Dictionary = {}
	for id: StringName in [&"patrol_cop", &"robot_thug"]:
		var pit: EnemyPit = PitLayout.build(23, false)
		PitLayout.squad(pit, PitLayout.many(id, 6))
		pit.rivet_hp = 100000.0
		for i: int in 4:
			pit.hurt(pit.agents[i], 100.0, Vector2.LEFT)
		var panicked: int = 0
		for t: int in 30:
			pit.step()
		for e: EnemyAgent in pit.agents:
			panicked += 1 if e.state == EnemyAgent.State.PANIC else 0
		out[String(id)] = panicked
	return out


static func judge(ev: Dictionary) -> String:
	for id: String in ev["archetypes"]:
		var r: Dictionary = ev["archetypes"][id]
		if r["tells"] < 1.0:
			return "%s never attacked: %s" % [id, r]
		if r["tells"] < r["swings"] + r["shots"] / 3.0 - 0.5:
			return "%s attacked without a tell: %s" % [id, r]
	var sq: Dictionary = ev["squad"]
	if sq["max_attackers"] > sq["max_shooters"] or sq["shots"] < 1.0:
		return "squad cap broken or nobody shot: %s" % sq
	if ev["planted_no_squad"]["max_attackers"] <= sq["max_shooters"]:
		return "planted fault (squad cap off) not caught: %s" % ev["planted_no_squad"]
	var dodge: float = ev["dodge"]["hit_rate"]
	if dodge > 0.5 * ev["stand"]["hit_rate"]:
		return "telegraphs not dodgeable: dodge %s stand %s" % [ev["dodge"], ev["stand"]]
	if ev["planted_no_lock"]["hit_rate"] <= dodge:
		return "planted fault (aim lock off) not caught: %s" % ev["planted_no_lock"]
	return _judge_squad_moves(ev)


static func _judge_squad_moves(ev: Dictionary) -> String:
	if ev["flank"]["spread_deg"] < 70.0:
		return "SWAT did not flank: %s" % ev["flank"]
	if ev["cover"]["hidden_frac"] < 0.4:
		return "SWAT did not use cover: %s" % ev["cover"]
	if ev["panic"]["patrol_cop"] < 1 or ev["panic"]["robot_thug"] != 0:
		return "morale wrong (cops must break, robots never): %s" % ev["panic"]
	var d: Dictionary = ev["determinism"]
	if d["a"] != d["b"] or d["a"] == d["other_seed"]:
		return "not deterministic: %s" % d
	return ""


static func _wrap_spread(lo: float, hi: float) -> float:
	return minf(hi - lo, 360.0 - (hi - lo))
