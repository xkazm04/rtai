class_name BotArsenal
extends RefCounted

var _guns: WeaponTable = WeaponTable.shipped()


func observe(view: BotView, stage: ArenaStage, street: bool) -> void:
	view.held_slots().clear()
	var carry: RivetCarry = stage.pilot.carry if stage.pilot != null else null
	if street and carry != null and stage.pilot.wheel != null:
		var wheel: RivetWheel = stage.pilot.wheel
		var order: Array[StringName] = wheel.order()
		view.player().wheel_size = order.size()
		view.player().current_slot = order.find(wheel.selected())
		for i: int in range(1, order.size()):
			_add_slot(view, stage, i, order[i], carry.melee_ids.has(order[i]))
		return
	view.player().wheel_size = 0
	view.player().current_slot = carry.current if carry != null else -1
	if carry != null:
		for i: int in carry.slots.size():
			if carry.slots[i] != &"":
				_add_slot(view, stage, i, carry.slots[i], carry.melee_ids.has(carry.slots[i]))
	if view.player().current_slot < 0 and stage.arena.rivet.weapon != &"":
		_add_slot(view, stage, -1, stage.arena.rivet.weapon, false)


static func attack(
	view: BotView,
	intent: GauntletBot.Intent,
	foe: BotView.Hostile,
	slot: BotView.Slot,
	error: float
) -> void:
	var me: BotView.Player = view.player()
	var distance: float = intent.reach
	intent.aim = intent.aim.rotated(deg_to_rad(error))
	if (
		me.form == &"dent"
		and me.seized_car_pos == Vector2.INF
		and me.pos.distance_to(me.car_pos) <= BotForms.DENT_M
	):
		intent.aim = me.pos.direction_to(me.car_pos)
		intent.attack = &"fire"
	elif me.form == &"dent" and me.seized_car_pos.distance_to(foe.pos) <= BotForms.HEAVY_M:
		intent.attack = &"melee"
	elif distance <= maxf(GauntletBot.MELEE_M, BotForms.reach(me.form)):
		if me.form != &"kerf" or view.blink_clear(intent.aim):
			intent.attack = &"melee"
		elif slot != null and not slot.melee:
			intent.attack = &"fire"
	elif slot != null and not slot.melee and distance <= slot.reach:
		intent.attack = &"fire"


static func best_gun(view: BotView, distance: float) -> BotView.Slot:
	var best: BotView.Slot = null
	for slot: BotView.Slot in view.held_slots():
		if slot.melee or slot.reach < distance:
			continue
		if (
			slot.splash_m > 0.0
			and distance <= slot.splash_m + view.player().radius + view.player().blast_margin
		):
			continue
		if best == null or slot.damage_per_tick > best.damage_per_tick:
			best = slot
	return best


func _add_slot(view: BotView, stage: ArenaStage, index: int, id: StringName, melee: bool) -> void:
	var slot: BotView.Slot = BotView.Slot.new()
	slot.index = index
	if view.player().wheel_size == 0 and index >= 0:
		slot.action = RivetCarry.SLOT_ACTIONS[index]
	slot.melee = melee
	if melee:
		slot.reach = GauntletBot.MELEE_M
	elif stage.arena.tuning.weapons.has(id):
		var gun: CombatTuning.Weapon = stage.arena.tuning.weapon(id)
		slot.reach = gun.range_m
		slot.damage_per_tick = gun.damage * gun.burst / maxi(gun.cooldown_ticks, 1)
	elif _guns.weapons.has(id):
		slot.reach = _guns.weapon(id).range_m
	else:
		return
	if not melee and _guns.weapons.has(id):
		var spec: WeaponSpec = _guns.weapon(id)
		slot.splash_m = spec.splash_radius_m
		var human_hp: float = _guns.target_hp[&"human"]
		slot.damage_per_tick = spec.damage * spec.pellets / (spec.interval_ticks * human_hp)
	view.held_slots().append(slot)


## A slot edge and fire can arrive together. The wheel advances just one slot per edge.
static func clear_shot(
	view: BotView, intent: GauntletBot.Intent, actions: PlayerActions, margin: float
) -> bool:
	var me: BotView.Player = view.player()
	var next: int = me.current_slot
	if intent.slot != &"":
		for slot: BotView.Slot in view.held_slots():
			if slot.action == intent.slot:
				next = slot.index
				break
		if me.wheel_size > 0:
			var step: int = 1 if intent.slot == &"weapon_next" else -1
			next = posmod(me.current_slot + step, me.wheel_size)
	var radius: float = 0.0
	for held: BotView.Slot in view.held_slots():
		if held.index == me.current_slot or held.index == next:
			radius = maxf(radius, held.splash_m)
	if radius <= 0.0:
		return true
	var clearance: float = radius + me.radius + margin
	if intent.reach <= clearance:
		return false
	# Trace the unsafe part of the packed firing ray, including the sampled aim error.
	var step_rad: float = TAU / actions.aim_steps
	var ray: Vector2 = Vector2.RIGHT.rotated(snappedf(intent.aim.angle(), step_rad))
	var end: Vector2 = me.pos + ray * clearance
	if not view.clear_line(me.pos, end):
		return false
	for foe: BotView.Hostile in view.hostiles():
		if not foe.alive:
			continue
		var near: Vector2 = Geometry2D.get_closest_point_to_segment(foe.pos, me.pos, end)
		if near.distance_squared_to(foe.pos) <= foe.radius * foe.radius:
			return false
	return true
