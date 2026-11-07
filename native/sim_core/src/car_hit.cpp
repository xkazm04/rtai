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
			double hf = c.bike ? BIKE_HIT_F : 2.6, hs = c.bike ? BIKE_HIT_S : 1.3;
			if (!(std::fabs(f) < hf && std::fabs(s) < hs)) continue;
			if (c.vv > 4.0) {
				mode_[j] = M_DEAD;
				t2_[j] = 0.0;
				v_[j] = c.vv * 0.5;
				hx_[j] = c.hhx;
				hy_[j] = c.hhy;
				counters_[CN_KILLED] += 1;
			} else {
				double sg = s >= 0.0 ? 1.0 : -1.0;
				double push = (c.bike ? 0.675 : 1.35) - std::fabs(s);
				px_[j] += -c.hhy * sg * push;
				py_[j] += c.hhx * sg * push;
			}
			continue;
		}
		double d2 = rx * rx + ry * ry;
		if (c.bike || is_bike(j)) {
			car_push(c, j, rx, ry, d2);
		} else if (d2 < 4.84 && d2 > 1e-9) {
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

// d9: a bike in a car-car contact: a shorter reach, and the lighter body takes more of the overlap.
void CityCore::car_push(Car &c, int j, double rx, double ry, double d2) {
	bool both = c.bike && is_bike(j);
	double rr = both ? BIKE_RR2 : BIKE_RR;
	if (!(d2 < rr * rr && d2 > 1e-9)) return;
	double dd = std::sqrt(d2);
	double share = both ? 0.5 : (c.bike ? BIKE_SHARE : 1.0 - BIKE_SHARE);
	double over = rr - dd;
	c.x -= rx / dd * over * share;
	c.y -= ry / dd * over * share;
	px_[j] += rx / dd * over * (1.0 - share);
	py_[j] += ry / dd * over * (1.0 - share);
	c.vv *= 0.9;
}

// Six hull sample points against solid cells: push out along the shallowest axis.
void CityCore::car_hull(Car &c) {
	for (int p = 0; p < 6; p++) {
		double hf = c.bike ? BIKE_HULL_F : 2.3, hs = c.bike ? BIKE_HULL_S : 0.95;
		double f = p < 2 ? hf : (p < 4 ? -hf : 0.0);
		double s = (p % 2) == 0 ? hs : -hs;
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
