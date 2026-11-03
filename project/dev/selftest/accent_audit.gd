extends "res://dev/selftest/city_selftest.gd"
## The colour doctrine, measured: the selftest junction (seed 91) at 32 / 48 / 64 px/m under
## --fixed-fps 60, then, with the tree paused (the same sim state), one capture per render layer
## hidden. Accent pixels (PaletteTokens gates) are reported per frame and per layer: `world` is
## absolute (the actors canvas hidden), the actor bands are what hiding them removes. Any accent
## on a layer the palette table does not allow it on is an offender. The full rigs are also split by
## body kind (Rivet / cop / pedestrian) so a vermilion pedestrian is its own number. Since
## 2026-11-03 the four accent inks are counted (vermilion, teal, blood, cop blue) and vermilion on a
## cop's full rig is an offender of its own (`vermilion on cop`: cops print in cop blue now). Writes
## accent-audit.json.
##   godot --fixed-fps 60 --path project res://dev/selftest/accent_audit.tscn -- --out=<dir>

const PPMS: Array[int] = [32, 48, 64]
const STRIDE: int = 2
## PaletteTokens.count_inks() class index per accent id (0 is the base tones).
const ACCENTS: Dictionary[String, int] = {"vermilion": 1, "teal": 2, "blood": 3, "cop_blue": 4}

var _palette: PaletteTokens = PaletteTokens.shared()


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--site="):
			if not set_site(arg.substr(7)):
				return
			continue
		if not arg.begins_with("--out="):
			printerr("accent_audit: unknown argument %s" % arg)
			get_tree().quit(2)
			return
		_out = arg.substr(6)
	_build()
	await _characters.bake()
	@warning_ignore("return_value_discarded")
	await _view.prewarm()
	var rows: Array[Dictionary] = []
	for ppm: int in PPMS:
		rows.append(await _audit(ppm))
	_write(rows)


func _audit(ppm: int) -> Dictionary:
	get_tree().paused = false
	_view.zoom = ppm / SimConst.PX_PER_M
	for i: int in SETTLE_FRAMES:
		await get_tree().process_frame
	get_tree().paused = true
	var full: PackedInt32Array = await _count([], "accent-%dppm.png" % ppm)
	var layers: Dictionary = {}
	var actors: Array[CanvasItem] = []
	for n: Node in _view.actor_layer().get_children():
		actors.append(n as CanvasItem)
	layers["world"] = _pair(
		await _count(actors, "accent-%dppm-world.png" % ppm), PackedInt32Array([0, 0, 0, 0, 0])
	)
	var people: Array[CanvasItem] = [_view.crowd.nodes[SimConst.RL_PEDS], _characters.rigs]
	layers["actors"] = _pair(full, await _count(people, ""))
	layers["vehicles"] = _pair(full, await _count([_view.crowd.nodes[SimConst.RL_CARS]], ""))
	var f: FxSystem = _view.fx
	var fx: Array[CanvasItem] = [_view.crowd.nodes[SimConst.RL_BULLETS], f, f.glow, f.ground]
	layers["fx"] = _pair(full, await _count(fx, ""))
	var by_kind: Dictionary = await _by_kind(full)
	var offenders: Array[String] = _offenders(layers, by_kind)
	var px_accent: int = full[1] + full[2] + full[3] + full[4]
	var px: int = (
		get_viewport().get_texture().get_width() * get_viewport().get_texture().get_height()
	)
	return {
		"ppm": ppm,
		"frame": _pair(full, PackedInt32Array([0, 0, 0, 0, 0])),
		"frame_share": float(px_accent) / float(px),
		"layers": layers,
		"full_rigs_by_kind": by_kind,
		"offenders": offenders,
	}


## Accents on a layer the palette does not allow them on, and vermilion on cops: the actors'
## vermilion that is not Rivet's (the atlas crowd is one MultiMesh; its pedestrian looks are held
## at 0 outside the hit flash by the atlas check, so the rest is the cops and the odd flash), at
## least the cops' full rigs.
func _offenders(layers: Dictionary, by_kind: Dictionary) -> Array[String]:
	var out: Array[String] = []
	for layer: String in layers:
		var c: Dictionary = layers[layer]
		for accent: String in ACCENTS:
			var n: int = c[accent]
			if n > 0 and not _palette.allowed(StringName(accent), StringName(layer)):
				out.append("%s on %s: %d px" % [accent, layer, n])
	var actors: Dictionary = layers["actors"]
	var rivet: Dictionary = by_kind["rivet"]
	var cop: Dictionary = by_kind["cop"]
	var a_v: int = actors["vermilion"]
	var r_v: int = rivet["vermilion"]
	var c_v: int = cop["vermilion"]
	var n_cop: int = maxi(a_v - r_v, c_v)
	if n_cop > 0 and not _palette.accent_uses[&"vermilion"].has("cop"):
		out.append("vermilion on cop: %d px" % n_cop)
	return out


