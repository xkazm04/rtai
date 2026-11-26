class_name TonnageDump
extends RefCounted
## n31 ghost 2 (the owner: no placement marker, a short charge, then a dump on a full circle).
## Tonnage's drop-mode deploy lands on the key's press edge, stands charging for the row's
## charge ticks and hits on the dump tick. This holds the countdown and the circle's geometry.
## Ohm's drop row (n31 ghost 10) shares it: the same press, charge and circle, his discharge.
## Dent's (n31 ghost 15) shares the press and the charge; his ram runs along a lane (DentLane).
## Kerf's (n31 ghost 21) locks a target on the press (KerfDrop) and cuts it on the last tick.

## Ticks until the dump; 0 or less = nothing pending.
var ticks_left: int = -1
## Kerf's locked target (n31 ghost 21); reset with the dump.
var kerf: KerfDrop = KerfDrop.new()


func pending() -> bool:
	return ticks_left > 0


## Start the charge. True when the charge is zero: the dump lands on the press tick itself.
func arm(ticks: int) -> bool:
	ticks_left = ticks
	if ticks > 0:
		return false
	ticks_left = -1
	return true


## Count one later tick. True on the dump tick (the press tick + the charge ticks).
func count() -> bool:
	if ticks_left <= 0:
		return false
	ticks_left -= 1
	return ticks_left == 0


func cancel() -> void:
	ticks_left = -1
	kerf.reset()


## A drop-mode press that passed every refusal: no aiming phase, the ghost stands at the spot
## from this tick (drop_at aim = the cursor, rivet = Rivet's spot) and the strike waits.
func press(
	ghost: GhostDeploy, stage: CollectCallStage, c: PlayerCommand, id: StringName, forms: GhostForms
) -> void:
	var row: GhostAttacks.DeployRow = ghost.strike.attacks.deploy[id]
	ghost.aim(stage, c, id)
	if row.drop_at == &"rivet":
		ghost.spot = stage.arena.rivet.pos
	if id == KerfStage.GHOST and not kerf.lock(stage, ghost):
		ghost.last_refusal = &"no_target"
		ghost.refuse(id)
		ghost.clear()
		return
	ghost.activate(row, stage.tick)
	if id == DentStage.GHOST:
		# n31 ghost 15: Dent's ram lane is laid now; a foe can step out during the wind-up.
		@warning_ignore("return_value_discarded")
		DentLane.lay(stage, ghost)
	if arm(row.charge_ticks):
		_land(ghost, stage, forms)


## Each later tick: count the charge down. Rivet's death cancels the dump and dismisses the
## ghost (cooldown stays spent); the dump tick resolves the strike and records the bond.
func step(ghost: GhostDeploy, stage: CollectCallStage, forms: GhostForms) -> void:
	if not pending():
		return
	if not stage.arena.rivet.alive():
		ghost.clear()
	elif count():
		_land(ghost, stage, forms)


## Ticks since the strike landed; negative while the drop still charges.
func strike_age(ghost: GhostDeploy, tick: int) -> int:
	if pending():
		return -ticks_left
	return tick - ghost.strike.release_tick


func _land(ghost: GhostDeploy, stage: CollectCallStage, forms: GhostForms) -> void:
	var strike: GhostDeployStrike = ghost.strike
	strike.land(stage, ghost)
	forms.bond.record(
		ghost.form, strike.release_kills, strike.release_stuns, strike.release_boss_cuts
	)


## Live hostiles whose body reaches inside radius_m of the spot, in the arena's list order.
static func victims(hostiles: Array[Fighter], spot: Vector2, radius_m: float) -> Array[Fighter]:
	var out: Array[Fighter] = []
	for foe: Fighter in hostiles:
		if foe.alive() and spot.distance_to(foe.pos) <= radius_m + foe.radius_m:
			out.append(foe)
	return out


## The shove runs from the spot to the foe; a foe on the spot takes Tonnage's facing.
static func push_dir(spot: Vector2, at: Vector2, facing: Vector2) -> Vector2:
	if at == spot:
		return facing
	return spot.direction_to(at)
