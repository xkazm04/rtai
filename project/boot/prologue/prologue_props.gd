class_name PrologueProps
extends Node2D
## The lieutenant carries the King's megaphone. A stretched cop baton reads as a pole
## at 32 px/m. Both sit on the live officer's rig when it is in the full-rig bubble.

const HORN: Texture2D = preload("res://features/characters/art/king/megaphone.png")
const POLE: Texture2D = preload("res://features/characters/art/cop/baton.png")

var patrol: ProloguePatrol
var rigs: CharacterRigs


func _process(_dt: float) -> void:
	queue_redraw()


func _draw() -> void:
	for officer: ProloguePatrol.Officer in patrol.officers:
		var body: Fighter = officer.body
		var dale: bool = body == patrol.dale
		if not body.alive() or (not dale and body.archetype != &"appliance_warden"):
			continue
		var ppm: float = SimConst.PX_PER_M
		var at: Vector2 = (body.pos + body.facing * 0.35) * ppm
		var rig: CutRig = rigs.rig_for(body.id)
		if rig != null and rig.is_visible_in_tree():
			at = to_local(rig.torso.to_global(rig.sides[BodyPlan.R].j_hand))
		var size_m: Vector2 = Vector2(0.95, 0.65) if dale else Vector2(1.8, 0.19)
		draw_set_transform(at, body.facing.angle())
		draw_texture_rect(
			HORN if dale else POLE, Rect2(-size_m * Vector2(0.2, 0.5) * ppm, size_m * ppm), false
		)
	draw_set_transform(Vector2.ZERO)