## What hiding each body kind's full rigs removes from the frame's accents.
func _by_kind(full: PackedInt32Array) -> Dictionary:
	var out: Dictionary = {}
	for kind: BodyPlan.Kind in [BodyPlan.Kind.RIVET, BodyPlan.Kind.COP, BodyPlan.Kind.PED]:
		var key: String = BodyPlan.Kind.find_key(kind)
		out[key.to_lower()] = _pair(full, await _count(_rigs_of(kind), ""))
	return out


## The full rigs of one body kind on screen now (the atlas crowd is one MultiMesh: not split).
func _rigs_of(kind: BodyPlan.Kind) -> Array[CanvasItem]:
	var out: Array[CanvasItem] = []
	var rigs: CharacterRigs = _characters.rigs
	for i: int in rigs.feed.count:
		if rigs.full_row(i) and rigs.feed.kinds[i] == kind:
			var rig: CutRig = rigs.rig_for(rigs.feed.ids[i])
			if rig != null:
				out.append(rig)
	return out


## Hides `hide`, draws one frame, counts the accents, shows them again.
func _count(hide: Array[CanvasItem], save_as: String) -> PackedInt32Array:
	for item: CanvasItem in hide:
		item.visible = false
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	if save_as != "":
		@warning_ignore("return_value_discarded")
		img.save_png(_out.path_join(save_as))
	for item: CanvasItem in hide:
		item.visible = true
	return _palette.count_inks(img, STRIDE)


## The atlas crowd is one MultiMesh, so its accents are split here at the source: the baked
## atlas texels of each look (one row of CrowdAtlas cells), classified like a frame (raw texels,
## before the item print). The HIT clip's vermilion flash is a danger cue (counted apart); a
## pedestrian look with vermilion anywhere else is an off-doctrine source.
func _atlas_by_look() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var tex: Texture2D = _characters.rigs.atlas.texture
	if tex == null:
		return out
	var img: Image = tex.get_image()
	@warning_ignore("return_value_discarded")
	img.save_png(_out.path_join("crowd-atlas.png"))
	var c: int = CrowdAtlas.CELL_PX
	for look: int in CrowdAtlas.rows():
		var row: Image = img.get_region(Rect2i(0, look * c, CrowdAtlas.cols() * c, c))
		var v: RigVariant = RigVariant.crowd(look)
		var n: PackedInt32Array = _palette.count_inks(row, STRIDE)
		var hit_x: int = CrowdAtlas.CLIP_FIRST[CrowdAtlas.Clip.HIT] * c
		var hit_w: int = CrowdAtlas.FRAMES[CrowdAtlas.Clip.HIT] * c
		var hit: PackedInt32Array = _palette.count_inks(
			img.get_region(Rect2i(hit_x, look * c, hit_w, c)), STRIDE
		)
		var cell: Dictionary = _pair(n, hit)
		cell["hit_flash"] = _pair(hit, PackedInt32Array([0, 0, 0, 0, 0]))
		cell["look"] = look
		cell["tag"] = v.tag
		var kind: String = BodyPlan.Kind.find_key(v.kind)
		cell["kind"] = kind.to_lower()
		cell["off_doctrine"] = v.kind == BodyPlan.Kind.PED and n[1] - hit[1] > 0
		out.append(cell)
	return out


## Per accent: what `a` has more than `b` (a frame minus the frame with a layer hidden).
static func _pair(a: PackedInt32Array, b: PackedInt32Array) -> Dictionary:
	var out: Dictionary = {}
	for accent: String in ACCENTS:
		var k: int = ACCENTS[accent]
		out[accent] = maxi(a[k] - b[k], 0)
	return out


func _write(rows: Array[Dictionary]) -> void:
	var offenders: int = 0
	for r: Dictionary in rows:
		var o: Array = r["offenders"]
		offenders += o.size()
	var res: Dictionary = {
		"schema": "gtai.accent-audit/1",
		"ok": offenders == 0,
		"stride": STRIDE,
		"frames": rows,
		"crowd_atlas_by_look": _atlas_by_look(),
		"gpu": RenderingServer.get_video_adapter_name(),
	}
	var f: FileAccess = FileAccess.open(_out.path_join("accent-audit.json"), FileAccess.WRITE)
	var written: bool = f != null and f.store_string(JSON.stringify(res, "  ", true))
	if f != null:
		f.close()
	printerr("accent_audit: %s" % JSON.stringify(res))
	get_tree().quit(0 if written else 1)
