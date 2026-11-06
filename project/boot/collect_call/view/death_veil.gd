class_name DeathVeil
extends ColorRect
## Rivet's death beat on screen (owner, d8): the frame goes to the print's ink over the beat's
## last DeathBeat.FADE_IN_S, so the respawn cut lands in the dark, and lifts over FADE_OUT_S.
## Under the HUD (first child of its layer), render only: it reads the stage's DeathBeat.

var stage: CollectCallStage = null


static func over(p_stage: CollectCallStage) -> DeathVeil:
	var v: DeathVeil = DeathVeil.new()
	v.stage = p_stage
	return v


func _ready() -> void:
	color = Ink.INK
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	modulate.a = 0.0


func _process(_delta: float) -> void:
	var beat: DeathBeat = stage.death_beat if stage != null else null
	modulate.a = beat.veil() if beat != null else 0.0
	visible = modulate.a > 0.0
