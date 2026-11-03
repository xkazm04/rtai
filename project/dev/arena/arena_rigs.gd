class_name ArenaRigs
extends Node
## Dev flag --rigs: the arena's fighters drawn on the cast rigs (CharacterRigs, d5-cast) instead of
## quest 1's stills and guard sprites (CastView is hidden). Rivet is the RIVET rig, every hostile
## and dummy a COP rig (the robot and contractor plans land with the enemy-ai and rivet-motion
## merges). Render only: reads the CombatArena every frame and fills the rig feed (world px at
## SimConst.PX_PER_M, the print stage's space); it writes nothing back and draws no RNG.

const DOWN_FLAGS: int = RigFeed.Flag.DEAD | RigFeed.Flag.DOWN

var rigs: CharacterRigs = CharacterRigs.new()
var stage: ArenaStage = null
var _last: Dictionary[int, Vector2] = {}
var _print: PrintStage = null


## Puts the rigs on the view's actor layer and hides the sprite cast; false when the view is not
## the printed path (the rigs need its world space).
func attach(p_stage: ArenaStage, view: CollectCallView, ctx: WorldContext) -> bool:
	if view.print_stage == null:
		return false
	stage = p_stage
	_print = view.print_stage
	process_priority = -1  # the feed is filled before CharacterRigs poses this frame
	rigs.z_index = RenderLayers.z(&"actors")
	view.print_stage.actor_layer().add_child(rigs)
	rigs.setup(ctx)
	view.cast_view.visible = false
	return true


func _process(_delta: float) -> void:
	if stage == null:
		return
	var f: RigFeed = rigs.feed
	f.count = 0
	var r: Fighter = stage.arena.rivet
	_put(0, r, BodyPlan.Kind.RIVET)
	f.flags[0] |= RigFeed.Flag.AIMING
	f.aim[0] = (r.pos + r.facing * 4.0) * SimConst.PX_PER_M
	var i: int = 1
	for h: Fighter in stage.arena.hostiles:
		_put(i, h, BodyPlan.Kind.COP)
		i += 1
	rigs.focus = r.pos * SimConst.PX_PER_M
	rigs.zoom = _print.zoom


func _put(i: int, who: Fighter, kind: BodyPlan.Kind) -> void:
	var at: Vector2 = who.pos * SimConst.PX_PER_M
	var vel: Vector2 = (at - _last.get(who.id, at)) * float(SimClock.TICK_RATE)
	_last[who.id] = at
	var f: RigFeed = rigs.feed
	@warning_ignore("return_value_discarded")
	f.put(i, who.id, kind, at, vel)
	f.face[i] = who.facing.angle()
	if not who.alive():
		f.flags[i] = DOWN_FLAGS
