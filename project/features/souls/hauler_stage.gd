class_name HaulerStage
extends RefCounted
## The Hauler on quest 1's stage and the arena (which extends it), for the bound player:
## StagePilot hands it the decoded presses each tick. power_hauler (Q / LB) turns Rivet into the
## ghost tank; while on, his move intent steers the tank's heavy movement (turn limit, momentum),
## the melee press arms the stomp instead of the jab, a due stomp hurts and throws every live
## hostile in its radius, and a ram (above ram_mps) hurts whoever the tank touches.

const ID: StringName = &"hauler"

var powers: SoulPowers
var form: HaulerForm
## The tick the last stomp landed (-1 = none) and where (the view's crack and ring).
var stomp_tick: int = -1
var stomp_at: Vector2 = Vector2.ZERO
var stomp_hits: int = 0
var ram_hits: int = 0
var activations: int = 0
var ticks_on: int = 0
var _rammed: Dictionary[int, bool] = {}


func _init(table: PowerTable) -> void:
	powers = SoulPowers.new(table)
	form = HaulerForm.new(table.hauler)
	form.bind(powers)


static func shipped() -> HaulerStage:
	return HaulerStage.new(PowerTable.load_default())


## One tick. `move_by` is the pilot's walk this tick (m); returns the move to use instead.
## `melee` true = the pilot's melee press (the stomp takes it while the tank is on).
func drive(stage: CollectCallStage, power: bool, melee: bool, move_by: Vector2) -> Vector2:
	if power and stage.arena.rivet.alive() and powers.try_activate(ID) == &"ok":
		activations += 1
	powers.tick()
	var want: Vector2 = move_by.normalized() if move_by.length() > 0.0001 else Vector2.ZERO
	form.step(want if form.on else Vector2.ZERO)
	if not form.on:
		form.vel = Vector2.ZERO
		_rammed.clear()
		return move_by
	ticks_on += 1
	if melee:
		@warning_ignore("return_value_discarded")
		form.arm()
	if form.stomp_due():
		_stomp(stage)
	_ram(stage)
	return form.vel * SimClock.TICK_DT


## True while the tank owns the melee press (the pilot skips the jab).
func owns_melee() -> bool:
	return form.on


func _stomp(stage: CollectCallStage) -> void:
	var at: Vector2 = stage.arena.rivet.pos
	var live: Array[Fighter] = []
	var spots: PackedVector2Array = PackedVector2Array()
	for h: Fighter in stage.arena.hostiles:
		if h.alive():
			live.append(h)
			@warning_ignore("return_value_discarded")
			spots.push_back(h.pos)
	stomp_tick = stage.tick
	stomp_at = at
	for hit: Dictionary in form.stomp(at, spots):
		var idx: int = hit["i"]
		var push: Vector2 = hit["push"]
		var h: Fighter = live[idx]
		h.pos += push
		stage.arena.damage(h, form.num(&"stomp_damage"), stage.arena.rivet.id, &"stomp")
		stomp_hits += 1


func _ram(stage: CollectCallStage) -> void:
	if not form.ramming():
		return
	var at: Vector2 = stage.arena.rivet.pos
	var reach: float = ArenaBodies.table().radius(form.body_class)
	for h: Fighter in stage.arena.hostiles:
		if not h.alive() or _rammed.has(h.id):
			continue
		var to: Vector2 = h.pos - at
		if to.length() > reach + h.radius_m:
			continue
		_rammed[h.id] = true
		h.pos += to.normalized() * form.num(&"stomp_knock_m")
		stage.arena.damage(h, form.num(&"ram_damage"), stage.arena.rivet.id, &"ram")
		ram_hits += 1


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(stomp_tick)
	out.put_32(stomp_hits)
	out.put_32(ram_hits)
	out.put_32(ticks_on)
	out.put_float(form.vel.x)
	out.put_float(form.vel.y)
