class_name MeleeKillGear
extends RefCounted
## Loose equipment rides the existing gib pool. Each shield half samples one side of the
## original plate. Its opposite kick leaves daylight between the pieces after the impact.

const ART: String = "res://features/characters/art/view/p70/"
const GUN: String = "res://features/combat/weapons/art/"
const SHIELD: String = ART + "riot_shield_card.png"
const KIT: Dictionary[StringName, String] = {
	&"cap": ART + "cop_patrol_headgear_tumble.png",
	&"helmet": ART + "cop_riot_headgear_tumble.png",
	&"rifle": GUN + "assault_rifle/held.png",
	&"tube": GUN + "rocket_launcher/held.png",
	&"pistol": GUN + "pistol/held.png",
}


static func attach(parts: Array[Node2D], row: SignatureKill, ppm: float) -> void:
	if row.kit.is_empty():
		return
	for part: int in row.pieces:
		if part < SignatureKill.KIT:
			continue
		var sprite: Sprite2D = Sprite2D.new()
		var path: String = KIT[row.kit] if part == SignatureKill.KIT else SHIELD
		sprite.texture = StreetStrips.get_tex(path)
		var rect: Rect2 = Rect2(Vector2.ZERO, sprite.texture.get_size())
		if part == SignatureKill.KIT and row.kit in [&"cap", &"helmet"]:
			rect.size.x = rect.size.y
		if part != SignatureKill.KIT and row.pieces.has(SignatureKill.PLATE_B):
			rect.size.x *= 0.5
			rect.position.x = rect.size.x if part == SignatureKill.PLATE_B else 0.0
		sprite.region_enabled = true
		sprite.region_rect = rect
		var size_m: float = row.kit_m if part == SignatureKill.KIT else row.plate_m
		sprite.scale = Vector2.ONE * size_m * ppm / maxf(rect.size.x, rect.size.y)
		if parts[part] != null:
			parts[part].free()
		var root: Node2D = Node2D.new()
		root.add_child(sprite)
		parts[part] = root
