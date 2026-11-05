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
## The riot cop's look (RigVariant.crowd: the shield), worn by the pit's --riot guards.
const RIOT_LOOK: int = 6
const PATROL_LOOK: int = 5
## rivet-arsenal: the claw combo's arm per hit (left jab, right backhand, both-hands slam).
const STRIKE_ARMS: Array[int] = [BodyPlan.L, BodyPlan.R, 2]
## Hostiles farther than this from Rivet (another station's) do not pull the bubble.
const FOCUS_REACH_M: float = 20.0
## The molotov's throw on Rivet's gun claw (rivet_plan: BodyPlan.L) as strike ticks: a 1-tick
## wind-back, the whip out to full reach, a slow return (view only; the bottle left this tick).
const THROW: Vector3i = Vector3i(1, 6, 18)

var rigs: CharacterRigs = CharacterRigs.new()
var stage: CollectCallStage = null
## The floor plan whose rig_kick sets a shot's recoil strength (null: every weapon kicks 1.0).
var plan: ArenaPlan = null
## human-reactions: the wound families and the deaths by damage class on the hostiles' rigs.
var react: ReactLink = null
## Fighter ids a signature kill consumed (lane brutality): their body is gibs now, no rig.
var hidden: Dictionary[int, bool] = {}
## Fixtures whose body decayed (CorpseDecayHook.gone): undrawn until they stand up again.
var gone: Dictionary[int, bool] = {}
## The fight's corpse decay (CorpseFade wires it; null without one): the dropped pistols ink out.
var decay: CorpseDecay = null
## human-reactions: the city crowd's reactions (--arena=city), told where the fight's dead lie.
var crowd: CrowdReact = null
## ghost-forms: the bound player's ghost form over the rigs (null without a pilot).
var ghost_view: GhostFormView = null
## ghost-powers: the arena's robot on the robot thug's rig (null in quest 1).
var robots: ArenaRobotRigs = null
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
## human-reactions: the (body plan, look) of the dummies that carry one (ReactLineBot.LOOKS).
var _looks: Dictionary[int, Vector2i] = {}


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
	var arena_stage: ArenaStage = p_stage as ArenaStage  # null in quest 1 (no plan, no targets)
	plan = arena_stage.plan if arena_stage != null else null
	process_priority = -1  # the feed is filled before CharacterRigs poses this frame
	rigs.z_index = RenderLayers.z(&"actors")
	layer.add_child(rigs)
	rigs.setup(ctx)
	_add_hand_views(layer, p_stage)
	view.cast_view.fighters_on_rigs = true  # quest 1 keeps its allies and marks on the cast view
	view.cast_view.visible = arena_stage == null
	react = ReactLink.make(p_stage.arena)
	ShieldSparks.wire(react, p_stage.arena, func() -> CombatBlood: return view.blood)
	if arena_stage == null:
		return true
	_add_robots(layer, p_stage.arena, view.blood)
	for t: ArenaTargets.Target in arena_stage.targets.targets:
		var look: Vector2i = ReactLineBot.look_of(t.spawn.id)
		if look.x >= 0:
			_looks[t.fighter.id] = look
	return true


## Rivet's held weapon (rivet-arsenal) and reload magazine (weapon-art) over the rigs, on the
## rigs' own layer (showcase glue: the city view has no print stage).
func _add_hand_views(layer: CanvasLayer, p_stage: CollectCallStage) -> void:
	var held: RivetHeldView = RivetHeldView.new()  # rivet-arsenal: the weapon in his claw
	held.rigs = rigs
	held.pilot = p_stage.pilot
	held.arena = p_stage.arena
	held.rivet_id = p_stage.arena.rivet.id
	held.z_index = rigs.z_index + 60  # above every rig part (they stack their own z offsets)
	layer.add_child(held)  # showcase glue: the city view has no print stage
	var mag: WeaponMagView = WeaponMagView.new()  # weapon-art: the reload magazine in the off claw
	mag.rigs = rigs
	mag.pilot = p_stage.pilot
	mag.rivet_id = held.rivet_id
	mag.z_index = held.z_index
	layer.add_child(mag)
	var arcs: ShockArcsView = ShockArcsView.new()  # combat-notes: arcs over a stunned body
	arcs.arena = p_stage.arena
	arcs.rigs = rigs
	arcs.host = self
	arcs.z_index = held.z_index
	layer.add_child(arcs)
	var scorch: PlasmaScorchView = PlasmaScorchView.new()  # combat-notes: a plasma wound's burn
	scorch.arena = p_stage.arena
	scorch.rigs = rigs
	scorch.host = self
	scorch.z_index = held.z_index
	layer.add_child(scorch)
	var cam: CameraRig = _print.rig if _print != null else _city.rig
	ghost_view = GhostFormView.attach(layer, p_stage, rigs, cam)  # ghost-forms: the ghost bodies


