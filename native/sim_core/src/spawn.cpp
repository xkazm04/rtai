// Spawn, kill and fire: the rare per-actor calls (NAT-02).
#include "city_core.h"

namespace gtai::sim {

int CityCore::spawn(const double *spec) {
	int k = (int)spec[SP_KIND];
	int fl = (int)spec[SP_FLAGS];
	double x = spec[SP_X], y = spec[SP_Y], ln = spec[SP_LANE];
	for (int i = 0; i < CAP; i++) {
		if (alive_[i] != 0) continue;
		alive_[i] = 1;
		kind_[i] = (uint8_t)k;
		tier_[i] = 1;
		variant_[i] = (uint8_t)(int)spec[SP_VARIANT];
		flags_[i] = (uint8_t)fl;
		mode_[i] = (fl & F_RIOTER) ? M_RIOT : M_WALK;
		px_[i] = x;
		py_[i] = y;
		hx_[i] = spec[SP_DX];
		hy_[i] = spec[SP_DY];
		v_[i] = 0.0;
		vmax_[i] = spec[SP_VMAX];
		phase_[i] = 0.0;
		t1_[i] = 0.0;
		t2_[i] = (k == K_COP) ? 1.0 : 0.0;
		sx_[i] = x;
		sy_[i] = y;
		lane_[i] = ln;
		nlane_[i] = ln;
		jx_[i] = jy_[i] = stuck_[i] = 0.0;
		dir_[i] = (int)spec[SP_DIR];
		ndir_[i] = -1;
		res_[i] = -1;
		return i;
	}
	return -1;
}

void CityCore::set_riot_centre(int i, double x, double y) {
	sx_[i] = x;
	sy_[i] = y;
}

void CityCore::kill(int i) {
	alive_[i] = 0;
	int r = res_[i];
	if (r >= 0 && owner_[r] == i + 1) owner_[r] = 0;
	res_[i] = -1;
	counters_[CN_DESPAWNED] += 1;
}

void CityCore::fire(double x, double y, double vx, double vy, double ttl) {
	for (int k = 0; k < PCAP; k++) {
		if (qalive_[k] != 0) continue;
		qalive_[k] = 1;
		qx_[k] = x;
		qy_[k] = y;
		qvx_[k] = vx;
		qvy_[k] = vy;
		qt_[k] = ttl;
		return;
	}
}

}  // namespace gtai::sim
