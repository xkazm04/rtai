class_name RigLimbs
extends RefCounted
## The parts and the planted-foot state of one side of a rig (L or R).

var thigh: Sprite2D = null
var shin: Sprite2D = null
var foot: Sprite2D = null
var upper: Sprite2D = null
var fore: Sprite2D = null
var hand: Sprite2D = null
var shield: Sprite2D = null

## The foot in world px, where the current step started, and the step's progress.
var foot_w: Vector2 = Vector2.ZERO
var foot_from: Vector2 = Vector2.ZERO
var stepping: bool = false
var timed: bool = false
var step_t: float = 0.0
var lift: float = 0.0
## The cells shown now, so a part's texture is swapped only when its cell changes.
var foot_cell: String = ""
var upper_cell: String = ""
var fore_cell: String = ""
var hand_cell: String = ""
var j_shoulder: Vector2 = Vector2.ZERO
var j_elbow: Vector2 = Vector2.ZERO
var j_hand: Vector2 = Vector2.ZERO


func plant(at: Vector2) -> void:
	foot_w = at
	foot_from = at
	stepping = false
	timed = false
	step_t = 0.0
	lift = 0.0
