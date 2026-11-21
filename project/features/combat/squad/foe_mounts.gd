class_name FoeMounts
extends ArenaHook
## Station weapons and body contacts can displace a fighter after its brain has run.
## A bolted mount ends every arena tick at its spawn, including the tick of a lethal hit.

var host: WeakRef
var anchors: Dictionary[Fighter, Vector2] = {}


func pin(h: Fighter) -> void:
	anchors[h] = h.pos
	var stage: ArenaStage = host.get_ref() if host != null else null
	if stage != null and not stage.hooks.has(self):
		stage.hooks.append(self)


func step(_stage: ArenaStage, _tick: int) -> void:
	for h: Fighter in anchors:
		h.pos = anchors[h]
