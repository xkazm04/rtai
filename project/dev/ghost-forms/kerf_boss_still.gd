extends "res://dev/ghost-forms/ghost_deploy_take.gd"
## Use the film's native street/rig camera at each scale. Capture the same finishing opportunity.

const START_HP: float = 6.0
const CROP: Rect2i = Rect2i(480, 270, 960, 540)

var before: bool
var target: Fighter
var caption: Label


class StillInput:
	extends GhostDeployFilmInput

	func sample(tick: int) -> TickInput:
		if subject == null:
			return TickInput.new()
		var aim: Vector2 = subject.pos - stage.arena.rivet.pos
		var actions: PlayerActions = stage.pilot.actions
		var bits: int = PlayerCommand.pack_aim(aim, actions, aim.length())
		if tick >= 8 and tick < 12:
			var action: StringName = GhostNumberKeys.action(stage.pilot.ghosts.forms.table, cue)
			bits |= 1 << actions.bit(action)
		return TickInput.new(bits)

	func observe() -> void:
		pass


func _ready() -> void:
	before = ArenaArgs.parse().text("--arm") == "uncapped"
	input = StillInput.new()
	super._ready()
	last_frame = 16
	stills = [16]


func _open() -> bool:
	if not super._open():
		return false
	var stage: ArenaStage = session.stage
	var combat: GauntletCombat = stage.arena as GauntletCombat
	combat.run.wave = 4
	stage.arena.rivet.pos = Vector2(session.street.current().end_x() + 8.0, 0)
	session.street.step(stage, 0)
	var waves: GauntletWaves = GauntletWaves.attach(session, combat.run, GauntletPilot.new(), 5)
	waves.step(stage, 0)
	var members: Array[Fighter] = waves._live[0].members
	target = members[0]
	target.hp = START_HP
	target.pos = combat.rivet.pos + Vector2(5.0, 0.6)
	target.facing = Vector2.LEFT
	for i: int in range(1, members.size()):
		members[i].pos = combat.rivet.pos + Vector2(18.0, 3.0 + i)
	input.subject = target
	input.cue = KerfStage.GHOST
	var deploy: GhostDeploy = session.pilot.ghosts.deploy
	if before:
		deploy.strike.attacks.deploy[&"kerf"].boss_damage_cap = 1.0
	street.focus = combat.rivet.pos + Vector2(2.8, -0.7)
	street.print_stage.place(street.focus)
	_caption()
	return target.archetype == GauntletComposer.BOSS


func _caption() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	var panel: ColorRect = ColorRect.new()
	panel.color = Color(0.035, 0.055, 0.06, 0.94)
	panel.position = Vector2(CROP.position) + Vector2(0, 462)
	panel.size = Vector2(960, 78)
	layer.add_child(panel)
	caption = Label.new()
	caption.position = Vector2(22, 7)
	caption.add_theme_font_size_override("font_size", 22)
	panel.add_child(caption)


func _process(_delta: float) -> void:
	caption.text = (
		(
			"KERF  /  WAR MACHINE     %s     %d px/m\n"
			+ "%.1f of %.0f HP before cut     %.1f damage     %.1f HP remaining"
		)
		% [
			"UNCAPPED" if before else "CAPPED",
			ppm,
			START_HP,
			target.max_hp,
			START_HP - target.hp,
			target.hp
		]
	)
	super._process(SimClock.TICK_DT)


func _save_still() -> bool:
	var cap: float = session.pilot.ghosts.deploy.strike.attacks.deploy[&"kerf"].boss_damage_cap
	var expected: float = minf(START_HP, cap * target.max_hp)
	if not is_equal_approx(START_HP - target.hp, expected) or target.alive() == before:
		Log.error(
			"kerf-still", "unexpected damage %.2f, expected %.2f" % [START_HP - target.hp, expected]
		)
		return false
	var name_part: String = "before" if before else "after"
	var file: String = out_dir.path_join("kerf-%s-%d.png" % [name_part, ppm])
	var image: Image = get_viewport().get_texture().get_image().get_region(CROP)
	return image.save_png(file) == OK


func _finish() -> void:
	_close()
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().quit()
