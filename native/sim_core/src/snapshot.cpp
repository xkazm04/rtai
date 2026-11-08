// The parity digest (NAT-06): every float of every live slot in slot order, then projectiles.
#include "city_core.h"

namespace gtai::sim {

std::vector<double> CityCore::snapshot() const {
	std::vector<double> out;
	for (int i = 0; i < CAP; i++) {
		if (alive_[i] == 0) continue;
		const double a[SNAP_STRIDE] = {(double)i, (double)kind_[i], (double)mode_[i],
			(double)tier_[i], px_[i], py_[i], hx_[i], hy_[i], v_[i], phase_[i], t1_[i], t2_[i],
			(double)dir_[i], (double)ndir_[i]};
		out.insert(out.end(), a, a + SNAP_STRIDE);
	}
	for (int k = 0; k < PCAP; k++) {
		if (qalive_[k] == 0) continue;
		out.push_back((double)(SNAP_PROJ_BASE + k));
		out.push_back(qx_[k]);
		out.push_back(qy_[k]);
	}
	return out;
}

void scan_dead_flips(const double *snap, int64_t n, const uint8_t *dead, int64_t dead_n,
		std::vector<int32_t> &out) {
	out.clear();
	out.push_back(0);
	int64_t r = 0;
	while (r + SNAP_STRIDE <= n && snap[r] < SNAP_PROJ_BASE) {
		const int64_t i = (int64_t)snap[r];
		const int kind = (int)snap[r + 1];
		if (i >= 0 && i < dead_n && (kind == K_PED || kind == K_COP) &&
				(((int)snap[r + 2] == M_DEAD) != (dead[i] != 0))) {
			out.push_back((int32_t)r);
		}
		r += SNAP_STRIDE;
	}
	out[0] = (int32_t)r;
}

}  // namespace gtai::sim
