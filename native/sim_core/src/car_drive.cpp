// Cars, part 2: steering toward the lane and the desired speed (junction, waiting, following).
#include "city_core.h"
#include "sim_math.h"

namespace gtai::sim {

// Steer toward a point 6 m ahead on the lane.
void CityCore::car_steer(Car &c, double dt) {
	int i = c.i;
	double tx = 0.0, ty = 0.0;
	if (c.d == 0 || c.d == 2) {
		tx = c.x + c.ddx * 6.0;
		ty = lane_[i];
	} else {
		tx = lane_[i];
		ty = c.y + c.ddy * 6.0;
	}
	double ax = tx - c.x, ay = ty - c.y;
	double l = std::sqrt(ax * ax + ay * ay);
	c.hhx = hx_[i];
	c.hhy = hy_[i];
	if (l > 1e-6) {
		double kk = minf(1.0, (1.5 + v_[i] * 0.25) * dt);
		c.hhx += (ax / l - c.hhx) * kk;
		c.hhy += (ay / l - c.hhy) * kk;
		double hl = std::sqrt(c.hhx * c.hhx + c.hhy * c.hhy);
		c.hhx /= hl;
		c.hhy /= hl;
	}
}

double CityCore::car_desired_speed(const Car &c) {
	int i = c.i;
	double vdes = vmax_[i];
	if (ndir_[i] >= 0 && ndir_[i] != c.d) vdes = minf(vdes, 7.0);
	if (c.waiting) {
		double along2 = c.x * c.ddx + c.y * c.ddy;
		double dist = (jx_[i] * c.ddx + jy_[i] * c.ddy) - along2 - 14.0;
		vdes = minf(vdes, maxf(0.0, dist));
	}
	if (tier_[i] != 0 || c.is_p) return vdes;
	int n = query(c.x + c.hhx * 7.0, c.y + c.hhy * 7.0, 1, qbuf_);
	for (int q = 0; q < n; q++) {
		int j = qbuf_[q];
		if (j == i) continue;
		double rx = px_[j] - c.x, ry = py_[j] - c.y;
		double f = rx * c.hhx + ry * c.hhy;
		double s = std::fabs(rx * c.hhy - ry * c.hhx);
		int kj = kind_[j];
		if (kj == K_CAR || kj == K_PCAR) {
			if (f > 0.0 && f < 12.0 && s < 1.8) vdes = minf(vdes, maxf(0.0, f - 5.5) * 1.4);
		} else if (mode_[j] != M_DEAD) {
			if (f > 0.0 && f < 7.0 && s < 1.6) vdes = minf(vdes, maxf(0.0, f - 3.0) * 1.5);
		}
	}
	return vdes;
}

}  // namespace gtai::sim
