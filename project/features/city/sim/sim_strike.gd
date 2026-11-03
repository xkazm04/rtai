class_name CitySimStrike
extends RefCounted
## A car hit a person (the vehicles feature's one write into the bubble sim): lethal = dead, the
## body slides along the hit; else a knockdown, shoved 1 m along the hit, then fleeing 3 s.
## Operation for operation the native CityCore::strike (spawn.cpp), so parity holds.


static func strike(s: CitySimState, i: int, vx: float, vy: float, lethal: bool) -> void:
	if i < 0 or i >= SimConst.CAP or s.alive[i] == 0 or s.mode[i] == SimConst.M_DEAD:
		return
	if s.kind[i] != SimConst.K_PED and s.kind[i] != SimConst.K_COP:
		return
	var sp: float = sqrt(vx * vx + vy * vy)
	if sp < 1e-9:
		return
	var dx: float = vx / sp
	var dy: float = vy / sp
	if lethal:
		s.mode[i] = SimConst.M_DEAD
		s.t2[i] = 0.0
		s.v[i] = sp * 0.5
		s.hx[i] = dx
		s.hy[i] = dy
		s.counters[SimConst.CN_KILLED] += 1
		return
	s.px[i] += dx
	s.py[i] += dy
	s.mode[i] = SimConst.M_FLEE
	s.t1[i] = 3.0
	s.sx[i] = s.px[i] - dx * 4.0
	s.sy[i] = s.py[i] - dy * 4.0
