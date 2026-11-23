class_name StagePilot
extends RefCounted
## The player at quest 1's stage (and the arena's, and the city block's): each tick's TickInput
## (live devices or a replay log, never raw keys) decoded into StageIntent. The move stick drives
## PlayerMotion (rivet_motion.json over TopDownMover: the walk, the held sprint, the dodge roll
## with its i-frames), a held fire shoots along the aim heading, an interact press uses whatever
## is in reach (StageActions), melee is the claw combo (PlayerMelee over rivet_melee.json), and
## the car key is a stub until the vehicles lane's enter/exit API lands.
## Vaults own the stage position and attack input through their landing tick.
## Station cover holds the fighter on the face and releases fire at a full corner peek.

var actions: PlayerActions
var guard: PlayerGuard = null
var wheel: RivetWheel = null
var motion: PlayerMotion = PlayerMotion.shipped()
var melee: PlayerMelee = PlayerMelee.new()
## rivet-arsenal: hold melee after the jab to charge the electroshock, release to discharge.
var shock: PlayerShock = PlayerShock.shipped()
## rivet-arsenal: the weapon in the claw follows the arena's rivet.weapon with a stow and a draw
## (rivet_arsenal.json); no shot leaves before the draw ends.
var hold: WeaponHold = WeaponHold.new()
## rivet-arsenal: the carried guns and the switch keys (null: quest 1 keeps its own weapons).
var carry: RivetCarry = null:
	set(value):
		carry = value
		if wheel != null:
			wheel.bind(value)
## rivet-arsenal: this tick's sway of the fire line off the aim (rad; the flamer's hose, else 0).
var sway_rad: float = 0.0
## rivet-arsenal: the molotov's wind-up before the bottle leaves.
var throw: PlayerThrow = PlayerThrow.new()
## Claw hits started (a press that started or chained a hit; the Hauler's stomp is not one).
var melee_swings: int = 0
var car_presses: int = 0
## GhostPilot handles deployment (Q / LB), selection (G / RB) and mastery (T).
## The four form stages also feed the views and tests.
var ghosts: GhostPilot = GhostPilot.shipped()
var hauler: HaulerStage = ghosts.hauler
var dent: DentStage = ghosts.dent
var kerf: KerfStage = ghosts.kerf
var ohm: OhmStage = ghosts.ohm
## The tick the last input arrived and the tick its first move or claw started (latency probe).
var last_press_tick: int = -1
var _previous: int = 0
## rivet-arsenal: the claw and each carried melee weapon's combo, by weapon id.
var _melees: Dictionary[StringName, PlayerMelee] = {}


func _init(p_actions: PlayerActions) -> void:
	actions = p_actions
	if actions.wheel:
		guard = PlayerGuard.new()
		wheel = RivetWheel.new()
	actions.enable_cover_input(motion.cover.enabled)


## Fills the stage's intent for this tick from `input`.
func drive(stage: CollectCallStage, input: TickInput) -> void:
	var c: PlayerCommand = PlayerCommand.decode(input, _previous, actions)
	_previous = input.buttons
	if c.pressed != 0:
		last_press_tick = stage.tick
	var rivet: Fighter = stage.arena.rivet
	if rivet.alive():
		if wheel != null:
			if carry == null:
				carry = RivetWheel.carry_for(stage.arena)
			wheel.step(c, actions, stage.arena, stage.tick)
		elif carry != null:
			carry.step(c, actions, stage.arena)
	hold.follow_weapon(rivet.weapon)
	if guard != null:
		PlayerGuardInput.prepare(self, stage, c)
	_pick_melee(c)
	if stage.hidden_in != "" and c.move == Vector2.ZERO:
		motion.stop()
	if rivet.alive():
		_move(stage, c)
	else:
		motion.stop()
	stage.intent.interact = stage.intent.interact or c.was_pressed(actions, &"interact")
	_attacks(stage, c, rivet)
	motion.vault.guard_move(stage)
	if guard != null and guard.up() and not PlayerGuardInput.available(self, stage.arena):
		guard.lower()


func _attacks(stage: CollectCallStage, c: PlayerCommand, rivet: Fighter) -> void:
	_fire(stage, c)
	var press: bool = _melee_press(c)
	var free_to_attack: bool = motion.cover.spot == null and not motion.vault.owns_move
	if not _ghosts(stage, c, press, free_to_attack) and free_to_attack:
		var free: bool = motion.phase == PlayerMotion.Phase.FREE
		var down: bool = c.is_held(actions, &"melee") and rivet.alive()
		@warning_ignore("return_value_discarded")
		shock.step(stage.arena, down, free and not melee.busy(), rivet.facing)
		var before: int = melee.combo.starts
		if press and free and not shock.busy():
			melee.combo.press()
		melee.combo.holding = _attack_held(c) and rivet.alive()
		stage.intent.move_by += melee.step(stage.arena, false, rivet.facing)
		melee_swings += melee.combo.starts - before
		if c.was_pressed(actions, &"car"):
			car_presses += 1
			Log.info("pilot", "enter/exit car pressed (stub until the vehicles lane's API lands)")


## The ghost forms (features/souls GhostPilot); true when a form owns the melee press this tick
## (the pilot skips the claw).
func _ghosts(stage: CollectCallStage, c: PlayerCommand, press: bool, free: bool) -> bool:
	if ghosts == null:
		return false
	stage.intent.move_by = ghosts.drive(stage, c, actions, press, free)
	return ghosts.owns_melee()


func facing() -> Vector2:
	return motion.facing()


