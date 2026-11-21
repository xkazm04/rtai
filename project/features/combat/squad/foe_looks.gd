class_name FoeLooks
extends RefCounted
## Gauntlet placeholders reuse the blue plate carrier and the gunmetal machine parts.


static func wears_swat(id: StringName) -> bool:
	return id in [&"swat", &"rocket_trooper"]


static func robot_plan(id: StringName, plan: BodyPlan, rig: CanvasItem = null) -> BodyPlan:
	match id:
		&"sentry_turret":
			if rig != null:
				rig.modulate.a = 0.0
		&"shield_robot":
			plan.size_k = 1.18 * FoeShieldView.LOOK_SCALE
			plan.arm_w *= 1.45
		&"war_machine":
			plan.size_k = 1.65 * FoeWalkerView.LOOK_SCALE
			# Tuck the thug's long claw arms into the cannon cradle.
			plan.upper_len *= 0.65
			plan.upper_draw *= 0.65
			for side: int in 2:
				plan.fore_len[side] *= 0.65
				plan.fore_draw[side] *= 0.65
				plan.hand_ready[side] = plan.shoulder[side].lerp(plan.hand_ready[side], 0.65)
				plan.hand_relax[side] = plan.shoulder[side].lerp(plan.hand_relax[side], 0.65)
	return plan
