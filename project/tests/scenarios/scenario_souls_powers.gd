extends Scenario
## features/souls: both ghost powers against bodies. Hauler: the tank walks at its top speed
## (4.2 m/s, under base Rivet's 5.0 tackle line) into a standing human in the real city sim and
## knocks him down, then into a robot (BodyContact) and knocks it down; its stomp floors a ring.
## Gearbox: a linked car turns onto a robot 17 m off-axis and wrecks on it.
## Planted faults (TST-05): the class switch dropped (base Rivet at the same speed must only
## shove), a stomp radius of 0 (no hits), and a car that cannot turn (never reaches the robot).

const RING: int = 6


func run(_tree: SceneTree) -> String:
	var t: PowerTable = PowerTable.load_default()
	if not t.ok():
		return "powers.json: %s" % "; ".join(t.errors())
	var human: Dictionary = _haul_human(t, true)
	if human.has("error"):
		return human["error"]
	var r: Dictionary = {
		"human": human,
		"planted_no_class": _haul_human(t, false),
		"robot": _haul_robot(t, true),
		"planted_robot_base": _haul_robot(t, false),
		"stomp": _stomp(t.hauler),
		"planted_stomp_r0": _stomp(_with(t.hauler, "stomp_radius_m", 0.0)),
		"gearbox": _gearbox(t.gearbox),
		"planted_no_turn": _gearbox(_with(t.gearbox, "turn_dps", 0.0)),
	}
	Log.info("scenario", "souls: %s" % r)
	var err: String = write_evidence("souls-powers.json", r)
	return err if err != "" else _judge(r)


func _judge(r: Dictionary) -> String:
	if r["human"]["knocks"] != 1 or r["planted_no_class"]["knocks"] != 0:
		return "hauler vs human: %s / planted %s" % [r["human"], r["planted_no_class"]]
	if r["robot"]["result"] != "knockdown" or r["planted_robot_base"]["result"] != "blocked":
		return "hauler vs robot: %s / planted %s" % [r["robot"], r["planted_robot_base"]]
	if r["stomp"]["hits"] != RING or r["planted_stomp_r0"]["hits"] != 0:
		return "stomp: %s / planted %s" % [r["stomp"], r["planted_stomp_r0"]]
	if not r["gearbox"]["crashed"] or r["planted_no_turn"]["crashed"]:
		return "gearbox: %s / planted %s" % [r["gearbox"], r["planted_no_turn"]]
	return ""


func _rig(t: PowerTable, on: bool) -> HaulerForm:
	var p: SoulPowers = SoulPowers.new(t)
	var h: HaulerForm = HaulerForm.new(t.hauler)
	h.bind(p)
	if on and p.try_activate(&"hauler") != SoulPowers.OK:
		return null
	return h


func _haul_human(t: PowerTable, on: bool) -> Dictionary:
	var st: BodiesStage = BodiesStage.new()
	var err: String = st.setup(20.0)
	if err != "":
		return {"error": err}
	var slot: int = st.stand(st.band + Vector2(6.0, 0.13))
	var h: HaulerForm = _rig(t, on)
	st.body.body_class = h.body_class
	var downed: bool = false
	for i: int in 3 * SimClock.TICK_RATE:
		h.step(Vector2.RIGHT)
		st.tick(h.vel)
		var p: PackedFloat64Array = st.person(slot)
		downed = downed or (not p.is_empty() and int(p[1]) == SimConst.M_DOWN)
	return {"knocks": st.knocks.size(), "downed": downed, "class": String(h.body_class)}


func _haul_robot(t: PowerTable, on: bool) -> Dictionary:
	var h: HaulerForm = _rig(t, on)
	var table: BodyTable = BodyTable.load_default()
	var rivet: Vector2 = Vector2.ZERO
	var robot: Vector2 = Vector2(6.0, 0.0)
	for i: int in 3 * SimClock.TICK_RATE:
		h.step(Vector2.RIGHT)
		var want: Vector2 = rivet + h.vel * SimClock.TICK_DT
		var c: BodyContact = BodyContact.resolve(
			table, h.body_class, &"robot", PackedVector2Array([want, robot]), h.vel
		)
		rivet = c.a_pos
		robot = c.b_pos
		if c.result != &"":
			return {"result": String(c.result), "at_mps": h.vel.length(), "t_s": i / 60.0}
	return {"result": "none"}


func _stomp(tuning: Dictionary) -> Dictionary:
	var t: PowerTable = PowerTable.load_default()
	t.hauler = tuning
	var h: HaulerForm = _rig(t, true)
	var pts: Array[Vector2] = [Vector2(7.0, 0.0), Vector2(0.0, -8.0)]
	for i: int in RING:
		pts.push_back(Vector2.from_angle(TAU * i / RING) * 2.0)
	var bodies: PackedVector2Array = PackedVector2Array(pts)
	return {"hits": h.stomp(Vector2.ZERO, bodies).size()}


func _gearbox(tuning: Dictionary) -> Dictionary:
	var g: GearboxLink = GearboxLink.new(tuning)
	var robot: Vector2 = Vector2(12.0, 12.0)
	var car: int = g.pick(Vector2.ZERO, Vector2(4.0, 0.5), PackedVector2Array([Vector2(4, 0)]))
	if not g.link(car, Vector2(4.0, 0.0), 0.0):
		return {"crashed": false, "linked": false}
	for i: int in 6 * SimClock.TICK_RATE:
		g.step(robot)
		if g.pos.distance_to(robot) < 1.4 and g.contact():
			return {"crashed": true, "t_s": i / 60.0, "mps": g.speed}
	return {"crashed": false, "closest_m": g.pos.distance_to(robot)}


func _with(tuning: Dictionary, key: String, value: float) -> Dictionary:
	var d: Dictionary = tuning.duplicate()
	d[key] = value
	return d
