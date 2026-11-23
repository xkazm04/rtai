class_name CastMulroneyPreview
extends RefCounted
## Admit the review subject for this dev process only. The shipping row stays gated by the audit.

const ID: StringName = &"sergeant_mulroney"


static func enable() -> void:
	var table: DataTable = DataTable.open(CastCards.TABLE, CastCards.SCHEMA)
	table.raw.archetypes.sergeant_mulroney.enabled = true
	CastCards._library = CastCards.from_table(table)


static func hide_dress(scene: Node) -> void:
	for item: Node in scene.find_children("*", "Node2D", true, false):
		if item is PrologueCommanderDress:
			(item as Node2D).self_modulate.a = 0.0
