class_name GuardFilmSet
extends RefCounted
## One dock-floor set per take. The same camera and pistol clocks are used for both controls.

const START: Vector2 = Vector2(-3, 0)
const AIM: Vector2 = Vector2(0.8660254, 0.5)
const ROCKET: StringName = &"rocket_launcher"

var stage: ArenaStage
var actions: PlayerActions = PlayerActions.shipped()
var ctx: WorldContext
var rocket: WeaponSpec
var anchor: Vector2


func build(beat: String) -> void:
	var plan: ArenaPlan = ArenaPlan.shipped()
	var floor_area: ArenaPlan.Area = ArenaPlan.Area.new()
	floor_area.rect = Rect2(-46, -30, 92, 60)
	floor_area.stenciled = false
	plan.areas.assign([floor_area])
	plan.rivet_start = START
	var station: ArenaStation = ArenaStation.new()
	for at: Vector2 in [Vector2(-11, -6), Vector2(13, -6), Vector2(13, 10)]:
		_prop(station, "cone", at, Vector2.ONE * 0.7)
	if beat == "wall":
		_prop(station, "wall_high", Vector2(-0.6, 0), Vector2(1.1, 4.4))
	var stations: ArenaStations = ArenaStations.new()
	stations.stations.append(station)
	ctx = World.build_context(Events, Data, 22)
	stage = ArenaStage.new(plan, stations)
	stage.pilot = StagePilot.new(actions)
	stage.setup(ctx)
	stage.arena.rivet.weapon = &""
	stage.arena.rivet.facing = AIM
	var arsenal: RivetCarry = RivetWheel.carry_for(stage.arena)
	stage.pilot.carry = arsenal
	_weapons()
	_place(beat)
	anchor = START + Vector2(3.4, 1.5) if beat != "wheel" else START + AIM * 1.9


func view_on(parent: Node, ppm: int) -> void:
	var view: CollectCallView = CollectCallView.new()
	view.stage_view = ArenaFloorView.new()
	view.px_per_m = ppm
	view.focus = START + AIM if ppm == 64 else anchor
	view.bind(stage, CollectCallWorld.new(stage), null)
	parent.add_child(view)
	view.hud_view.hide()
	var cast: ArenaRigs = ArenaRigs.new()
	parent.add_child(cast)
	@warning_ignore("return_value_discarded")
	cast.attach(stage, view, ctx)
	PropOcclusion.for_view(view)


func _prop(station: ArenaStation, kind: String, at: Vector2, size: Vector2) -> void:
	var prop: ArenaStation.Prop = ArenaStation.Prop.new()
	prop.kind = kind
	prop.at = at
	prop.size = size
	station.props.append(prop)


func _weapons() -> void:
	var pistol: EnemyRoster.Weapon = EnemyRoster.shipped().weapons[&"pistol"]
	var w: CombatTuning.Weapon = CombatTuning.Weapon.new()
	w.id = pistol.id
	w.burst = pistol.burst
	w.burst_gap_ticks = pistol.burst_gap_ticks
	w.cooldown_ticks = pistol.cooldown_ticks
	w.damage_vs_rivet = pistol.damage
	w.range_m = pistol.reach_m
	w.speed_mps = pistol.speed_mps
	stage.arena.tuning.weapons[w.id] = w
	rocket = WeaponTable.shipped().weapon(ROCKET)
	var shell: CombatTuning.Weapon = CombatTuning.Weapon.new()
	shell.id = ROCKET
	shell.round = Shot.LARGE
	shell.range_m = rocket.range_m
	shell.speed_mps = rocket.speed_mps
	stage.arena.tuning.weapons[ROCKET] = shell
	EnemyRounds.override_for_test(ROCKET, Shot.LARGE, 5.0, 28.0)


func _place(beat: String) -> void:
	var carry: RivetCarry = stage.pilot.carry
	match beat:
		"guard":
			for i: int in 3:
				var ray: Vector2 = AIM.rotated(deg_to_rad(-30.0 + 30.0 * i))
				_cop(START + ray * (9.0 + i * 0.4), &"pistol", 48 + i * 19)
		"rocket", "wall":
			carry.take(&"pistol", stage.arena)
			var at: Vector2 = Vector2(7, 0) if beat == "wall" else START + AIM * 11.0
			_cop(at, ROCKET, ArenaTargets.NEVER)
		"wheel":
			carry.take(&"katana", stage.arena)
			carry.take(&"pistol", stage.arena)
			_cop(START + AIM * 1.6, &"pistol", ArenaTargets.NEVER)


func _cop(at: Vector2, weapon: StringName, wait: int) -> void:
	var id: int = 100 + stage.arena.hostiles.size()
	var cop: Fighter = Fighter.make(Fighter.Kind.GUARD, id, at, 30.0)
	cop.archetype = &"swat" if weapon == ROCKET else &"patrol_cop"
	cop.radius_m = stage.arena.tuning.human["radius_m"]
	cop.weapon = weapon
	cop.cooldown = wait
	cop.facing = at.direction_to(START)
	stage.arena.hostiles.append(cop)


func fire_rocket() -> void:
	var arena: CombatArena = stage.arena
	var cop: Fighter = arena.hostiles[0]
	var shot: Shot = Shot.fire(
		cop, cop.pos.direction_to(arena.rivet.pos), arena.tuning.weapon(ROCKET)
	)
	# The production rocket row supplies its in-flight art. The hostile row supplies its burst.
	shot.spec = rocket
	shot.origin = shot.pos
	arena.shots.append(shot)
