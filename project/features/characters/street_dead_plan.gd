class_name StreetDeadPlan
extends RefCounted
## n9 world: the dead redesigned from scratch (the owner: "they lay down like in the bed now").
## At impact (StreetWalkerFall's lying frame) a card view swaps the drawn fall grid's lying frame
## for one of five PLAN-view lying poses (drawn straight down, art/view/plan/dead_<class>.png: A
## face-down crumple, B on the back spread and broken, C side curl, D twisted sprawl, E folded and
## tipped over), laid on the ground plane so the camera's own tilt foreshortens it at 70 and 55,
## its head along the blow. The pose is picked by the death family (the weapon class), then the
## first one no neighbour within NEAR_M already shows. It lands slightly big, slides along the blow
## into its rest and rocks back a few degrees (the settle). The rest is the sim point: the view
## never moves the body past where the sim put it. ENABLED false = the drawn lying frame (d9).

const ENABLED: bool = true
const DIR: String = "res://features/characters/art/view/plan/dead_"
const POSES: int = 5
## Card row -> body class strip ("" or absent = the row keeps its drawn lying frame).
const CLASS_OF: Dictionary[String, String] = {
	"ped/head_hair": "ped_suit",
	"ped/head_hood": "ped_hood",
	"ped/head_worker": "ped_worker",
	"ped/head_shopper": "ped_shopper",
	"cop/head_cap": "cop_patrol",
	"cop/head_helmet": "cop_riot",
	"cop/head_swat": "swat",
	"thug": "thug",
}
## The head's direction in each pose's cell (rad, screen): A-D head up, E lies head right.
const HEAD_ANGLE: PackedFloat32Array = [-PI * 0.5, -PI * 0.5, -PI * 0.5, -PI * 0.5, 0.0]
## Death family -> candidate poses, best first (0 A, 1 B, 2 C, 3 D, 4 E).
const BY_KIND: Dictionary[StringName, PackedInt32Array] = {
	&"death_blast": [1, 3, 0],
	&"death_bullet": [0, 3, 1, 2],
	&"death_melee": [4, 2, 0],
	&"death_burn": [2, 4, 0],
	&"death_shock": [2, 3, 4],
}
const ANY: PackedInt32Array = [0, 1, 2, 3, 4]
## The slide into the rest (m, along the blow) by family; the rest is the sim point.
const SLIDE_M: Dictionary[StringName, float] = {
	&"death_blast": 1.2, &"death_bullet": 0.6, &"death_melee": 0.35
}
const SLIDE_DEFAULT_M: float = 0.5
## Of the death family's progress: the slide ends at SLIDE_END, the settle at SETTLE_END.
const SLIDE_END: float = 0.7
const SETTLE_END: float = 0.9
const SETTLE_RAD: float = 0.06
const LAND_SCALE: float = 1.05
## The pelvis (the cell centre) lies this share of the standing height along the blow from the
## sim point (the feet stay near where the person stood).
const PELVIS_K: float = 0.45
## Each body turns off the blow by up to this much (rad, the person's own hash), and mirrors by it.
const JITTER_RAD: float = 0.4
const NEAR_M: float = 3.0
const MEMORY: int = 256
const NODE: String = "DeadPlan"
const PICK: StringName = &"street_dead_plan"
## n9 item 4 (view half): the head end lies HEAD_K of standing past the pelvis (the longest pose:
## 1.4 x standing); the pose is pulled back short of the first solid along the blow.
const HEAD_K: float = 0.7
const FREE_STEPS: int = 8
const FREE: StringName = &"street_dead_plan_free"

## The city's solid test (px -> bool: a building or prop cell; set by the boot). Unset = no bound.
static var solid: Callable = Callable()

## actor id -> Vector3(x, y, pose): the poses lying now, so neighbours differ (view-side only).
static var _lying: Dictionary[int, Vector3] = {}
static var _tex: Dictionary[String, Texture2D] = {}


## The plan strip for a card row ("" = none: the row keeps the drawn lying frame).
static func path_of(row: String) -> String:
	if not ENABLED or not CLASS_OF.has(row):
		return ""
	return DIR + CLASS_OF[row] + ".png"


## The pose for a death of family `kind` at `at` (world px): the family's candidates from the
## person's hash, the first no neighbour within NEAR_M shows (all taken: the hashed one).
static func pick(actor: int, kind: StringName, at: Vector2) -> int:
	if _lying.has(actor):
		return int(_lying[actor].z)
	var cands: PackedInt32Array = BY_KIND.get(kind, ANY)
	var start: int = posmod(_hash(actor), cands.size())
	var pose: int = cands[start]
	var near: float = NEAR_M * CharacterRigs.PX_PER_M
	for i: int in cands.size():
		var c: int = cands[(start + i) % cands.size()]
		if not _taken(c, at, near):
			pose = c
			break
	if _lying.size() >= MEMORY:
		if not _lying.erase(_lying.keys()[0]):
			return pose
	_lying[actor] = Vector3(at.x, at.y, pose)
	return pose


