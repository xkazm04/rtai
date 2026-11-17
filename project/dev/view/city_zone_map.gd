extends SceneTree
## The generated city as a plan (n18 districts evidence): every 1 m cell of every chunk coloured by
## its cell code (lane, kerb-side, walk, building, prop), each chunk's zone as a tint, and the
## zone numbers (chunks, blocks, junctions, cells per kind) as JSON. Headless, no GPU; reads the
## generator directly (not the baked files), so it shows the working tree's rows.
## Usage: godot --headless --path project -s res://dev/view/city_zone_map.gd --
##   --out=<abs path, no ext>
##   [--scale=<px per m, 1 or 2>] [--rect=<x0>,<y0>,<w>,<h> in chunks]

const KNOWN_FLAGS: PackedStringArray = ["--out", "--scale", "--rect"]
## CitySystem.DISTRICT / TEXTURES: CitySystem needs the autoloads, which a -s script has not.
const DISTRICT: String = "res://data/tables/city_district.json"
const TEXTURES: String = "res://data/tables/city_textures.json"
const CELL_RGB: Array[Color] = [
	Color(0.0, 0.0, 0.0),
	Color(0.22, 0.22, 0.24),
	Color(0.36, 0.36, 0.38),
	Color(0.72, 0.72, 0.68),
	Color(0.5, 0.42, 0.34),
	Color(0.9, 0.85, 0.2),
]
const ZONE_TINT: Dictionary[StringName, Color] = {
	&"mixed": Color(1, 1, 1),
	&"docks": Color(0.75, 0.85, 1.15),
	&"downtown": Color(1.15, 1.0, 0.8),
}


func _initialize() -> void:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		var key: String = arg.split("=")[0]
		if not KNOWN_FLAGS.has(key):
			printerr("city_zone_map: unknown argument %s" % arg)
			quit(2)
			return
		args[key] = arg.substr(key.length() + 1)
	if not args.has("--out"):
		printerr("city_zone_map: --out=<path> is required")
		quit(2)
		return
	var rect: PackedStringArray = str(args.get("--rect", "0,0,16,16")).split(",")
	var r: Rect2i = Rect2i(rect[0].to_int(), rect[1].to_int(), rect[2].to_int(), rect[3].to_int())
	quit(_run(str(args["--out"]), r, maxi(str(args.get("--scale", "1")).to_int(), 1)))


func _run(out: String, r: Rect2i, scale: int) -> int:
	var gen: CityGen = CityGen.from_tables(DISTRICT, TEXTURES)
	var n: int = SimConst.CHUNK_CELLS
	var img: Image = Image.create(
		r.size.x * n * scale, r.size.y * n * scale, false, Image.FORMAT_RGB8
	)
	var stats: Dictionary = {}
	var t0: int = Time.get_ticks_msec()
	for cy: int in range(r.position.y, r.end.y):
		for cx: int in range(r.position.x, r.end.x):
			var chunk: CityChunk = gen.gen_chunk(cx, cy)
			var zone: StringName = gen.zones.id_of_chunk(cx, cy)
			_count(stats, zone, chunk)
			var tint: Color = ZONE_TINT.get(zone, Color(1, 1, 1))
			for y: int in n:
				for x: int in n:
					var c: Color = (
						CELL_RGB[mini(chunk.cells[y * n + x], CELL_RGB.size() - 1)] * tint
					)
					var px: Vector2i = Vector2i(
						(cx - r.position.x) * n + x, (cy - r.position.y) * n + y
					)
					img.fill_rect(Rect2i(px * scale, Vector2i(scale, scale)), c.clamp())
	stats["gen_ms"] = Time.get_ticks_msec() - t0
	var err: int = img.save_png(out + ".png")
	var f: FileAccess = FileAccess.open(out + ".json", FileAccess.WRITE)
	if err != OK or f == null:
		return 1
	var wrote: bool = f.store_string(JSON.stringify(stats, "  ", true))
	f.close()
	if not wrote:
		return 1
	printerr("city_zone_map: %s.png, %s" % [out, JSON.stringify(stats)])
	return 0


func _count(stats: Dictionary, zone: StringName, chunk: CityChunk) -> void:
	var z: Dictionary = stats.get_or_add(str(zone), {"chunks": 0, "tiles": {}, "cells": {}})
	z["chunks"] += 1
	var tiles: Dictionary = z["tiles"]
	var cells: Dictionary = z["cells"]
	_tally(tiles, chunk.tiles)
	_tally(cells, chunk.cells)


func _tally(into: Dictionary, codes: PackedByteArray) -> void:
	for code: int in codes:
		var was: int = into.get(str(code), 0)
		into[str(code)] = was + 1
