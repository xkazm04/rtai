class_name KerfVictim
extends RefCounted
## Keep the spectral slice victim in front of the Ronin while the two halves react.

const REVEAL_TICKS: int = 4
const REACTION_TICKS: int = 30


class Reaction:
	extends Node2D
	var kills: SignatureKills
	var press_tick: int
	var edges: Array[KillCutEdge] = []

	func _process(_delta: float) -> void:
		var age: int = kills.tick - press_tick
		if age < REVEAL_TICKS:
			return
		for edge: KillCutEdge in edges:
			edge.show()
		edges.clear()
		if age >= REACTION_TICKS:
			z_index = 0
			z_as_relative = true
			set_process(false)


static func spectral(row: SignatureKill) -> bool:
	return row.id == &"kerf_split" and GhostLook.spectral(&"kerf")


static func flash_ticks(row: SignatureKill) -> int:
	return 0 if spectral(row) else row.flash_ticks


static func streak(
	row: SignatureKill, streaks: Dictionary[int, Vector4], serial: int, stroke: Vector4
) -> void:
	if not spectral(row):
		streaks[serial] = stroke


## The press lands in ArenaStage before BrutalityHook advances the kill clock for that step.
static func holder(row: SignatureKill, groups: Array[Node2D], kills: SignatureKills) -> Node2D:
	if not spectral(row):
		return Node2D.new()
	var body: Reaction = Reaction.new()
	body.kills = kills
	body.press_tick = kills.tick + 1
	body.z_as_relative = false
	body.z_index = RenderLayers.z(&"actors") + GhostFormView.Z_OVER_RIGS + 1
	for half: Node2D in groups:
		if half == null:
			continue
		for part: Node in half.get_children():
			var edge: KillCutEdge = part as KillCutEdge
			if edge != null:
				edge.hide()
				body.edges.append(edge)
	return body
