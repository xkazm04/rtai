class_name GauntletSession
extends ArenaSession
## An arena session with street stations. Proving-ground dummies, cars and pit spawns belong
## to the range, so build the standard ArenaStage over an empty plan before placing the street.

var street: GauntletStreet
var bonuses: GauntletBonusApply


static func open_street(
	events: EventBus, data: DataStore, run: GauntletRun, input: InputSource = null
) -> GauntletSession:
	var s: GauntletSession = GauntletSession.new()
	s.world.start(events, data, run.seed)
	s.street = GauntletStreet.new(s.world.context().rng)
	if s.street.window.is_empty():
		s.world.free()
		return null
	s.plan = ArenaPlan.new()
	s.plan.rivet_start = Vector2(2.0, 0.0)
	s.stations = ArenaStations.new()
	var options: ArenaArgs = ArenaArgs.new()
	options.values["--enemy-brain"] = "guard"  # the street installs its rolling squad map
	s.stage = ArenaStage.new(s.plan, s.stations, options)
	s.actions = PlayerActions.shipped()
	s.actions.install()
	s.pilot = StagePilot.new(s.actions)
	s.stage.pilot = s.pilot
	s.world.add_system(s.stage)
	s.stage.hooks.append(s.street)
	s.street.setup(s.stage, s.world.context())
	(s.stage.arena.squad_ai as GauntletStreet.StreetSquad).mods = run.mods
	s.bonuses = GauntletBonusApply.new(s.stage, s.world.context(), run)
	s.stage.arena.rivet.weapon = &""
	var forms: GhostForms = s.pilot.ghosts.forms
	for form: GhostFormDef in forms.table.forms.values():
		form.unlock = form.id  # a ghost bonus grants its form ref in this session's GhostLocks
	forms.locks.on = true
	s.live = PadAimAssist.wired(LiveInput.new(s.actions), s.stage.get.bind(&"arena"))
	s.tape = InputTape.new(s.live)
	s.world.loop().set_input(input if input != null else s.tape)
	return s
