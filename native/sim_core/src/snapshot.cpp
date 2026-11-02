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

}  // namespace gtai::sim
