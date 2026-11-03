class_name NoirParts
extends RefCounted
## D-Noir part redraws (lane noir, dev only): every png in art/noir/<kind>/ replaces the part of
## that name in the shared PartLibrary cache. Call it BEFORE any rig of that kind is built (or a
## crowd atlas baked). Same sizes, same alpha, same pivots as the D4 parts (masters slice_noir.py).

const NOIR_ART: String = "res://features/characters/art/noir/"


static func wear(kinds: PackedStringArray) -> int:
	var n: int = 0
	for kind: String in kinds:
		var lib: PartLibrary = PartLibrary.of(kind)
		for file: String in ResourceLoader.list_directory(NOIR_ART + kind):
			if file.ends_with(".png"):
				var path: String = NOIR_ART + kind + "/" + file
				lib.textures[file.get_basename()] = load(path) as Texture2D
				n += 1
	return n