## Kept for the dev arena's teleport and older hosts: the walk under PlayerMotion.
func stop() -> void:
	motion.stop()


func write_state(out: StreamPeerBuffer) -> void:
	motion.write_state(out)
	melee.write_state(out)
	shock.write_state(out)
	hold.write_state(out)
	if carry != null and (wheel == null or wheel.writes_carry()):
		carry.write_state(out)
		throw.write_state(out)
	TickInput.write_previous(out, _previous)
	if ghosts != null:
		ghosts.write_state(out)
	if guard != null:
		guard.write_state(out)
	if wheel != null:
		wheel.write_state(out)


## The walk, sprint and roll; a claw hit slows the walk (move_mult), so do spinning barrels (the
## gatling's fire_move_mult), and the roll's i-frames close
## Rivet to damage (CombatArena.damage skips a fighter that is not exposed).
func _move(stage: CollectCallStage, c: PlayerCommand) -> void:
	var rivet: Fighter = stage.arena.rivet
	var walk: float = stage.arena.tuning.rivet["walk_mps"] * melee.move_scale()
	var gun: GunHand = stage.arena.gun
	if gun != null and gun.trigger.spinning():
		walk *= gun.trigger.spec.fire_move_mult  # the gatling's barrels turn: a heavy slow walk
	if guard != null and guard.blocks_attack():
		walk = stage.arena.tuning.rivet["walk_mps"] * (guard.tuning.move_k if guard.up() else 1.0)
		motion.mover.velocity = motion.mover.velocity.limit_length(walk)
	var aim: Vector2 = c.aim
	if melee.busy() and aim == Vector2.ZERO:
		c.aim = motion.facing()  # a swing holds the heading it started on
	motion.drive(stage, self, c, walk)
	c.aim = aim
	rivet.facing = c.aim if guard != null and guard.up() else motion.heading(c.aim)
	rivet.exposed = not motion.invulnerable()


## rivet-arsenal: a carried melee weapon (katana, baton) is in the claw.
func wielding() -> bool:
	if wheel != null and melee.busy() and melee.weapon_id == MeleeTable.CLAW:
		return false
	return carry != null and carry.melee_ids.has(hold.held)


## The melee combo follows the weapon in the claw (the bare claw otherwise); it changes between
## hits only, never inside one.
## Wheel controls also allow a quick claw press to interrupt a blade hit.
func _pick_melee(c: PlayerCommand) -> void:
	var want: StringName = hold.held if wielding() else MeleeTable.CLAW
	if wheel != null and c.was_pressed(actions, &"melee"):
		want = MeleeTable.CLAW
		if melee.weapon_id != want and melee.busy():
			melee.combo.cancel()
	if want == melee.weapon_id or melee.busy():
		return
	_melees[melee.weapon_id] = melee
	if not _melees.has(want):
		_melees[want] = PlayerMelee.new(MeleeTable.weapon(want))
	melee = _melees[want]


## The melee key's press; with a melee weapon drawn, a held fire swings too (held = the combo
## chains, as a mash does). Nothing swings while the weapon is still being drawn.
func _melee_press(c: PlayerCommand) -> bool:
	if wheel != null:
		return wheel.swing_pressed(c, actions, hold, melee, ghosts)
	if not wielding():
		return c.was_pressed(actions, &"melee")
	if not hold.can_fire():
		return false
	return c.was_pressed(actions, &"melee") or c.is_held(actions, &"fire")


## The attack is held down: melee, or a held fire with a melee weapon drawn (the chainsaw grinds).
func _attack_held(c: PlayerCommand) -> bool:
	var primary: bool = wheel.melee_selected() if wheel != null else wielding()
	return c.is_held(actions, &"melee") or (primary and c.is_held(actions, &"fire"))


## A held fire shoots along the aim; the flamer's hose sways the line (ArsenalTable.Grip.sway).
func _fire(stage: CollectCallStage, c: PlayerCommand) -> void:
	var rolling: bool = motion.blocks_fire()  # n10 r-2: no gun is drawn in the ball
	var armed: bool = (
		hold.can_fire() and not melee.busy() and not shock.busy() and not wielding() and not rolling
	)
	if wheel != null:
		armed = armed and not wheel.melee_selected() and not c.was_pressed(actions, &"melee")
	var grip: ArsenalTable.Grip = hold.table.grip_of(hold.held)
	var firing: bool = c.is_held(actions, &"fire") and c.aim != Vector2.ZERO and armed
	if grip != null and grip.windup_ticks > 0:  # the molotov: wind up, then the bottle leaves
		var gun: GunHand = stage.arena.gun
		var ready: bool = gun != null and gun.trigger.cooldown == 0 and not gun.trigger.reloading()
		var at: Vector2 = throw.step(grip.windup_ticks, firing, armed, ready, c.aim)
		if at != Vector2.ZERO:
			stage.intent.fire_at = stage.arena.rivet.pos + at * _reach(stage, c)
		return
	sway_rad = grip.sway(stage.tick) if firing and grip != null else 0.0
	if firing:
		stage.intent.fire_at = stage.arena.rivet.pos + c.aim.rotated(sway_rad) * actions.aim_range_m


## How far along the aim the fire point sits: a thrown weapon lands where the cursor was (lane
## gunplay, rivet-arsenal REQUEST 12); everything else aims aim_range_m out (direction only).
func _reach(stage: CollectCallStage, c: PlayerCommand) -> float:
	var gun: GunHand = stage.arena.gun
	if c.aim_m > 0.0 and gun != null and gun.trigger.spec.kind == WeaponSpec.Kind.THROWN:
		return c.aim_m
	return actions.aim_range_m
