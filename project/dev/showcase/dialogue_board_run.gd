extends Node
## n8-hud evidence (run by dialogue_board.gd): the dialogue box with a face over a plain ground,
## one still per speaker (quest 1's lines read from the package, never edited) at the given size.
## "$GODOT_BIN" --rendering-driver d3d12 --path project -s res://dev/showcase/dialogue_board.gd --
##   --out=<abs dir> --size=1920x1080
## Writes <out>/dialogue_<w>x<h>_<nn>_<speaker>.png; the 0.18 s rise is past when it shoots.

const QUEST: String = "res://quests/collect-call/quest.json"
const LINES: Array[String] = [
	"patch-collect-call",
	"fax-slow-motion",
	"juno-load-bearing",
	"juno-real-name",
	"brass-gloria",
	"kilohm-come-to-me",
	"guard-who-do-we-call",
	"mertz-appliances",
	"rivet-line-stopped",
]
const SETTLE: int = 30

var out_dir: String = "user://"
var size_px: Vector2i = Vector2i(1920, 1080)
var _hud: HudView = HudView.new()
var _feed: HudFeed = HudFeed.new()


func _ready() -> void:
	DisplayServer.window_set_size(size_px)
	get_tree().root.size = size_px
	var ground: ColorRect = ColorRect.new()
	ground.color = Color("6e6a66")
	ground.size = Vector2(size_px)
	add_child(ground)
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	layer.add_child(_hud)
	_run.call_deferred(out_dir, size_px)


func _run(out: String, px: Vector2i) -> void:
	var q: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(QUEST))
	var names: Dictionary = {}
	for c: Dictionary in q["characters"]:
		names[c["id"]] = c["name"]
	var n: int = 0
	for want: String in LINES:
		for l: Dictionary in q["lines"]:
			if l["id"] != want:
				continue
			_hud.state.head = "2/6  Answer the payphone"
			_hud.state.cash = 1500
			var who: String = str(l["speaker"])
			_hud.state.say(str(names[who]), str(l["text"]))
			_feed.face(_hud.state, who, want)
			for i: int in SETTLE:
				await get_tree().process_frame
			var img: Image = get_tree().root.get_texture().get_image()
			var f: String = "%s/dialogue_%dx%d_%02d_%s.png" % [out, px.x, px.y, n, who]
			@warning_ignore("return_value_discarded")
			img.save_png(f)
			n += 1
			_hud.state.silent()
			for i: int in 20:
				await get_tree().process_frame
	get_tree().quit(0)
