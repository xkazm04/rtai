// Cars, part 3 (tier A only): hitting or nudging people, car-car push, hull vs solid cells.
#include "city_core.h"
#include "sim_math.h"

namespace gtai::sim {

void CityCore::car_contacts(Car &c) {
	int i = c.i;
	int n = query(c.x, c.y, 1, qbuf_);
	for (int q = 0; q < n; q++) {
		int j = qbuf_[q];
		if (j == i || alive_[j] == 0) continue;
		int kj = kind_[j];
		double rx = px_[j] - c.x, ry = py_[j] - c.y;
		if (kj == K_PED || kj == K_COP) {
			if (mode_[j] == M_DEAD) continue;
			double f = rx * c.hhx + ry * c.hhy;
			double s = -rx * c.hhy + ry * c.hhx;
			if (!(std::fabs(f) < 2.6 && std::fabs(s) < 1.3)) continue;
			if (c.vv > 4.0) {
				mode_[j] = M_DEAD;
				t2_[j] = 0.0;
				v_[j] = c.vv * 0.5;
				hx_[j] = c.hhx;
				hy_[j] = c.hhy;
				counters_[CN_KILLED] += 1;
			} else {
				double sg = s >= 0.0 ? 1.0 : -1.0;
				double push = 1.35 - std::fabs(s);
				px_[j] += -c.hhy * sg * push;
				py_[j] += c.hhx * sg * push;
			}
			continue;
		}
		double d2 = rx * rx + ry * ry;
		if (d2 < 4.84 && d2 > 1e-9) {
			double dd = std::sqrt(d2);
			double push = (2.2 - dd) * 0.5;
			c.x -= rx / dd * push;
			c.y -= ry / dd * push;
			px_[j] += rx / dd * push;
			py_[j] += ry / dd * push;
			c.vv *= 0.9;
		}
	}
}

// Six hull sample points against solid cells: push out along the shallowest axis.
void CityCore::car_hull(Car &c) {
	for (int p = 0; p < 6; p++) {
		double f = p < 2 ? 2.3 : (p < 4 ? -2.3 : 0.0);
		double s = (p % 2) == 0 ? 0.95 : -0.95;
		double qxx = c.x + c.hhx * f - c.hhy * s;
		double qyy = c.y + c.hhy * f + c.hhx * s;
		int ix = floori(qxx), iy = floori(qyy);
		int cell = 0;
		if (ix >= 0 && iy >= 0 && ix < W && iy < W) cell = cells_[(size_t)iy * W + ix];
		if (cell != 0 && cell < 4) continue;
		double lft = qxx - (double)ix, rgt = (double)ix + 1.0 - qxx;
		double up = qyy - (double)iy, dn = (double)iy + 1.0 - qyy;
		double mm = minf(minf(lft, rgt), minf(up, dn));
		if (mm == lft) c.x -= lft + 0.01;
		else if (mm == rgt) c.x += rgt + 0.01;
		else if (mm == up) c.y -= up + 0.01;
		else c.y += dn + 0.01;
		c.vv *= 0.7;
	}
}

}  // namespace gtai::sim
