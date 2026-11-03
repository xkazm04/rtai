// Cars, part 4: passing a stopped service car. A tier-A traffic car that has stood behind an
// obstacle (set_obstacles) in its own lane for PASS_WAIT_S, mid-block, with the oncoming lane
// clear, steers into the oncoming lane until every obstacle is PASS_BACK_M behind it. Mirrored by
// CitySimCarPass (GDScript reference sim); parity stays exact.
#include "city_core.h"
#include "sim_math.h"

namespace gtai::sim {

namespace {
constexpr double PASS_WAIT_S = 2.5;   // standing behind the obstacle before pulling out
constexpr double PASS_ABORT_S = 6.0;  // standing while passing: give up, back to the own lane
constexpr double PASS_BACK_M = 7.0;   // obstacles this far behind: the pass is over
}  // namespace

void CityCore::car_pass(Car &c) {
	int i = c.i;
	c.ln = lane_[i];
	if (c.is_p || tier_[i] != 0) {
		flags_[i] = (uint8_t)(flags_[i] & ~F_PASSING);
		return;
	}
	double other = lane_[i] - 2.0 * LANE_OFF[c.d];
	bool passing = (flags_[i] & F_PASSING) != 0;
	if (passing) {
		if (stuck_[i] > PASS_ABORT_S || !car_obst_in(c, lane_[i], -PASS_BACK_M, 14.0)) {
			flags_[i] = (uint8_t)(flags_[i] & ~F_PASSING);
			passing = false;
		}
	} else if (stuck_[i] > PASS_WAIT_S && ndir_[i] < 0 && car_obst_in(c, lane_[i], 0.0, 12.0) &&
			!car_obst_in(c, other, -6.0, 20.0) && car_lane_clear(c, other)) {
		flags_[i] = (uint8_t)(flags_[i] | F_PASSING);
		passing = true;
	}
	if (passing) c.ln = other;
}

// An obstacle point within (a, b) metres along the car's direction and 1.8 m of lane line ln.
bool CityCore::car_obst_in(const Car &c, double ln, double a, double b) const {
	bool horiz = c.d == 0 || c.d == 2;
	for (int k = 0; k < obst_n_; k++) {
		double ox = obst_[k * 2], oy = obst_[k * 2 + 1];
		double along = (ox - c.x) * c.ddx + (oy - c.y) * c.ddy;
		double lat = std::fabs((horiz ? oy : ox) - ln);
		if (along > a && along < b && lat < 1.8) return true;
	}
	return false;
}

// No live car on lane line ln from 8 m behind to 36 m ahead of this one.
bool CityCore::car_lane_clear(const Car &c, double ln) {
	bool horiz = c.d == 0 || c.d == 2;
	double qx = horiz ? c.x + c.ddx * 16.0 : ln;
	double qy = horiz ? ln : c.y + c.ddy * 16.0;
	int n = query(qx, qy, 6, qbuf_);
	for (int q = 0; q < n; q++) {
		int j = qbuf_[q];
		if (j == c.i || alive_[j] == 0) continue;
		if (kind_[j] != K_CAR && kind_[j] != K_PCAR) continue;
		double along = (px_[j] - c.x) * c.ddx + (py_[j] - c.y) * c.ddy;
		double lat = std::fabs((horiz ? py_[j] : px_[j]) - ln);
		if (along > -8.0 && along < 36.0 && lat < 2.0) return false;
	}
	return true;
}

}  // namespace gtai::sim
