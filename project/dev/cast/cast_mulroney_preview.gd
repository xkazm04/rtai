class_name CastMulroneyPreview
extends RefCounted
## Admit the review subject for this dev process only. The shipping row stays gated by the audit.

const ID: StringName = &"sergeant_mulroney"


static func enable() -> void:
	var table: DataTable = DataTable.open(CastCards.TABLE, CastCards.SCHEMA)
	table.raw.archetypes.sergeant_mulroney.enabled = true
	CastCards._library = CastCards.from_table(table)


## Sample the displayed texels and the shadow's ground point after the renderer has posed.
static func trace(rig: CutRig, tick: int) -> void:
	if not LaunchArgs.has("--cast-mulroney-trace") or rig == null or rig.head_card == null:
		return
	var sample: Dictionary = CastFeetFrame.sample_sprite(rig.head_card)
	var xf: Transform2D = rig.get_viewport().get_canvas_transform()
	var ground: Vector2 = xf * (rig.global_position + RigCastShadows.card_push(rig))
	sample["ground"] = [ground.x, ground.y]
	sample["tick"] = tick
	sample["moving"] = rig.speed_now > StreetWalkerCards.MOVING
	Log.info("cast-trace", JSON.stringify(sample, "", false, true))


static func hide_dress(scene: Node) -> void:
	for item: Node in scene.find_children("*", "Node2D", true, false):
		if item is PrologueCommanderDress:
			(item as Node2D).self_modulate.a = 0.0
