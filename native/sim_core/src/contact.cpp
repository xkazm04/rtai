// Tier-A contact for people: separation from nearby people, then push-out from solid cells.
// Both work on the scratch position (cx_, cy_).
#include "city_core.h"
#include "sim_math.h"

namespace gtai::sim {

void CityCore::crowd(int i) {
	int n = query(cx_, cy_, 1, qbuf_);
	for (int q = 0; q < n; q++) {
		int j = qbuf_[q];
		if (j == i) continue;
		int kj = kind_[j];
		if ((kj != K_PED && kj != K_COP) || mode_[j] == M_DEAD) continue;
		double ddx = cx_ - px_[j], ddy = cy_ - py_[j];
		double d2 = ddx * ddx + ddy * ddy;
		if (d2 < 0.49 && d2 > 1e-9) {
			double d = std::sqrt(d2);
			double push = (0.7 - d) * 0.5;
			cx_ += ddx / d * push;
			cy_ += ddy / d * push;
		}
	}
}

// Circle of radius r against solid 1 m cells (building, prop, unloaded).
void CityCore::solid(double r) {
	int x0 = floori(cx_ - r), x1 = floori(cx_ + r), y0 = floori(cy_ - r), y1 = floori(cy_ + r);
	for (int gy = y0; gy <= y1; gy++) {
		for (int gx = x0; gx <= x1; gx++) {
			int c = 0;
			if (gx >= 0 && gy >= 0 && gx < W && gy < W) c = cells_[(size_t)gy * W + gx];
			if (c != 0 && c < 4) continue;
			double qxx = clampf(cx_, (double)gx, (double)gx + 1.0);
			double qyy = clampf(cy_, (double)gy, (double)gy + 1.0);
			double ddx = cx_ - qxx, ddy = cy_ - qyy;
			double d2 = ddx * ddx + ddy * ddy;
			if (d2 >= r * r) continue;
			if (d2 > 1e-12) {
				double d = std::sqrt(d2);
				cx_ += ddx / d * (r - d);
				cy_ += ddy / d * (r - d);
				continue;
			}
			double l = cx_ - (double)gx, rr = (double)gx + 1.0 - cx_;
			double u = cy_ - (double)gy, dd = (double)gy + 1.0 - cy_;
			double mm = minf(minf(l, rr), minf(u, dd));
			if (mm == l) cx_ = (double)gx - r;
			else if (mm == rr) cx_ = (double)gx + 1.0 + r;
			else if (mm == u) cy_ = (double)gy - r;
			else cy_ = (double)gy + 1.0 + r;
		}
	}
}

}  // namespace gtai::sim
