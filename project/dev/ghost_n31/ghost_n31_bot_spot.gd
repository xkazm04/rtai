class_name GhostN31BotSpot
extends GhostDeployBotSpot
## n31 measure (dev only): the shipped spot scorer with a relaxed fit, so the bot deploys Ohm and
## Kerf in early waves the way a player would. Ohm fires at 3+ bodies inside his circle, Kerf at
## any target; Tonnage and Dent keep the shipped rules.


func _fits(bodies: int, machines: int, special: bool) -> bool:
	if _form == OhmStage.GHOST:
		return bodies >= 3
	return super._fits(bodies, machines, special)


func _kerf() -> Vector2:
	_require_fit = false
	return super._kerf()


## Swap the spot scorer the shipped bot built inside the pilot (private fields, dev only).
static func install(pilot: GauntletPilot) -> bool:
	var brain: Object = pilot.get("_brain")
	var deploy: Object = brain.get("_deploy") if brain != null else null
	var old: GhostDeployBotSpot = deploy.get("_spots") if deploy != null else null
	if old == null:
		return false
	deploy.set("_spots", GhostN31BotSpot.new(old._stage, old._actions))
	return true
