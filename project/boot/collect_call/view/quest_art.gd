class_name QuestArt
extends RefCounted
## Quest 1's art table (data/tables/collect_call_art.json) through ArtIds, loaded once per run and
## shared by CastView, StageView and FxView: they name ids, never paths.

const TABLE: String = "res://data/tables/collect_call_art.json"
const SCHEMA: String = "gtai.collect-call-art/1"

static var _shared: ArtIds = null


static func shared() -> ArtIds:
	if _shared == null:
		_shared = ArtIds.new(TABLE, SCHEMA, "quest1")
	return _shared
