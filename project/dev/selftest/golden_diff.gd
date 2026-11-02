class_name GoldenDiff
extends RefCounted
## Compares a frame with its golden (same size): the mean absolute channel difference in 0..255
## and the fraction of pixels whose largest channel difference exceeds `far` (0..1).


static func compare(img: Image, gold: Image, far: float) -> Dictionary:
	if gold == null or gold.is_empty():
		return {"found": false, "mean": 255.0, "far": 1.0}
	if gold.get_size() != img.get_size():
		return {"found": true, "mean": 255.0, "far": 1.0, "why": "size %s" % gold.get_size()}
	var a: Image = img.duplicate() as Image
	var b: Image = gold.duplicate() as Image
	a.convert(Image.FORMAT_RGB8)
	b.convert(Image.FORMAT_RGB8)
	var pa: PackedByteArray = a.get_data()
	var pb: PackedByteArray = b.get_data()
	var total: int = 0
	var far_px: int = 0
	var far_b: int = int(far * 255.0)
	for i: int in range(0, pa.size(), 3):
		var dr: int = absi(pa[i] - pb[i])
		var dg: int = absi(pa[i + 1] - pb[i + 1])
		var db: int = absi(pa[i + 2] - pb[i + 2])
		total += dr + dg + db
		if maxi(dr, maxi(dg, db)) > far_b:
			far_px += 1
	var n: int = pa.size() / 3
	return {"found": true, "mean": float(total) / float(pa.size()), "far": float(far_px) / float(n)}
