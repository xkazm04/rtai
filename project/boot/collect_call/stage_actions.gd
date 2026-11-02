class_name StageActions
extends RefCounted
## What one interact press does on the stage, nearest use first: pick up a payphone (Patch's
## heat rule), climb in or out of a hide spot, torch the crate stack (once Mertz is down), grab
## a dropped rifle. A press none of these takes is left for the quest (meeting the allies).

const PHONE_REACH_M: float = 1.7
const RIFLE_REACH_M: float = 1.5


## true when the stage used the press.
static func interact(stage: CollectCallStage) -> bool:
	var at: Vector2 = stage.arena.rivet.pos
	for phone: String in stage.layout.phones:
		if at.distance_to(stage.layout.phones[phone]) <= PHONE_REACH_M:
			_pick_up(stage, phone)
			return true
	if stage.hidden_in != "":
		stage.hidden_in = ""
		return true
	for spot: String in stage.layout.hide_at:
		if at.distance_to(stage.layout.hide_at[spot]) <= stage.layout.hide_r[spot]:
			stage.hidden_in = spot
			stage.hidden_ticks = 0
			stage.arena.rivet.pos = stage.layout.hide_at[spot]
			return true
	if _can_torch(stage, at):
		stage.ignite()
		return true
	return stage.arena.grab_rifle(RIFLE_REACH_M)


static func _pick_up(stage: CollectCallStage, phone: String) -> void:
	var got: PayphoneRouter.Pickup = stage.router.pick_up(phone, stage.heat.level)
	if got == PayphoneRouter.Pickup.REFUSED_HOT:
		stage.refusal_left = stage.layout.refusal_ticks
		Log.info(
			"payphone", "Patch refused a hot caller at %s (heat %d)" % [phone, stage.heat.level]
		)
	elif got == PayphoneRouter.Pickup.CONNECTED:
		Log.info("payphone", "Patch connected the call at %s" % phone)


static func _can_torch(stage: CollectCallStage, at: Vector2) -> bool:
	var boss_down: bool = stage.arena.boss != null and not stage.arena.boss.alive()
	var near: bool = at.distance_to(stage.layout.crates_at) <= stage.layout.torch_reach_m
	return boss_down and near and not stage.crates_burning