## Draws the plan pose under `card` (the fall grid card) once the fall reaches its lying frame;
## the card's own frame is hidden while it shows (not lying yet, or no strip for the row: dropped).
static func draw(rig: CutRig, card: Sprite2D, row: String, ks: float, p: float) -> void:
	var path: String = path_of(row)
	if path.is_empty() or p < StreetWalkerFall.FALL_AT[StreetWalkerFall.FALL_FRAMES - 1]:
		drop(card)
		return
	var r: HumanReact = rig.react
	var blow: Vector2 = r.dir.rotated(rig.facing).normalized() if r != null else Vector2.DOWN
	var kind: StringName = r.kind if r != null else &""
	var plan: Sprite2D = _node(card, path)
	var pose: int = pick(rig.actor_id, kind, rig.global_position)
	var h: int = _hash(rig.actor_id)
	var jitter: float = JITTER_RAD * (float(posmod(h >> 4, 1001)) / 500.0 - 1.0)
	var m: Vector2 = motion(kind, p)
	var pelvis: float = _bounded(card, rig.global_position, blow, ks)
	var at: Vector2 = rig.global_position + blow * (pelvis - m.x * CharacterRigs.PX_PER_M)
	plan.frame = pose
	plan.flip_h = (h & 1) == 1
	var head: float = HEAD_ANGLE[pose] if not plan.flip_h else PI - HEAD_ANGLE[pose]
	var s: float = ks * m.y
	plan.global_transform = Transform2D(
		blow.angle() - head + jitter + _settle(p), Vector2(s, s), 0.0, at
	)
	card.self_modulate.a = 0.0


## (the slide still to go in metres, the landing scale) at progress p.
static func motion(kind: StringName, p: float) -> Vector2:
	var t0: float = StreetWalkerFall.FALL_AT[StreetWalkerFall.FALL_FRAMES - 1]
	var t: float = clampf((p - t0) / maxf(SLIDE_END - t0, 0.001), 0.0, 1.0)
	var left: float = (1.0 - t) * (1.0 - t)
	var slide: float = SLIDE_M[kind] if SLIDE_M.has(kind) else SLIDE_DEFAULT_M
	return Vector2(slide * left, lerpf(1.0, LAND_SCALE, left))


## Removes the plan pose from `card` (rebuilt for another strip, revived, or not lying yet).
static func drop(card: Sprite2D) -> void:
	var plan: Node = card.get_node_or_null(NODE)
	if plan != null:
		card.remove_child(plan)
		plan.queue_free()
	card.remove_meta(FREE)
	card.self_modulate.a = 1.0


## Forgets the poses lying now.
static func reset() -> void:
	_lying.clear()


## The pelvis offset along the blow (px), pulled back short of the first solid; once per card.
static func _bounded(card: Sprite2D, at: Vector2, blow: Vector2, ks: float) -> float:
	var pelvis: float = PELVIS_K * StreetWalkerFall.STILL_PX * ks
	var reach: float = pelvis + HEAD_K * StreetWalkerFall.STILL_PX * ks
	if not card.has_meta(FREE):
		card.set_meta(FREE, free_px(at, blow, reach))
	var free: float = card.get_meta(FREE)
	return pelvis - (reach - free)


## How far (px, up to `reach`) from `at` along `dir` stays clear of `solid`.
static func free_px(at: Vector2, dir: Vector2, reach: float) -> float:
	if not solid.is_valid():
		return reach
	for k: int in range(1, FREE_STEPS + 1):
		if solid.call(at + dir * (reach * k / FREE_STEPS)):
			return reach * (k - 1) / FREE_STEPS
	return reach


static func _settle(p: float) -> float:
	var u: float = clampf((p - SLIDE_END) / (SETTLE_END - SLIDE_END), 0.0, 1.0)
	return SETTLE_RAD * sin(PI * u) * (1.0 - u)


static func _taken(pose: int, at: Vector2, near: float) -> bool:
	for v: Vector3 in _lying.values():
		if int(v.z) == pose and Vector2(v.x, v.y).distance_to(at) < near:
			return true
	return false


static func _node(card: Sprite2D, path: String) -> Sprite2D:
	var plan: Sprite2D = card.get_node_or_null(NODE) as Sprite2D
	if plan == null:
		plan = Sprite2D.new()
		plan.name = NODE
		plan.hframes = POSES
		card.add_child(plan)
	if plan.texture == null or plan.texture.resource_path != path:
		if not _tex.has(path):
			_tex[path] = load(path) as Texture2D
		plan.texture = _tex[path]
	return plan


## A stable, well-mixed hash of the actor id (never the global rng).
static func _hash(actor: int) -> int:
	var x: int = (actor * 0x45D9F3B) & 0x7FFFFFFF
	x = ((x >> 16) ^ x) * 0x45D9F3B & 0x7FFFFFFF
	return (x >> 16) ^ x
