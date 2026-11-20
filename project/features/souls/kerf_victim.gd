class_name KerfVictim
extends RefCounted
## Draw the spectral slot across the posed guard before revealing the split edges.

const REVEAL_TICKS: int = 4


class EdgeHold:
	extends Node
	var kills: SignatureKills
	var reveal_tick: int
	var edges: Array[KillCutEdge] = []

	func _process(_delta: float) -> void:
		if kills.tick < reveal_tick:
			return
		for edge: KillCutEdge in edges:
			edge.show()
		queue_free()


static func spectral(row: SignatureKill) -> bool:
	return row.id == &"kerf_split" and GhostLook.spectral(&"kerf")


static func flash_ticks(row: SignatureKill) -> int:
	return 0 if spectral(row) else row.flash_ticks


static func streak(
	row: SignatureKill, streaks: Dictionary[int, Vector4], serial: int, stroke: Vector4
) -> void:
	if not spectral(row):
		streaks[serial] = stroke


## The sim already holds the posed halves together during hitstop. Hide only their ink and
## hot edges until the fourth kill tick. The holder owns this short-lived reveal.
static func holder(row: SignatureKill, groups: Array[Node2D], kills: SignatureKills) -> Node2D:
	var body: Node2D = Node2D.new()
	if not spectral(row):
		return body
	var hold: EdgeHold = EdgeHold.new()
	hold.kills = kills
	# The press lands in ArenaStage before BrutalityHook advances kills.tick for that step.
	var press_tick: int = kills.tick + 1
	hold.reveal_tick = press_tick + REVEAL_TICKS
	for half: Node2D in groups:
		if half == null:
			continue
		for part: Node in half.get_children():
			var edge: KillCutEdge = part as KillCutEdge
			if edge != null:
				edge.hide()
				hold.edges.append(edge)
	body.add_child(hold)
	return body
