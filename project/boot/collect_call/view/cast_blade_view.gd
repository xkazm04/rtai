class_name CastBladeView
extends MeleeWeaponView
## n7-melee: quest 1's shipped sprite cast draws Rivet's carried blade (Quest1Session.blade). The
## sprite has no rig hand, so the prop sits at a hand point beside the sprite toward his facing,
## swept by the combo exactly as the rig path's MeleeWeaponView (anticipation, the cut with its
## smear, the settle). Drawn only while the blade is in the claw and his own sprite shows (not
## dead, no ghost form standing in). The rig cast (dev `--rigs`) has RivetHeldView instead.
## View only: headless runs attach nothing, so scenarios and replay are untouched.

## The hand point off the sprite's centre (m): ahead along the facing and out to his gun side.
const HAND_AHEAD_M: float = 0.45
const HAND_SIDE_M: float = 0.4
## A two-hand blade sweeps wider than a one-hand one (the rig clip's values).
const SWEEP_TWO_HAND: float = 1.1
const SWEEP_ONE_HAND: float = 0.7

var stage: CollectCallStage = null
var ppm: float = SimConst.PX_PER_M
var _kind: StringName = &""


## Adds the view to `cc`'s printed actors' layer (as the ghost attack views), over the cast.
static func attach(cc: CollectCallView, p_stage: CollectCallStage) -> CastBladeView:
	var layer: CanvasLayer = GhostAttackViews.layer_of(cc) if cc != null else null
	if layer == null or p_stage == null or p_stage.pilot == null or p_stage.pilot.carry == null:
		return null
	var v: CastBladeView = CastBladeView.new()
	v.stage = p_stage
	v.z_index = RenderLayers.z(&"actors") + 2
	layer.add_child(v)
	return v


func _process(_delta: float) -> void:
	var pilot: StagePilot = stage.pilot
	var rivet: Fighter = stage.arena.rivet
	visible = (pilot.wielding() and rivet.alive() and not StoryForms.stands_in(pilot.ghosts.forms))
	if not visible:
		return
	if _kind != pilot.hold.held:
		_kind = pilot.hold.held
		var table: MeleeTable = MeleeTable.weapon(_kind)
		kind = _kind
		length_px = table.length_m * ppm
		sweep_rad = SWEEP_TWO_HAND if table.grip == &"two_hand" else SWEEP_ONE_HAND
	var face: Vector2 = rivet.facing if rivet.facing != Vector2.ZERO else Vector2.RIGHT
	var hand: Vector2 = rivet.pos + face * HAND_AHEAD_M + face.orthogonal() * -HAND_SIDE_M
	track_at(hand * ppm, face, pilot.melee.combo)
