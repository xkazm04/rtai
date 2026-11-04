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
## rivet-arsenal: the claw combo's arm per hit (left jab, right backhand, both-hands slam).
const STRIKE_ARMS: Array[int] = [BodyPlan.L, BodyPlan.R, 2]

var rigs: CharacterRigs = CharacterRigs.new()
var stage: ArenaStage = null
## The floor plan whose rig_kick sets a shot's recoil strength (null: every weapon kicks 1.0).
var plan: ArenaPlan = null
## human-reactions: the wound families and the deaths by damage class on the hostiles' rigs.
var react: ReactLink = null
## Fighter ids a signature kill consumed (lane brutality): their body is gibs now, no rig.
var hidden: Dictionary[int, bool] = {}
var _last: Dictionary[int, Vector2] = {}
var _print: PrintStage = null
## On the city proving block the view draws through CityView (no print stage): its actor layer.
var _city: CityView = null
## Each fighter's last hurt tick already played as a HIT clip.
var _hurt_seen: Dictionary[int, int] = {}
## Each fighter's (cooldown, burst_left) last frame: a shot shows as one of them moving (fired()).
var _fire_seen: Dictionary[int, Vector2i] = {}
## rivet-arsenal: the pilot's last seen claw starts and rolls (a change starts the rig clip).
var _strikes_seen: int = 0
var _rolls_seen: int = 0


## Puts the rigs on the view's actor layer (the print stage's, or CityView's on the city proving
## block) and hides the sprite cast; false when the view has neither.
func attach(p_stage: ArenaStage, view: CollectCallView, ctx: WorldContext) -> bool:
	_print = view.print_stage
	_city = view.city_view if _print == null else null
	if _print == null and _city == null:
		return false
	stage = p_stage
	plan = p_stage.plan
	process_priority = -1  # the feed is filled before CharacterRigs poses this frame
	rigs.z_index = RenderLayers.z(&"actors")
	(_print.actor_layer() if _print != null else _city.actor_layer()).add_child(rigs)
	rigs.setup(ctx)
	var held: RivetHeldView = RivetHeldView.new()  # rivet-arsenal: the weapon in his claw
	held.rigs = rigs
	held.pilot = p_stage.pilot
	held.rivet_id = p_stage.arena.rivet.id
	held.z_index = rigs.z_index + 60  # above every rig part (they stack their own z offsets)
	view.print_stage.actor_layer().add_child(held)
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
	_rivet_clips(f)
	var i: int = 1
	for h: Fighter in stage.arena.hostiles:
		if hidden.has(h.id):
			continue
		_put(i, h, BodyPlan.Kind.COP)
		i += 1
	rigs.focus = (r.pos + r.facing * FOCUS_AHEAD_M) * SimConst.PX_PER_M
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


## True when a fighter fired between two frames, from its (cooldown, burst_left): a guard's burst
## spends a round (burst_left falls), Rivet's trigger re-arms the cooldown with no burst running.
## A guard starting a burst (cooldown and burst_left both rise) has not fired yet.
static func fired(before: Vector2i, now: Vector2i) -> bool:
	if now.y < before.y:
		return true
	return now.y == 0 and before.y == 0 and now.x > before.x


## rivet-arsenal: the live pilot's claw strikes and dodge rolls on Rivet's rig (row 0). While a
## claw hit plays the gun is put away, so the strike reads on both arms.
func _rivet_clips(f: RigFeed) -> void:
	var pilot: StagePilot = stage.pilot
	if pilot == null or not stage.arena.rivet.alive():
		return
	var m: MeleeCombo = pilot.melee.combo
	if m.starts != _strikes_seen and m.hit_index != 0:
		var h: MeleeHit = m.current()
		var arm: int = STRIKE_ARMS[mini(m.hit_index - 1, STRIKE_ARMS.size() - 1)]
		f.clip[0] = RigClips.Clip.STRIKE
		f.clip_arg[0] = RigInput.pack_strike(h.windup, h.active, h.recovery, arm)
	_strikes_seen = m.starts
	if pilot.motion.rolls != _rolls_seen:
		f.clip[0] = RigClips.Clip.ROLL
		f.clip_arg[0] = pilot.motion.roll_ticks * SimClock.TICK_DT
	_rolls_seen = pilot.motion.rolls
	if pilot.melee.busy() or pilot.motion.phase != PlayerMotion.Phase.FREE or not _gun_shown(pilot):
		f.flags[0] = 0


## The gun is in the claw from halfway through the draw until halfway through the stow.
static func _gun_shown(pilot: StagePilot) -> bool:
	var h: WeaponHold = pilot.hold
	match h.state:
		WeaponHold.State.DRAWING:
			return h.progress() >= 0.5
		WeaponHold.State.STOWING:
			return h.progress() < 0.5
	return h.held != &""
