class_name FoeLooks
extends RefCounted
## Gauntlet placeholders reuse the blue plate carrier and the gunmetal machine parts.


static func wears_swat(id: StringName) -> bool:
	return id in [&"swat", &"rocket_trooper"]


static func robot_plan(id: StringName, plan: BodyPlan) -> BodyPlan:
	match id:
		&"sentry_turret":
			plan.size_k = 0.88
			plan.thigh_len *= 0.5
			plan.shin_len *= 0.5
		&"shield_robot":
			plan.size_k = 1.18
			plan.arm_w *= 1.45
		&"war_machine":
			plan.size_k = 1.65
	return plan
