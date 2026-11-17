class_name CitySimTier
extends RefCounted
## The reference sim's tiering pass (CitySimRef.step, op for op native world.cpp's): split out of
## city_sim_ref.gd (n18) to keep that file under its size cap.


## Despawns dead bodies after 8 s (or at once in tier B) and re-tiers everyone by distance.
static func tier(s: CitySimState, dt: float, camx: float, camy: float) -> void:
	var ra2: float = s.ra * s.ra
	var rb2: float = s.rb * s.rb
	for i: int in SimConst.CAP:
		if s.alive[i] == 0:
			continue
		var k: int = s.kind[i]
		if (k == SimConst.K_PED or k == SimConst.K_COP) and s.mode[i] == SimConst.M_DEAD:
			s.t2[i] += dt
			if s.t2[i] > 8.0 or s.tier[i] == 1:
				s.kill(i)
				continue
		var ddx: float = s.px[i] - camx
		var ddy: float = s.py[i] - camy
		var d2: float = ddx * ddx + ddy * ddy
		if (s.flags[i] & SimConst.F_PROMOTED) != 0:
			if d2 > rb2 * 2.56:
				s.kill(i)
				continue
			s.tier[i] = 0
		elif d2 < ra2:
			s.tier[i] = 0
		elif d2 < rb2:
			s.tier[i] = 1
		else:
			s.kill(i)
