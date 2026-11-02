// One fixed step (SIM-01: the caller passes the fixed TICK_DT): tiers, hash, actors,
// projectiles, counters, in that order.
#include "city_core.h"

namespace gtai::sim {

void CityCore::step(double dt, double camx, double camy, double tgx, double tgy) {
	time_ += dt;
	for (int i = 0; i < CAP; i++) {
		if (alive_[i] == 0) continue;
		int k = kind_[i];
		if ((k == K_PED || k == K_COP) && mode_[i] == M_DEAD) {
			t2_[i] += dt;
			if (t2_[i] > 8.0 || tier_[i] == 1) {
				kill(i);
				continue;
			}
		}
		tier_pass_one(i, camx, camy);
	}
	build_hash(camx, camy);
	flow_update(tgx, tgy);
	for (int i = 0; i < CAP; i++) {
		if (alive_[i] == 0) continue;
		int k = kind_[i];
		if (k == K_PED) ped(i, dt);
		else if (k == K_COP) cop(i, dt, tgx, tgy);
		else car(i, dt, tgx, tgy);
	}
	projectiles(dt);
	count();
}

// Tier A inside RA (or promoted, until 1.6 RB), tier B to RB, despawned beyond.
void CityCore::tier_pass_one(int i, double camx, double camy) {
	double ra2 = ra_ * ra_, rb2 = rb_ * rb_;
	double ddx = px_[i] - camx, ddy = py_[i] - camy;
	double d2 = ddx * ddx + ddy * ddy;
	if (flags_[i] & F_PROMOTED) {
		if (d2 > rb2 * 2.56) {
			kill(i);
			return;
		}
		tier_[i] = 0;
	} else if (d2 < ra2) {
		tier_[i] = 0;
	} else if (d2 < rb2) {
		tier_[i] = 1;
	} else {
		kill(i);
	}
}

void CityCore::count() {
	int32_t c[8] = {0, 0, 0, 0, 0, 0, 0, 0};
	for (int i = 0; i < CAP; i++) {
		if (alive_[i] == 0) continue;
		c[kind_[i]] += 1;
		c[CN_TIER_A + tier_[i]] += 1;
		if (mode_[i] == M_DEAD && (kind_[i] == K_PED || kind_[i] == K_COP)) c[CN_DEAD] += 1;
	}
	for (int k = 0; k < PCAP; k++) c[CN_PROJ] += qalive_[k];
	for (int j = 0; j < 8; j++) counters_[j] = c[j];
}

}  // namespace gtai::sim
