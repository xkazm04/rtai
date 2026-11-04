class_name ShockArcsView
extends Node2D
## The electro gun's arcs crawling over every stunned human (ShockJolt.arcs), drawn above the
## rigs (the fight's fx layer sits under them, where arcs on the body were hidden), centred on
## the victim rig's drawn torso so they ride its convulsion. Reads the arena's stun state on its
## tick; render only.

var arena: CombatArena = null
var rigs: CharacterRigs = null


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if arena == null or arena.areas == null or rigs == null:
		return
	for h: Fighter in arena.hostiles:
		var e: FighterFx = arena.areas.effect(h)
		if e == null or not h.alive() or e.stun_ticks <= 0:
			continue
		var rig: CutRig = rigs.rig_for(h.id)
		if rig == null or rig.torso == null:
			continue
		var c: Vector2 = to_local(rig.torso.global_position)
		var ppm: float = Ink.PX_PER_M * rig.global_transform.get_scale().x / CutRig.SC
		ShockJolt.arcs(self, c, ppm, arena.tick + h.id)
