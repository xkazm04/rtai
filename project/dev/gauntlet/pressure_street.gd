class_name PressureStreet
extends RefCounted
## Dev takes only. The street's side walls stand 12 m apart, too close for the 10 m circle the
## rocket measurement used. This pushes each retained block's two long walls outward, drops the
## loose cover and rebuilds the stage's solids and route map from the result. Never data.


static func widen(session: GauntletSession, shift_m: float) -> void:
	for block: GauntletSegment in session.street.window:
		var kept: Array[ArenaStation.Prop] = []
		for prop: ArenaStation.Prop in block.station.props:
			if prop.kind != "wall_high" or prop.size.x < block.length_m:
				continue
			prop.at.y += shift_m if prop.at.y > block.bounds.get_center().y else -shift_m
			kept.append(prop)
		block.station.props = kept
		block.bounds = Rect2(kept[0].at - kept[0].size * 0.5, kept[0].size)
		for prop: ArenaStation.Prop in kept:
			block.bounds = block.bounds.merge(Rect2(prop.at - prop.size * 0.5, prop.size))
	session.street._install(session.stage)
