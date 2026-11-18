extends "res://dev/frames/quest1_clip_rec.gd"

var clip: bool = false


func _run() -> void:
	var session: Quest1Session = _game.session
	var arena: CombatArena = session.stage.arena
	while session.tick() < 20000 and arena.rivet.weapon != &"assault-rifle":
		_driver.act()
		session.step()
	_driver.release()
	if arena.rivet.weapon != &"assault-rifle":
		Log.error("clip", "Quest rifle pickup was not reached")
		get_tree().quit(1)
		return
	await _warm()
	for octant: int in 8:
		if not await _octant(octant, session, arena):
			get_tree().quit(1)
			return
	_driver.release()
	get_tree().quit(0)


func _octant(octant: int, session: Quest1Session, arena: CombatArena) -> bool:
	var aim: Vector2 = Vector2.from_angle(octant * PI / 4.0)
	_driver._axis(JOY_AXIS_RIGHT_X, aim.x)
	_driver._axis(JOY_AXIS_RIGHT_Y, aim.y)
	_driver._axis(JOY_AXIS_TRIGGER_RIGHT, 0.0)
	Input.flush_buffered_events()
	var initial: int = arena.rifle_ammo
	var fired: bool = false
	for tick: int in 80 if clip else 48:
		if tick == 36:
			_driver._axis(JOY_AXIS_TRIGGER_RIGHT, 1.0)
			Input.flush_buffered_events()
		if fired:
			_driver._axis(JOY_AXIS_TRIGGER_RIGHT, 0.0)
			Input.flush_buffered_events()
		session.step()
		await get_tree().process_frame
		if clip and tick % 4 == 0:
			await _save("clip_%04d" % (octant * 20 + tick / 4.0))
		if tick == 35:
			await _record(octant, "rest")
		if not fired and arena.rifle_ammo < initial:
			await _record(octant, "fire")
			fired = true
			if not clip:
				break
	Log.info("clip", "octant %d ammo %d -> %d" % [octant, initial, arena.rifle_ammo])
	return fired and arena.rivet.weapon == &"assault-rifle"


func _record(octant: int, pose: String) -> void:
	var label: String = "oct%d_%s" % [octant, pose]
	await _save(label)
	for node: Node in _game.find_children("*", "Node2D", true, false):
		var held: RivetHeldView = node as RivetHeldView
		if held == null:
			continue
		var rig: CutRig = held.rigs.rig_for(held.rivet_id)
		if rig == null or rig.head_card == null:
			return
		var card: Sprite2D = rig.head_card
		var sprite: Sprite2D = (
			held._sprite if held._sprite != null and held._sprite.visible else card
		)
		if sprite.texture != null:
			var path: String = sprite.texture.resource_path
			var pos: Vector2 = card.get_global_transform_with_canvas().origin
			Log.info(
				"clip", "%s %s cell %d flip %s at %s" % [label, path, card.frame, card.flip_h, pos]
			)
		return
