class_name StreetDeadPlan
extends RefCounted
## n9 world: the dead redesigned ("they lay down like in the bed now"). At impact a card view
## swaps the fall grid's lying frame for one of five PLAN poses (art/view/plan/dead_<class>.png:
## A face-down crumple, B back spread, C side curl, D twisted sprawl, E folded on the side) on
## the ground plane, head on a drawn heading (StreetDeadHeading), picked by family, then the first
## no neighbour within NEAR_M shows; it slides into the sim rest and rocks back. ENABLED false = d9.
const ENABLED: bool = true
const DIR: String = "res://features/characters/art/view/plan/dead_"
const POSES: int = 5
## Card row -> body class strip ("" or absent = the row keeps its drawn lying frame).
const CLASS_OF: Dictionary[String, String] = {
	"ped/head_hair": "ped_suit",
	"ped/head_hood": "ped_hood",
	"ped/head_worker": "ped_worker",
	"ped/head_shopper": "ped_shopper",
	"ped/head_cap": "ped_cap",
	"ped/head_bald": "ped_elder",
	"ped/head_hat": "ped_hat",
	"ped/head_jogger": "ped_jogger",
	"ped/head_punk": "ped_punk",
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
## n11 (the owner on corpse size): a flat pose is 1.0-1.41 x the standing card and read 1.8 x the
## person alive; every lying pose (near rigs, far crowd, quest 1) draws at this share. 1.0 = before.
const LYING_K: float = 0.72
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
## A class drawn for this camera takes StreetDead70's cell, unturned and unsquashed by the ground.
static func draw(rig: CutRig, card: Sprite2D, row: String, ks: float, p: float) -> void:
	var path: String = path_of(row)
	if path.is_empty() or p < StreetWalkerFall.FALL_AT[StreetWalkerFall.FALL_FRAMES - 1]:
		drop(card)
		return
	var sink: float = StreetWalkerFall.sink_of(rig)
	var r: HumanReact = rig.react
	var blow: Vector2 = r.dir.rotated(rig.facing).normalized() if r != null else Vector2.DOWN
	var kind: StringName = r.kind if r != null else &""
	var drawn: String = StreetDead70.path_of(row)
	var plan: Sprite2D = (
		StreetDead70.sprite(card, path, POSES, 1)
		if drawn.is_empty()
		else StreetDead70.sprite(card, drawn, StreetDead70.COLS, StreetDead70.ROWS)
	)
	var pose: int = pick(rig.actor_id, kind, rig.global_position)
	var h: int = _hash(rig.actor_id)
	var m: Vector2 = motion(kind, p)
	var odd: bool = (h & 1) == 1
	var head: Vector2 = StreetDeadHeading.head_of(blow, pose, odd)
	var lying: float = StreetWalkerFall.rest_scale(ks, sink) * LYING_K
	var pelvis: float = _bounded(card, rig.global_position, head, lying)
	var left: float = StreetDeadHeading.fall_left(p)
	var centre: Vector2 = rig.global_position + head * pelvis
	var at: Vector2 = (
		StreetDeadHeading.resting(rig.actor_id, centre, left) - blow * m.x * CharacterRigs.PX_PER_M
	)
	var lay: Vector2 = StreetDead70.place(plan, head, pose, odd, not drawn.is_empty())
	var s: float = ks * LYING_K * m.y
	plan.global_transform = Transform2D(
		lay.x + StreetDeadHeading.jitter(h) + StreetDeadHeading.settle(p),
		Vector2(s, s / lay.y),
		0.0,
		at
	)
	StreetDeadHeading.shade(card, plan, drawn.is_empty())
	card.self_modulate.a = 0.0


## (the slide still to go in metres, the landing scale) at progress p.
static func motion(kind: StringName, p: float) -> Vector2:
	var left: float = StreetDeadHeading.fall_left(p)
	var slide: float = SLIDE_M[kind] if SLIDE_M.has(kind) else SLIDE_DEFAULT_M
	return Vector2(slide * left, lerpf(1.0, LAND_SCALE, left))


## Removes the plan pose from `card` (rebuilt for another strip, revived, or not lying yet).
static func drop(card: Sprite2D) -> void:
	var plan: Node = card.get_node_or_null(NODE)
	if plan != null:
		card.remove_child(plan)
		plan.queue_free()
	StreetDeadHeading.unshade(card)
	card.remove_meta(FREE)
	card.self_modulate.a = 1.0


## Forgets the poses lying now and their pushes (a new city starts from no dead).
static func reset() -> void:
	_lying.clear()
	StreetQuestDeadPush.reset()


## The pelvis offset along the head (px), pulled back short of the first solid; once per card.
static func _bounded(card: Sprite2D, at: Vector2, head: Vector2, ks: float) -> float:
	var pelvis: float = PELVIS_K * StreetWalkerFall.STILL_PX * ks
	var reach: float = pelvis + HEAD_K * StreetWalkerFall.STILL_PX * ks
	if not card.has_meta(FREE):
		card.set_meta(FREE, free_px(at, head, reach))
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


static func _taken(pose: int, at: Vector2, near: float) -> bool:
	for v: Vector3 in _lying.values():
		if int(v.z) == pose and Vector2(v.x, v.y).distance_to(at) < near:
			return true
	return false


## A stable, well-mixed hash of the actor id (never the global rng).
static func _hash(actor: int) -> int:
	var x: int = (actor * 0x45D9F3B) & 0x7FFFFFFF
	x = ((x >> 16) ^ x) * 0x45D9F3B & 0x7FFFFFFF
	return (x >> 16) ^ x
