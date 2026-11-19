class_name CrowdBaker
extends Node
## Renders CrowdAtlas at load: one real rig per crowd look in an offscreen SubViewport, posed
## through every clip on the fixed tick and captured frame by frame into one atlas image
## (25 captures, then the viewport and the rigs are freed). Headless (no GPU) it leaves the
## atlas unbaked; the layout and the clip table do not depend on it.
## Await bake(): it spans about 30 rendered frames at load. CrowdReadback takes each frame
## synchronously by default; the async readback flag queues it until _drain().

const TICK: float = 1.0 / 60.0
## Frames to wait for the last readbacks before the bake gives up on them (they land in 1-3).
const WAIT_FRAMES: int = 120

var _rigs: Array[CutRig] = []
var _vp: SubViewport = null
var _image: Image = null
var _readback: CrowdReadback = CrowdReadback.new()
var _clip: CrowdAtlas.Clip = CrowdAtlas.Clip.IDLE
var _reactions: ReactTable


func bake(atlas: CrowdAtlas) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var saved_zoom: float = PartMaterials.view_px / CutRig.SC
	PartMaterials.set_view(CrowdAtlas.BAKE_ZOOM)
	_make_stage()
	var cell: int = CrowdAtlas.CELL_PX
	_image = Image.create_empty(
		CrowdAtlas.cols() * cell, CrowdAtlas.rows() * cell, false, Image.FORMAT_RGBA8
	)
	for c: int in CrowdAtlas.CLIPS:
		var zoom: Vector2 = CrowdAtlas.bake_scale(ViewMode.shared(), c as CrowdAtlas.Clip)
		_vp.canvas_transform = Transform2D.IDENTITY.scaled(zoom)
		_start_clip(c as CrowdAtlas.Clip)
		var at: float = 0.0
		for f: int in CrowdAtlas.FRAMES[c]:
			var want: float = _frame_time(c as CrowdAtlas.Clip, f)
			_advance(want - at)
			at = want
			await RenderingServer.frame_post_draw
			_capture(CrowdAtlas.CLIP_FIRST[c] + f)
	await _drain()
	atlas.bake_view = ViewMode.new()
	atlas.bake_view.cards = ViewMode.shared().cards
	atlas.bake_view.art = ViewMode.shared().art
	atlas.bake_view.pitch_deg = ViewMode.shared().pitch_deg
	if not CrowdAtlas.drawn_fall(atlas.bake_view):
		StreetCrowdCorpse.stamp(_image, _rigs)
	atlas.texture = ImageTexture.create_from_image(_image)
	atlas.baked = true
	_vp.queue_free()
	_rigs.clear()
	PartMaterials.set_view(saved_zoom)


## Waits (rendered frames, at most WAIT_FRAMES) for the readbacks still in flight.
func _drain() -> void:
	var waited: int = 0
	while _readback.pending > 0 and waited < WAIT_FRAMES:
		await RenderingServer.frame_post_draw
		waited += 1
	var missing: int = _readback.pending + _readback.failed
	if missing > 0:
		Log.warn("characters", "crowd atlas: %d captures missing" % missing)


func _make_stage() -> void:
	var cell: int = CrowdAtlas.CELL_PX
	_vp = SubViewport.new()
	_vp.size = Vector2i(CrowdAtlas.LOOKS * cell, cell)
	_vp.transparent_bg = true
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_vp)
	_reactions = ReactTable.shipped() if CrowdAtlas.drawn_fall(ViewMode.shared()) else null
	for look: int in CrowdAtlas.LOOKS:
		var v: RigVariant = RigVariant.crowd(look)
		var rig: CutRig = CutRig.new()
		_vp.add_child(rig)
		rig.setup(RigPool.plan_of(v.kind), v)
		_rigs.append(rig)


func _centre(look: int) -> Vector2:
	var pixel: Vector2i = CrowdAtlas.anchor(ViewMode.shared(), _clip)
	pixel.x += look * CrowdAtlas.CELL_PX
	return Vector2(pixel) / CrowdAtlas.bake_scale(ViewMode.shared(), _clip)


func _start_clip(c: CrowdAtlas.Clip) -> void:
	_clip = c
	for look: int in _rigs.size():
		var rig: CutRig = _rigs[look]
		rig.global_position = _centre(look)
		rig.reset_state(0.0)
		var run: bool = c == CrowdAtlas.Clip.FLEE
		rig.vel_in = Vector2(CutRig.RUN_SPEED if run else CutRig.WALK_SPEED, 0.0)
		if c != CrowdAtlas.Clip.WALK and c != CrowdAtlas.Clip.FLEE:
			rig.vel_in = Vector2.ZERO
		rig.clips.fleeing = run
		rig.gun_out = c == CrowdAtlas.Clip.SHOOT and rig.plan.gun_arm >= 0
		rig.aiming = rig.gun_out
		rig.aim_at = rig.global_position + Vector2(400.0, 0.0)
		match c:
			CrowdAtlas.Clip.HIT:
				rig.clips.hit(rig, Vector2.RIGHT)
			CrowdAtlas.Clip.DEATH:
				rig.clips.die(false)
				if _reactions != null:
					HumanReact.on(rig).play(rig, &"death_bullet", Vector2.RIGHT, _reactions)
			CrowdAtlas.Clip.SHOOT:
				rig.clips.shoot(1.0)
	_advance(0.6 if c == CrowdAtlas.Clip.WALK or c == CrowdAtlas.Clip.FLEE else 0.0)


static func _frame_time(c: CrowdAtlas.Clip, f: int) -> float:
	var t: float = (f + 0.5) / CrowdAtlas.FPS[c]
	if c == CrowdAtlas.Clip.DEATH:
		t = (f + 1.0) / CrowdAtlas.FPS[c]
	return t


## Drives every rig on the fixed tick; walkers stay in their cell (a treadmill: the body and its
## planted feet shift back together, so the gait is the real one).
func _advance(seconds: float) -> void:
	for _k: int in roundi(seconds / TICK):
		for look: int in _rigs.size():
			var rig: CutRig = _rigs[look]
			rig.global_position += rig.vel_in * TICK
			rig.drive(TICK)
			var back: Vector2 = _centre(look) - rig.global_position
			rig.global_position += back
			for side: RigLimbs in rig.sides:
				side.foot_w += back
				side.foot_from += back
			for i: int in rig.hose_pts.size():
				rig.hose_pts[i] += back
				rig.hose_prev[i] += back


func _capture(col: int) -> void:
	_readback.request(_vp, _blit.bind(col))


func _blit(shot: Image, col: int) -> void:
	var cell: int = CrowdAtlas.CELL_PX
	if shot == null or shot.is_empty() or _image == null:
		return
	shot.convert(Image.FORMAT_RGBA8)
	for look: int in CrowdAtlas.LOOKS:
		var src: Rect2i = Rect2i(look * cell, 0, cell, cell)
		_image.blit_rect(shot, src, Vector2i(col * cell, look * cell))
