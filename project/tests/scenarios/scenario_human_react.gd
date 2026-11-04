extends Scenario
## Lane human-reactions: the reaction layer's timings, direction truth and determinism, on bare
## cutout rigs stepped on the 60 Hz tick. Every wound family clears within one tick of its table
## length; the knockdown lies flat 1.3-1.6 s (the tackle's 1.4 s); a stagger and a round kill
## carry the body along the round's travel from all four sides; a burn kill chars; two runs of
## every family give the same poses. Planted faults (TST-05): the hit direction inverted (the
## direction check must fail), a death map without the burn row (the char check must fail), and
## a signature kill that takes the death (the standard death must not start).

const WOUNDS: Array[StringName] = [
	&"flinch", &"stagger", &"knockdown", &"shield", &"spin", &"fold", &"stun", &"burn", &"cover"
]
const DIRS: Array[Vector2] = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
const LIE_MIN_S: float = 1.3
const LIE_MAX_S: float = 1.6


func run(_tree: SceneTree) -> String:
	var table: ReactTable = ReactTable.shipped()
	if not table.ok():
		return "human_reactions.json does not load"
	var timings: Dictionary = {}
	for kind: StringName in WOUNDS:
		timings[kind] = _ticks_to_clear(table, kind)
	var lie_s: float = _lie_s(table)
	var dir_ok: float = _direction_truth(table, false)
	var dir_planted: float = _direction_truth(table, true)
	var char_ok: float = _burn_char(table)
	var char_planted: float = _burn_char(_without_burn_death())
	var digest_a: int = _digest(table)
	var digest_b: int = _digest(table)
	var signature_took: bool = _signature_takes(table)
	var out: Dictionary = {
		"ticks_to_clear": timings,
		"knockdown_lie_s": lie_s,
		"direction_dot_min": dir_ok,
		"planted_inverted_dot_min": dir_planted,
		"burn_char": char_ok,
		"planted_no_burn_row_char": char_planted,
		"digest": [digest_a, digest_b],
		"planted_signature_took": signature_took,
	}
	Log.info("scenario", "human_react: %s" % out)
	var err: String = write_evidence("human-react.json", out)
	if err != "":
		return err
	return _judge(table, out)


func _judge(table: ReactTable, o: Dictionary) -> String:
	var t: Dictionary = o["ticks_to_clear"]
	for kind: StringName in WOUNDS:
		var want: int = ceili(table.length(kind) / SimClock.TICK_DT)
		var got: int = t[kind]
		if absi(got - want) > 1:
			return "%s cleared after %d ticks, the table says %d" % [kind, got, want]
	var lie: float = o["knockdown_lie_s"]
	if lie < LIE_MIN_S or lie > LIE_MAX_S:
		return "knockdown lies %.2f s, want %.1f-%.1f" % [lie, LIE_MIN_S, LIE_MAX_S]
	return _judge_faults(o)


func _judge_faults(o: Dictionary) -> String:
	var dot: float = o["direction_dot_min"]
	var planted_dot: float = o["planted_inverted_dot_min"]
	var burnt: float = o["burn_char"]
	var planted_char: float = o["planted_no_burn_row_char"]
	var d: Array = o["digest"]
	var bad: Array[String] = []
	if dot < 0.95:
		bad.append("a reaction does not follow the round (min dot %.2f)" % dot)
	if planted_dot >= 0.95:
		bad.append("planted fault (inverted direction) not caught: %.2f" % planted_dot)
	if burnt < 0.95 or planted_char > 0.05:
		bad.append("burn kill char %.2f (planted %.2f)" % [burnt, planted_char])
	if d[0] != d[1]:
		bad.append("two runs of every family differ: %s" % [d])
	if not o["planted_signature_took"]:
		bad.append("a signature kill did not replace the standard death")
	return "; ".join(PackedStringArray(bad))


func _rig() -> CutRig:
	var rig: CutRig = CutRig.new()
	rig.actor_id = 5
	return rig


func _ticks_to_clear(table: ReactTable, kind: StringName) -> int:
	var rig: CutRig = _rig()
	var r: HumanReact = HumanReact.on(rig)
	r.play(rig, kind, Vector2.LEFT, table)
	var n: int = 0
	while r.active() and n < 1200:
		r.pre(rig, SimClock.TICK_DT)
		n += 1
	rig.free()
	return n


func _lie_s(table: ReactTable) -> float:
	var rig: CutRig = _rig()
	var r: HumanReact = HumanReact.on(rig)
	r.play(rig, &"knockdown", Vector2.LEFT, table)
	var flat: int = 0
	while r.active():
		rig.c_sprawl = 0.0
		r.pre(rig, SimClock.TICK_DT)
		flat += 1 if rig.c_sprawl >= 0.85 else 0
	rig.free()
	return flat * SimClock.TICK_DT


## The smallest cosine between the hit direction and the body's carry at the family's peak,
## over stagger and a round kill from all four sides (planted: the rig is told the opposite).
func _direction_truth(table: ReactTable, plant: bool) -> float:
	var worst: float = 1.0
	for kind: StringName in [&"stagger", &"death_bullet"]:
		for d: Vector2 in DIRS:
			var rig: CutRig = _rig()
			var r: HumanReact = HumanReact.on(rig)
			r.play(rig, kind, -d if plant else d, table)
			var peak: Vector2 = Vector2.ZERO
			for i: int in 30:
				rig.position = Vector2.ZERO
				r.pre(rig, SimClock.TICK_DT)
				peak = rig.position if rig.position.length() > peak.length() else peak
			worst = minf(worst, peak.normalized().dot(d))
			rig.free()
	return worst


func _burn_char(table: ReactTable) -> float:
	var rig: CutRig = _rig()
	var pipe: DeathPipe = DeathPipe.make(table)
	@warning_ignore("return_value_discarded")
	pipe.kill(rig, &"burn", Vector2.LEFT, &"flamethrower")
	for i: int in 120:
		rig.react.pre(rig, SimClock.TICK_DT)
	var c: float = rig.react.tint
	rig.free()
	return c


func _without_burn_death() -> ReactTable:
	var raw: String = FileAccess.get_file_as_string(ReactTable.TABLE)
	var path: String = "user://planted_human_reactions.json"
	var fa: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	@warning_ignore("return_value_discarded")
	fa.store_string(raw.replace('"burn": "death_burn"', '"burn": "death_bullet"'))
	fa.close()
	return ReactTable.shipped(path)


## A hash of every family's pose stream from the four sides (no RNG: two runs must agree).
func _digest(table: ReactTable) -> int:
	var acc: PackedFloat32Array = PackedFloat32Array()
	for kind: StringName in WOUNDS + [&"death_blast", &"death_shock", &"death_melee"]:
		for d: Vector2 in DIRS:
			var rig: CutRig = _rig()
			var r: HumanReact = HumanReact.on(rig)
			r.play(rig, kind, d, table)
			for i: int in 40:
				r.pre(rig, SimClock.TICK_DT)
				acc.append_array([r.off.x, r.off.y, r.rot, rig.twist, rig.c_sprawl, r.head_rot])
			rig.free()
	return hash(acc.to_byte_array())


func _signature_takes(table: ReactTable) -> bool:
	var rig: CutRig = _rig()
	var pipe: DeathPipe = DeathPipe.make(table)
	pipe.add_signature(
		func(r: CutRig, _c: StringName, _d: Vector2, _w: StringName) -> bool: return r.actor_id == 5
	)
	var took: bool = pipe.kill(rig, &"medium", Vector2.LEFT, &"plasma_rifle") == &"signature"
	took = took and rig.react == null
	rig.free()
	return took
