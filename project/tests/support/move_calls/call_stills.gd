extends "res://dev/rivet_motion/cover_course_run.gd"
## Paired visual tests for the owner's Calls. Each arm changes just its named motion setting.
## A real projectile supplies the cover measurement. The vault take shares the tackle scenario.

const KNOWN_FLAGS: PackedStringArray = ["--subject", "--value", "--view", "--ppm", "--out"]
const PEEK_TICK: int = 162
const VAULT_TICK: int = 12

var shot: Shot
var fire_tick: int = -1
var _textures: Array[Texture2D] = []


func _ready() -> void:
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	drawing = DisplayServer.get_name() != "headless"
	if not _options(KNOWN_FLAGS) or args.text("--view") != "tilt70":
		get_tree().quit(2)
		return
	ViewMode.select("tilt70")
	if drawing and (output.is_empty() or DirAccess.make_dir_recursive_absolute(output) != OK):
		get_tree().quit(2)
		return
	var result: bool = false
	match args.text("--subject"):
		"cover":
			result = await _cover_take(args.text("--value"))
		"vault":
			result = await _vault_take(args.text("--value"))
	get_tree().quit(0 if result else 1)


func _cover_take(value: String) -> bool:
	if value not in ["0.8", "0.45"]:
		return false
	if drawing and not _decode_cover_art():
		return false
	_open("cover_low")
	var cover: PlayerCover = stage.pilot.motion.cover
	cover.peek_m = float(value)
	for k: int in PEEK_TICK + 1:
		if not _step(k, k):
			return false
		for s: Shot in stage.arena.shots:
			if s.from_rivet and shot == null:
				shot = s
				fire_tick = k
		await get_tree().process_frame
	if shot == null or cover.phase != PlayerCover.Phase.PEEK or cover.blocks_fire():
		return false
	var end: Vector2 = shot.origin + shot.vel.normalized() * shot.spec.range_m
	var blocked: bool = stage.walls.blocks(shot.origin, end)
	Log.info(
		"owner-call",
		(
			"peek_m=%s tick=%d fire_tick=%d origin=%s dir=%s box=%s blocks=%s"
			% [
				value,
				PEEK_TICK,
				fire_tick,
				shot.origin,
				shot.vel.normalized(),
				cover.spot.box,
				blocked
			]
		)
	)
	return await _capture("cover", value, PEEK_TICK)


func _vault_take(value: String) -> bool:
	if value not in ["false", "true"]:
		return false
	ctx = World.build_context(Events, Data, 1918)
	stage = VaultTrial.stage_for(false, ctx)
	guard = VaultTrial.place_tackle(stage)
	# The regular guard rig draws this fighter. Within engage range his AI holds position.
	guard.brain_owned = false
	guard.weapon = &"assault-rifle"
	guard.cooldown = 10000
	var vault: PlayerVault = stage.pilot.motion.vault
	vault.bodies_block_landing = value == "true"
	set_root = Node.new()
	add_child(set_root)
	if drawing:
		_make_view(Vector2(4, 13.5))
	var start: Vector2 = guard.pos
	var peak: float = 0.0
	var saved: bool = false
	for k: int in vault.ticks:
		var from: Vector2 = stage.arena.rivet.pos
		stage.step(k, VaultTrial.sample(stage, Vector2.DOWN, k == 0))
		ctx.clock.complete_tick()
		peak = maxf(peak, from.distance_to(stage.arena.rivet.pos) / SimClock.TICK_DT)
		await get_tree().process_frame
		if k == VAULT_TICK:
			saved = await _capture("vault", value, k)
	var shove: float = start.distance_to(guard.pos)
	Log.info(
		"owner-call",
		(
			"bodies_block_landing=%s peak_mps=%.4f shove_m=%.4f reason=%s"
			% [value, peak, shove, vault.hit.reason]
		)
	)
	if vault.bodies_block_landing:
		return (
			saved and vault.hit.reason == &"landing_blocked" and vault.frame == -1 and shove == 0.0
		)
	return saved and vault.hit.reason == &"ok" and peak > 10.0 and shove > 1.0


func _capture(subject: String, value: String, tick: int) -> bool:
	if not drawing:
		return true
	await RenderingServer.frame_post_draw
	var name: String = "%s_%s_%d_t%03d.png" % [subject, value, ppm, tick]
	return get_viewport().get_texture().get_image().save_png(output.path_join(name)) == OK


## D3D12 returns compressed images for these imported sheets. The existing cover contour
## reads a CPU region. Give it the decoded pixels of the same GPU texture in this capture.
func _decode_cover_art() -> bool:
	var art: String = ViewMode.shared().art
	var dir: String = RivetStrips.DIR.path_join(art)
	var paths: Array[String] = [RivetStrips.strip_of(art, &""), MoveCells.strip(art, 1.0)]
	for name: String in DirAccess.get_files_at(dir):
		if name.begins_with("rivet_eq_machine_pistol") and name.ends_with(".png"):
			paths.append(dir.path_join(name))
	for path: String in paths:
		var texture: Texture2D = load(path) as Texture2D
		var img: Image = texture.get_image()
		if not img.is_compressed():
			continue
		if img.decompress() != OK:
			return false
		var decoded: ImageTexture = ImageTexture.create_from_image(img)
		decoded.take_over_path(path)
		_textures.append(decoded)
	return true
