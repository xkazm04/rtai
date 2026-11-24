class_name CastPatrolTake
extends Node2D
## Parallel observations on the same fixed-camera ticks as the equipped near rig.
## The production far card and immediate-mode quest card draw outside the still's crop.
const TALL_ID: int = 262472

var far: ArenaWaveCards.Card = ArenaWaveCards.Card.new()
var feed: RigFeed = RigFeed.new()
var at: Vector2
var facing: Vector2
var quest: Dictionary
var actor: Fighter
var takes: Array[Dictionary] = []


func begin(arena: CombatArena, take: Dictionary) -> void:
	for h: Fighter in arena.hostiles:
		if h.id == TALL_ID:
			actor = h
			break
	if actor == null:
		var previous: int = arena._next_id
		arena._next_id = TALL_ID
		actor = arena.squad_ai.spawn_member(arena, Vector2.ZERO, &"patrol_cop")
		arena._next_id = previous
	for label: String in ["quest", "far", "near_tall"]:
		var row: Dictionary = take.duplicate(true)
		row.host = label
		if label != "quest":
			row.actor_scale = StreetCrowdCards.body_scale(TALL_ID)
		takes.append(row)


func collect(host: ArenaRigs) -> void:
	var samples: Array[Dictionary] = [
		quest, {"card": CastFeetFrame.sample_sprite(far)}, CastFeetFrame.sample(host, actor)
	]
	for i: int in takes.size():
		var frames: Array = takes[i].frames
		frames.append(samples[i])


func _ready() -> void:
	far.patrol = StreetCopWalk.Contact.new()
	add_child(far)
	# Leave both out of the near-rig photograph while retaining the same camera basis.
	position = Vector2(2048, 0)


func sample_pose(point: Vector2, dir: Vector2, speed: float) -> void:
	actor.pos = point / SimConst.PX_PER_M + Vector2.UP * 2.0
	actor.facing = dir
	at = point
	facing = dir
	@warning_ignore("return_value_discarded")
	feed.put(0, TALL_ID, BodyPlan.Kind.COP, point, dir * speed)
	feed.looks[0] = ArenaSquadLooks.PATROL_LOOK
	far.pose(feed, 0)
	queue_redraw()


func _draw() -> void:
	if not StreetQuestCards.draw_patrol(self, at, facing, SimConst.PX_PER_M):
		quest = {"error": "quest card was not drawn"}
		return
	var sample: StreetQuestPatrol = StreetQuestCards._contact
	if not StreetQuestCards._moving or sample.path.is_empty():
		quest = {"error": "quest patrol stood still"}
		return
	var tex: Texture2D = StreetStrips.get_tex(sample.path)
	var size_px: Vector2 = tex.get_size() / Vector2(RigHeadCard.FRAMES, sample.drawings)
	var xf: Transform2D = get_global_transform_with_canvas() * sample.placed
	if sample.face.y == 1:
		xf.x = -xf.x
	var coords: Vector2i = Vector2i(sample.face.x, posmod(sample.cell, sample.drawings))
	var rect: Rect2 = Rect2(Vector2(coords) * size_px, size_px)
	var origin: Vector2 = xf * (-size_px * Vector2(0.5, StreetCopWalk.FOOT_Y))
	quest = {"card": CastFeetFrame.record(tex.resource_path, coords, rect, xf, origin)}
