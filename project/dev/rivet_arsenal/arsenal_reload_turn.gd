extends "arsenal_turn_rec.gd"
## Dev-only reload evidence on the same live arena, input and camera as the turn kit.


func _record() -> void:
	var ok: bool = await _reload_clip() if clip else await _reload_stills()
	get_tree().quit(0 if ok and not _failed else 1)


## Capture the equipped fallback in historical trees at the same aim and phase.
func _reload_stills() -> bool:
	if _arena.gun == null:
		return false
	for octant: int in [2, 1, 0, 7, 6, 3, 4, 5]:
		_pad.aim = Vector2.from_angle(octant * PI / 4.0)
		var trigger: Trigger = _arena.gun.trigger
		for tick: int in 240:
			_pad.fire = tick % 2 == 0
			await _step()
			if trigger.ammo < trigger.spec.magazine:
				break
		_pad.fire = false
		trigger.start_reload()
		var phases: int = 0
		while trigger.reloading():
			await _step()
			var k: float = _game.session.pilot.hold.table.reload_phase(_arena.gun)
			if k >= 0.0 and int(k) == phases and fmod(k, 1.0) >= 0.25:
				await _reload_frame(octant, phases)
				phases += 1
		if phases != 3:
			Log.error("turn", "missing reload phase at octant %d" % octant)
			return false
	return true


func _reload_frame(octant: int, phase: int) -> void:
	if octant == 1:
		await _save("reload%d" % (5 + phase), true)
		if phase == 1:
			await _save("reload", true)
			if view_id == "top":
				_log_magazine()
		if phase == 0:
			# SE uses the three phase cells in play. Inspect its authored cell 1
			# on the same standing card for the contact sheet.
			var rig: CutRig = _game.cast.rigs.rig_for(_arena.rivet.id)
			var card: Sprite2D = rig.head_card
			if not RivetReload.shows(card):
				await _save("reload1", true)
				return
			var previous: int = card.frame
			card.frame = 1
			await _save("reload1", true)
			card.frame = previous
	elif phase == 1:
		var slot: int = 8 + octant - 3 if octant in [3, 4, 5] else RivetFrames.EQ_OCT[octant]
		await _save("reload%d" % slot, true)


func _reload_clip() -> bool:
	if _arena.gun == null:
		return false
	var trigger: Trigger = _arena.gun.trigger
	var empty: bool = false
	var loaded: bool = false
	for tick: int in 1800:
		_pad.aim = Vector2.from_angle(float(tick) * TAU / 420.0)
		_pad.fire = not empty and tick >= 24 and (trigger.spec.auto or tick % 4 < 2)
		await _step()
		empty = empty or (trigger.ammo == 0 and trigger.reloading())
		loaded = loaded or (empty and trigger.ammo == trigger.spec.magazine)
		if tick % 4 == 0:
			await _save("clip_%04d" % _frame, false)
			_frame += 1
		if loaded and tick >= 639:
			Log.info("turn", "empty and replenished %s to %d" % [weapon, trigger.ammo])
			return true
	Log.error("turn", "missing complete empty and reload cycle for " + String(weapon))
	return false
