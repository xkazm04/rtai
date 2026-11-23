class_name PlayerMotionTable
extends RefCounted
## Loads the authored sprint, roll, vault and cover tuning into a fresh fixed-tick mover.


static func read(t: DataTable) -> PlayerMotion:
	var m: PlayerMotion = PlayerMotion.new()
	var s: Dictionary = t.object(t.raw, "sprint")
	m.sprint_mps = t.num(s, "sprint_mps")
	m.sprint_accel_mps2 = t.num(s, "accel_mps2")
	m.sprint_turn_dps = t.num(s, "turn_dps")
	m.min_forward_dot = t.num(s, "min_forward_dot")
	var r: Dictionary = t.object(t.raw, "roll")
	m.roll_m = t.num(r, "roll_m")
	m.roll_ticks = maxi(t.integer(r, "roll_ticks"), 1)
	m.iframe_from = t.integer(r, "iframe_from")
	m.iframe_to = t.integer(r, "iframe_to")
	m.recovery_ticks = t.integer(r, "recovery_ticks")
	m.recovery_move_scale = t.num(r, "recovery_move_scale")
	m.cooldown_ticks = t.integer(r, "cooldown_ticks")
	m.exit_speed_k = t.num(r, "exit_speed_k")
	m.face_aim = t.raw.get("face_aim", true) == true
	m.dash.configure(t)
	m.cover.configure(t)
	m.errors = m.vault.configure(t)
	if m.iframe_to >= m.roll_ticks:
		m.errors.append("rivet_motion.json: roll.iframe_to must be inside roll_ticks")
	return m
