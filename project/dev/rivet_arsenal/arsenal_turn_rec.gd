extends Node
## Run the arena's normal pilot, carry, trigger and view. Only the input source is scripted.
const EQUIP_STEPS: int = 6

var boss: StringName
var weapon: StringName
var out_dir: String
var view_id: String
var clip: bool
var _game: ArenaGame
var _pad: TurnPad = TurnPad.new()
var _arena: CombatArena
var _frame: int = 0
var _failed: bool = false


func has_boss(id: StringName) -> bool:
	return BossSpec.ids().has(id)


func _ready() -> void:
	var table: ArsenalTable = ArsenalTable.shipped()
	if weapon != RivetWheel.HANDS and table.grip_of(weapon) == null:
		Log.error("turn", "unknown arsenal id " + String(weapon))
		get_tree().quit(2)
		return
	ViewMode.select(view_id)
	_game = ArenaGame.new()
	add_child(_game)
	_game.hud.hide()
	var session: ArenaSession = _game.session
	session.world.set_process(false)
	session.world.loop().set_input(_pad)
	_pad.actions = session.actions
	_arena = session.stage.arena
	if boss == &"":
		_arena.rivet.pos = session.plan.area("boulevard").rect.get_center()
	var carry: RivetCarry = session.pilot.carry
	if carry == null:
		carry = RivetCarry.new(
			WeaponTable.shipped(), table, session.world.context().rng.stream(&"turn")
		)
		session.pilot.carry = carry
	if weapon == RivetWheel.HANDS:
		carry.current = -1
		_arena.rivet.weapon = &""
		_arena.gun = null
	elif carry.carries(weapon):
		carry.take(weapon, _arena)
		await _equip(carry.slots.find(weapon))
	else:
		_arena.rivet.weapon = weapon
		_arena.gun = null
		_arena.rifle_ammo = _arena.tuning.weapon(weapon).magazine
	await _record()


## The slot key is pressed on the first equip step only.
static func slot_on_step(step: int, slot: int) -> int:
	return slot if step == 0 else -1


## `take` selects nothing under wheel_inventory and the first wheel step stows the gun.
func _equip(slot: int) -> void:
	for i: int in EQUIP_STEPS:
		_pad.slot = slot_on_step(i, slot)
		await _step()


func _record() -> void:
	for octant: int in 8:
		if not await _octant(octant):
			Log.error("turn", "no attack for %s at octant %d" % [weapon, octant])
			get_tree().quit(1)
			return
	await _reload()
	get_tree().quit(1 if _failed else 0)


func _octant(octant: int) -> bool:
	_pad.aim = Vector2.from_angle(octant * PI / 4.0)
	# A shallow diagonal tube still aims inside this octant at 38 degrees.
	if weapon == &"rocket_launcher" and octant % 2 == 1:
		_pad.aim.y *= tan(deg_to_rad(38.0))
	_pad.fire = false
	var gun: GunHand = _arena.gun
	if gun != null and gun.trigger.ammo == 0:
		gun.trigger.start_reload()
	for tick: int in 600:
		await _step()
		if (
			tick >= 35
			and (gun == null or (not gun.trigger.reloading() and gun.trigger.cooldown == 0))
		):
			break
	await _save("oct%d_rest" % octant, true)
	var initial: int = _attack_count()
	var fired: bool = false
	for tick: int in 180:
		_pad.fire = tick >= 28 and not fired
		await _step()
		if not fired and _attack_count() != initial:
			await _save("oct%d_fire" % octant, true)
			fired = true
		if clip and tick % 4 == 0 and (tick < 80 or not fired):
			await _save("clip_%04d" % _frame, false)
			_frame += 1
		if fired and (not clip or tick >= 79):
			break
	_pad.fire = false
	return fired and _arena.rivet.weapon == weapon


func _attack_count() -> int:
	if _game.session.pilot.wielding():
		return _game.session.pilot.melee_swings
	return _arena.gun.shots_fired if _arena.gun != null else -_arena.rifle_ammo


func _step() -> void:
	_game.session.step()
	await get_tree().process_frame


func _reload() -> void:
	var gun: GunHand = _arena.gun
	if gun == null or clip:
		return
	_pad.aim = Vector2(1.0, 1.0).normalized()
	gun.trigger.start_reload()
	for tick: int in gun.trigger.spec.reload_ticks + 1:
		await _step()
		var phase: float = _game.session.pilot.hold.table.reload_phase(gun)
		if phase >= 1.1 and phase < 2.0:
			await _save("reload", true)
			if view_id == "top":
				_log_magazine()
			return


func _log_magazine() -> void:
	for node: Node in _game.find_children("*", "Node2D", true, false):
		if node is WeaponMagView:
			var sprite: Sprite2D = (node as WeaponMagView)._mag
			if sprite != null and sprite.is_visible_in_tree():
				Log.info("turn", "visible magazine " + sprite.texture.resource_path)
		if node is RivetMagView:
			Log.info("turn", "placeholder held: " + str((node as RivetMagView)._held))


func _save(stem: String, still: bool) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	if boss != &"" and not clip and stem.ends_with("_fire"):
		if image.save_png(out_dir.path_join(stem + "_arena.png")) != OK:
			_failed = true
	var rig: CutRig = _game.cast.rigs.rig_for(_arena.rivet.id)
	var scale_px: Vector2 = Vector2(image.get_size()) / get_viewport().get_visible_rect().size
	var foot: Vector2 = rig.get_global_transform_with_canvas().origin * scale_px
	var size: Vector2i = Vector2i(404, 294) if still else Vector2i(640, 360)
	var base: int = (94 if view_id == "top" else 214) if still else 212
	image = image.get_region(Rect2i(Vector2i(foot) - Vector2i(size.x >> 1, base), size))
	if image.save_png(out_dir.path_join(stem + ".png")) != OK:
		Log.error("turn", "cannot write " + stem)
		_failed = true


class TurnPad:
	extends InputSource

	var actions: PlayerActions
	var aim: Vector2 = Vector2.RIGHT
	var fire: bool = false
	var slot: int = -1
	var move: Vector2i = Vector2i.ZERO
	var sprint: bool = false

	func sample(_tick: int) -> TickInput:
		var bits: int = PlayerCommand.pack_aim(aim, actions)
		if fire:
			bits |= 1 << actions.bit(&"fire")
		if slot >= 0:
			bits |= 1 << actions.bit(RivetCarry.SLOT_ACTIONS[slot])
		if sprint:
			bits |= 1 << actions.bit(&"sprint")
		return TickInput.new(bits, move.x, move.y)