func _add_robots(layer: CanvasLayer, arena: CombatArena, blood: CombatBlood) -> void:
	robots = ArenaRobotRigs.new()
	robots.blood = blood
	robots.arena = arena
	robots.rigs = rigs
	robots.pipe = react.pipe
	robots.consumed = hidden
	robots.gone = gone
	robots.z_index = rigs.z_index
	layer.add_child(robots)


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
		if hidden.has(h.id) or gone.has(h.id) or (robots != null and ArenaRobotRigs.takes(h)):
			continue
		var look: Vector2i = _looks.get(h.id, Vector2i(BodyPlan.Kind.COP, _pit_look(h.id)))
		_put(i, h, look.x as BodyPlan.Kind)
		f.looks[i] = look.y
		if _looks.has(h.id):  # the reaction line stands still facing east: the four sides differ
			f.face[i] = 0.0
			f.aim[i] = f.pos[i] + Vector2.RIGHT * 4.0 * SimConst.PX_PER_M
		i += 1
	rigs.focus = focus_m(stage.arena) * SimConst.PX_PER_M
	rigs.zoom = _print.zoom if _print != null else _city.zoom
	if react != null:
		react.apply(rigs)
	if crowd != null:
		crowd.extra_bodies.clear()
		for h: Fighter in stage.arena.hostiles:
			if not h.alive() and not gone.has(h.id):
				crowd.extra_bodies[-1 - h.id] = h.pos * SimConst.PX_PER_M


## A decayed body left the fight (CorpseFade): its per-fighter bookkeeping goes with it.
func forget(id: int) -> void:
	for d: Dictionary in [_last, _hurt_seen, _fire_seen, hidden]:
		@warning_ignore("return_value_discarded")
		d.erase(id)


## human-reactions' patrol/riot/SWAT mix by actor id; under --riot the shield is worn only by
## the pit's armored riot cops (the mix's other riot picks dress as patrol).
func _pit_look(id: int) -> int:
	var squad: int = RigVariant.squad_index_for(id)
	var arena_stage: ArenaStage = stage as ArenaStage
	if arena_stage == null or arena_stage.pit == null or arena_stage.pit.riot_hp <= 0.0:
		return squad
	if arena_stage.pit.riot.has(id):
		return RIOT_LOOK
	return PATROL_LOOK if squad == RIOT_LOOK else squad


func _put(i: int, who: Fighter, kind: BodyPlan.Kind) -> void:
	var at: Vector2 = who.pos * SimConst.PX_PER_M
	var vel: Vector2 = (at - _last.get(who.id, at)) * float(SimClock.TICK_RATE)
	_last[who.id] = at
	var f: RigFeed = rigs.feed
	@warning_ignore("return_value_discarded")
	f.put(i, who.id, kind, at, vel)
	f.face[i] = who.facing.angle()
	var weapon: StringName = who.weapon
	var mark: Vector2i = Vector2i(who.cooldown, who.burst_left)
	var gun: GunHand = null
	if stage != null and who == stage.arena.rivet:
		gun = stage.arena.gun
	if gun != null:  # lane gunplay: a table gun counts its own rounds (Rivet's cooldown is idle)
		weapon = gun.trigger.spec.id
		mark = Vector2i(gun.shots_fired, 0)
	var armed: bool = weapon != &"" and kind != BodyPlan.Kind.PED  # a pedestrian holds none
	if armed:  # the gun out and aimed along the facing (Rivet's pistol, rifles)
		f.flags[i] = RigFeed.Flag.GUN_OUT | RigFeed.Flag.AIMING
		f.aim[i] = at + who.facing * 4.0 * SimConst.PX_PER_M
	var before: Vector2i = _fire_seen.get(who.id, mark)
	var shot: bool = fired(before, mark)
	_fire_seen[who.id] = mark
	if not who.alive():
		f.flags[i] = DOWN_FLAGS
	elif shot and armed:
		f.clip[i] = RigClips.Clip.SHOOT  # the recoil kick on the gun arm, rifle > pistol
		f.clip_arg[i] = plan.kick(weapon) if plan != null else 1.0
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
