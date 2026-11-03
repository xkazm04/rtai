class_name D5RigShadow
extends Node2D
## d5-close hero and arena scenes (iteration 8): a hatched cast shadow for every rig up close, as
## King's sprite shadow and the concept's ground shadow. Up close the rig halos (and the
## look_d5_halo drop shadow) are gone, so the robots and cops floated over the floor. Each frame
## this mirrors every visible part sprite of the rigs under `source` (not the halos, not the D5
## overlays) onto the world layer, offset down-right by LENGTH_M, printed by look_d5_shadow as
## rig-locked pen strokes ONLY (tint 0, stroke 1): overlapping parts draw the same stroke pixels,
## so nothing stacks and no CanvasGroup is needed (the group cost +0.07..0.18 ms GPU with ~1 ms p95
## spikes; strokes only: +0.012 ms, no spike). Fades in 56 -> 64 px/m with the D5 part tier,
## "d5" tier only. Proposal for the characters lane; D5_RIG_SHADOW=0 off.

const SHADER: String = "res://assets/shaders/look_d5_shadow.gdshader"
const LENGTH_M: float = 0.45
const SKIP: Array[StringName] = [&"d5", &"halo_ink"]
const NAME: StringName = &"rig_shadow"

## script time spent in _sync since the last reset (the cost scene reads it)
static var sync_usec: int = 0

var source: Node = null
var px: float = 32.0
var _pool: Array[Sprite2D] = []
var _parts: Array[Sprite2D] = []  # cached on each tier switch (the tree walk cost ~1.7 ms a frame)
var _mat: ShaderMaterial = ShaderMaterial.new()
## item54: one material per rig, strokes anchored to the rig (they travel with it); world-locked
## strokes crawl under a walking shadow (in-shadow flip 0.44 vs 0.18).
## D5_RIG_SHADOW_LOCK=world = the old world-locked strokes
var _rig_lock: bool = OS.get_environment("D5_RIG_SHADOW_LOCK") != "world"
var _owner: Array[Node2D] = []  # the rig of each part in _parts
var _mats: Dictionary[Node2D, ShaderMaterial] = {}
var _part_mat: Array[ShaderMaterial] = []  # the material of each part in _parts (per collect)


## One call per tier switch from a scene: makes the node on `world` once (named NAME), then
## sets it for the view.
static func on_tier(world: Node, rigs: Node, px_per_m: float, ppm: float, tier: String) -> void:
	var g: D5RigShadow = world.get_node_or_null(NodePath(NAME)) as D5RigShadow
	if g == null:
		g = make(rigs, px_per_m)
		g.name = NAME
		world.add_child(g)
	g.set_view(ppm, tier)


static func make(from: Node, px_per_m: float) -> D5RigShadow:
	var g: D5RigShadow = D5RigShadow.new()
	g.source = from
	g.px = px_per_m
	g._mat.shader = load(SHADER) as Shader
	g._mat.set_shader_parameter("tint", 0.0)
	g._mat.set_shader_parameter("stroke", 1.0)
	g.visible = false
	return g


func set_view(ppm: float, tier: String) -> void:
	var on: bool = OS.get_environment("D5_RIG_SHADOW") != "0" and tier == "d5"
	var a: float = clampf((ppm - 56.0) / 8.0, 0.0, 1.0)
	visible = on and a > 0.0
	_parts.clear()
	_owner.clear()
	_part_mat.clear()
	modulate.a = a
	_mat.set_shader_parameter("zoom", ppm / 32.0)
	for m: ShaderMaterial in _mats.values():
		m.set_shader_parameter("zoom", ppm / 32.0)


func _process(_delta: float) -> void:
	if visible and source != null:
		var t0: int = Time.get_ticks_usec()
		_sync()
		sync_usec += Time.get_ticks_usec() - t0


func _sync() -> void:
	if _parts.is_empty():
		var skip: Dictionary[Sprite2D, bool] = {}
		_collect(source, _parts, skip, null)
		for rig: Node2D in _owner:
			_part_mat.append(_rig_mat(rig) if _rig_lock else _mat)
	var parts: Array[Sprite2D] = _parts
	while _pool.size() < parts.size():
		var s: Sprite2D = Sprite2D.new()
		s.material = _mat
		add_child(s)
		_pool.append(s)
	var off: Vector2 = Vector2.ONE * LENGTH_M * px * 0.7071
	for rig: Node2D in _mats:  # the anchor once per rig a frame (per part cost +0.2 ms script)
		var at: Vector2 = rig.global_position if rig != null else Vector2.ZERO
		_mats[rig].set_shader_parameter("anchor", at)
	for i: int in _pool.size():
		var s: Sprite2D = _pool[i]
		s.visible = i < parts.size() and parts[i].is_visible_in_tree()
		if s.visible:
			var p: Sprite2D = parts[i]
			s.texture = p.texture
			s.centered = p.centered
			s.offset = p.offset
			s.flip_h = p.flip_h
			s.flip_v = p.flip_v
			s.region_enabled = p.region_enabled
			s.region_rect = p.region_rect
			var g: Transform2D = p.global_transform
			s.global_transform = Transform2D(g.x, g.y, g.origin + off)
			if s.material != _part_mat[i]:
				s.material = _part_mat[i]


func _rig_mat(rig: Node2D) -> ShaderMaterial:
	var m: ShaderMaterial = _mats.get(rig, null)
	if m == null:
		m = _mat.duplicate() as ShaderMaterial
		_mats[rig] = m
	return m


func _collect(n: Node, out: Array[Sprite2D], skip: Dictionary[Sprite2D, bool], at: Node2D) -> void:
	for c: Node in n.get_children():
		var rig: CutRig = c as CutRig
		var own: Node2D = rig if rig != null else at
		if rig != null:
			for h: Sprite2D in rig.halos:
				skip[h] = true
		var s: Sprite2D = c as Sprite2D
		if s != null and s.texture != null:
			if not skip.has(s) and not SKIP.has(s.name):
				out.append(s)
				_owner.append(own)
		_collect(c, out, skip, own)
