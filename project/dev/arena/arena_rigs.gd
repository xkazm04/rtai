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
## Hostiles farther than this from Rivet (another station's) do not pull the bubble.
const FOCUS_REACH_M: float = 20.0

var rigs: CharacterRigs = CharacterRigs.new()
var stage: ArenaStage = null
## The floor plan whose rig_kick sets a shot's recoil strength (null: every weapon kicks 1.0).
var plan: ArenaPlan = null
## Fighter ids a signature kill consumed (lane brutality): their body is gibs now, no rig.
var hidden: Dictionary[int, bool] = {}
## human-reactions: the wound families and the deaths by damage class on the hostiles' rigs.
var react: ReactLink = null
var _last: Dictionary[int, Vector2] = {}
var _print: PrintStage = null
var _city: CityView = null
## Each fighter's last hurt tick already played as a HIT clip.
var _hurt_seen: Dictionary[int, int] = {}
## Each fighter's (cooldown, burst_left) last frame: a shot shows as one of them moving (fired()).
var _fire_seen: Dictionary[int, Vector2i] = {}


## Puts the rigs on the view's actor layer and hides the sprite cast: the printed path's, or
## (human-reactions) the CityView's on the city block (--arena=city); false with neither.
func attach(p_stage: ArenaStage, view: CollectCallView, ctx: WorldContext) -> bool:
	var layer: CanvasLayer = null
	if view.print_stage != null:
		_print = view.print_stage
		layer = _print.actor_layer()
	elif view.city_view != null:
		_city = view.city_view
		layer = _city.actor_layer()
	else:
		return false
	stage = p_stage
	plan = p_stage.plan
	process_priority = -1  # the feed is filled before CharacterRigs poses this frame
	rigs.z_index = RenderLayers.z(&"actors")
	layer.add_child(rigs)
	rigs.setup(ctx)
	view.cast_view.visible = false
	react = ReactLink.make(p_stage.arena)
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
		if hidden.has(h.id):
			continue
		_put(i, h, BodyPlan.Kind.COP)
		i += 1
	rigs.focus = focus_m(stage.arena) * SimConst.PX_PER_M
	rigs.zoom = _print.zoom if _print != null else _city.zoom
	if react != null:
		react.apply(rigs)


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
	var mark: Vector2i = Vector2i(who.cooldown, who.burst_left)
	var before: Vector2i = _fire_seen.get(who.id, mark)
	var shot: bool = fired(before, mark)
	_fire_seen[who.id] = mark
	if not who.alive():
		f.flags[i] = DOWN_FLAGS
	elif shot and who.weapon != &"":
		f.clip[i] = RigClips.Clip.SHOOT  # the recoil kick on the gun arm, rifle > pistol
		f.clip_arg[i] = plan.kick(who.weapon) if plan != null else 1.0
	elif who.hurt_tick > _hurt_seen.get(who.id, who.hurt_tick) and react == null:
		f.clip[i] = RigClips.Clip.HIT  # the flinch, away from Rivet
		f.clip_arg[i] = (who.pos - stage.arena.rivet.pos).angle()
	_hurt_seen[who.id] = who.hurt_tick


## The LOD bubble's centre (m). human-reactions: the middle of the box around Rivet, the point
## ahead of him and every hostile within FOCUS_REACH_M, the dead included, so a corpse keeps
## its full rig while it is on screen (the old focus, FOCUS_AHEAD_M along the aim, dropped
## bodies behind him).
static func focus_m(arena: CombatArena) -> Vector2:
	var r: Fighter = arena.rivet
	var box: Rect2 = Rect2(r.pos, Vector2.ZERO).expand(r.pos + r.facing * FOCUS_AHEAD_M)
	for h: Fighter in arena.hostiles:
		if h.pos.distance_to(r.pos) <= FOCUS_REACH_M:
			box = box.expand(h.pos)
	return box.get_center()


## True when a fighter fired between two frames, from its (cooldown, burst_left): a guard's burst
## spends a round (burst_left falls), Rivet's trigger re-arms the cooldown with no burst running.
## A guard starting a burst (cooldown and burst_left both rise) has not fired yet.
static func fired(before: Vector2i, now: Vector2i) -> bool:
	if now.y < before.y:
		return true
	return now.y == 0 and before.y == 0 and now.x > before.x
