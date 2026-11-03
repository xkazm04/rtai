class_name ArenaRigs
extends Node
## Dev flag --rigs: the arena's fighters drawn on the cast rigs (CharacterRigs, d5-cast) instead of
## quest 1's stills and guard sprites (CastView is hidden). Rivet is the RIVET rig, every hostile
## and dummy a COP rig (the robot and contractor plans land with the enemy-ai and rivet-motion
## merges). Render only: reads the CombatArena every frame and fills the rig feed (world px at
## SimConst.PX_PER_M, the print stage's space); it writes nothing back and draws no RNG.

const DOWN_FLAGS: int = RigFeed.Flag.DEAD | RigFeed.Flag.DOWN
## CharacterRigs poses full rigs within RADIUS_M (14 m) of its focus and leaves the rest to the
## city's crowd atlas, which the arena has not got: the focus sits this far ahead of Rivet along
## his aim, so the rigs cover the screen he faces (the range's 20 m lane), Rivet still inside.
const FOCUS_AHEAD_M: float = 7.0

var rigs: CharacterRigs = CharacterRigs.new()
var stage: ArenaStage = null
var _last: Dictionary[int, Vector2] = {}
var _print: PrintStage = null
## Each fighter's last hurt tick already played as a HIT clip.
var _hurt_seen: Dictionary[int, int] = {}


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
	f.aim[0] = (r.pos + r.facing * 4.0) * SimConst.PX_PER_M
	var i: int = 1
	for h: Fighter in stage.arena.hostiles:
		_put(i, h, BodyPlan.Kind.COP)
		i += 1
	rigs.focus = (r.pos + r.facing * FOCUS_AHEAD_M) * SimConst.PX_PER_M
	rigs.zoom = _print.zoom


func _put(i: int, who: Fighter, kind: BodyPlan.Kind) -> void:
	var at: Vector2 = who.pos * SimConst.PX_PER_M
	var vel: Vector2 = (at - _last.get(who.id, at)) * float(SimClock.TICK_RATE)
	_last[who.id] = at
	var f: RigFeed = rigs.feed
	@warning_ignore("return_value_discarded")
	f.put(i, who.id, kind, at, vel)
	f.face[i] = who.facing.angle()
	if who.weapon != &"":  # armed: the gun out and aimed along the facing (Rivet's pistol, rifles)
		f.flags[i] = RigFeed.Flag.GUN_OUT | RigFeed.Flag.AIMING
		f.aim[i] = at + who.facing * 4.0 * SimConst.PX_PER_M
	if not who.alive():
		f.flags[i] = DOWN_FLAGS
	elif who.hurt_tick > _hurt_seen.get(who.id, who.hurt_tick):
		f.clip[i] = RigClips.Clip.HIT  # the flinch, away from Rivet
		f.clip_arg[i] = (who.pos - stage.arena.rivet.pos).angle()
	_hurt_seen[who.id] = who.hurt_tick
