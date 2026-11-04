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
## The molotov's throw on Rivet's gun claw (rivet_plan: BodyPlan.L) as strike ticks: a 1-tick
## wind-back, the whip out to full reach, a slow return (view only; the bottle left this tick).
const THROW: Vector3i = Vector3i(1, 6, 18)

var rigs: CharacterRigs = CharacterRigs.new()
var stage: CollectCallStage = null
## The floor plan whose rig_kick sets a shot's recoil strength (null: every weapon kicks 1.0).
var plan: ArenaPlan = null
var _last: Dictionary[int, Vector2] = {}
var _print: PrintStage = null
var _city: CityView = null
## Each fighter's last hurt tick already played as a HIT clip.
var _hurt_seen: Dictionary[int, int] = {}
## Each fighter's (cooldown, burst_left) last frame: a shot shows as one of them moving (fired()).
var _fire_seen: Dictionary[int, Vector2i] = {}
## rivet-arsenal: the pilot's last seen claw starts and rolls (a change starts the rig clip).
var _strikes_seen: int = 0
var _shocks_seen: int = 0
var _rolls_seen: int = 0
var _shots_seen: int = 0
var _winds_seen: int = 0
var _arsenal: ArsenalTable = ArsenalTable.shipped()


## Puts the rigs on the view's actor layer and hides the sprite cast: the printed path's, or
## (human-reactions) the CityView's on the city block (--arena=city); false with neither.
func attach(p_stage: CollectCallStage, view: CollectCallView, ctx: WorldContext) -> bool:
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
	plan = (p_stage as ArenaStage).plan if p_stage is ArenaStage else null  # quest 1: no plan
	process_priority = -1  # the feed is filled before CharacterRigs poses this frame
	rigs.z_index = RenderLayers.z(&"actors")
	layer.add_child(rigs)
	rigs.setup(ctx)
	var held: RivetHeldView = RivetHeldView.new()  # rivet-arsenal: the weapon in his claw
	held.rigs = rigs
	held.pilot = p_stage.pilot
	held.arena = p_stage.arena
	held.rivet_id = p_stage.arena.rivet.id
	held.z_index = rigs.z_index + 60  # above every rig part (they stack their own z offsets)
	layer.add_child(held)
	var mag: WeaponMagView = WeaponMagView.new()  # weapon-art: the reload magazine in the off claw
	mag.rigs = rigs
	mag.pilot = p_stage.pilot
	mag.rivet_id = held.rivet_id
	mag.z_index = held.z_index
	layer.add_child(mag)
	view.cast_view.fighters_on_rigs = true  # quest 1 keeps its allies and marks on the cast view
	view.cast_view.visible = not (p_stage is ArenaStage)
	return true


func _process(_delta: float) -> void:
	if stage == null:
		return
	var f: RigFeed = rigs.feed
	f.count = 0
	var r: Fighter = stage.arena.rivet
	_put(0, r, BodyPlan.Kind.RIVET)
	var sway: float = stage.pilot.sway_rad if stage.pilot != null else 0.0  # the flamer's hose
	f.aim[0] = (r.pos + r.facing.rotated(sway) * 4.0) * SimConst.PX_PER_M
	_rivet_clips(f)
	var i: int = 1
	for h: Fighter in stage.arena.hostiles:
		if h.kind == Fighter.Kind.BOSS and not stage is ArenaStage:
			continue  # quest 1's Mertz keeps the cast view's own drawing (no boss rig yet)
		_put(i, h, BodyPlan.Kind.COP)
		i += 1
	rigs.focus = (r.pos + r.facing * FOCUS_AHEAD_M) * SimConst.PX_PER_M
	rigs.zoom = _print.zoom if _print != null else _city.zoom


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
	elif who.hurt_tick > _hurt_seen.get(who.id, who.hurt_tick):
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
	if pilot.shock.discharges != _shocks_seen:  # the discharge: both claws thrust
		f.clip[0] = RigClips.Clip.STRIKE
		f.clip_arg[0] = RigInput.pack_strike(2, 5, pilot.shock.recovery_ticks, 2)
	_shocks_seen = pilot.shock.discharges
	if pilot.motion.rolls != _rolls_seen:
		f.clip[0] = RigClips.Clip.ROLL
		f.clip_arg[0] = pilot.motion.roll_ticks * SimClock.TICK_DT
	_rolls_seen = pilot.motion.rolls
	var gun: GunHand = stage.arena.gun
	var grip: ArsenalTable.Grip = _arsenal.grip_of(pilot.hold.held)
	if pilot.throw.winds != _winds_seen and grip != null:  # the arm draws back, then whips through
		f.clip[0] = RigClips.Clip.STRIKE
		f.clip_arg[0] = RigInput.pack_strike(grip.windup_ticks, THROW.y, THROW.z, BodyPlan.L)
	_winds_seen = pilot.throw.winds
	if gun != null and gun.shots_fired != _shots_seen and f.clip[0] == RigClips.Clip.NONE:
		f.clip[0] = RigClips.Clip.SHOOT  # the class's kick (rivet_arsenal.json)
		f.clip_arg[0] = grip.kick if grip != null else 1.0
		if grip != null and grip.windup_ticks > 0:  # the wind-up's clip is already throwing
			f.clip[0] = RigClips.Clip.NONE
		elif grip != null and grip.id == &"thrown":  # the bottle leaves: the claw whips through
			f.clip[0] = RigClips.Clip.STRIKE
			f.clip_arg[0] = RigInput.pack_strike(THROW.x, THROW.y, THROW.z, BodyPlan.L)
	_shots_seen = gun.shots_fired if gun != null else 0
	var claws: bool = (pilot.melee.busy() and not pilot.wielding()) or pilot.shock.busy()
	if claws or pilot.motion.phase != PlayerMotion.Phase.FREE or not _gun_shown(pilot):
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
