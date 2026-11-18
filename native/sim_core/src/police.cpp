// n18 living police: heat drives the city's foot cops. heat_level_ -1 (the default) never comes
// here. Heat 0: every cop walks his sidewalk like a pedestrian, holding fire. Heat 1-3: the
// pol_[PT_FOOT<level>] cops nearest the last-seen point are engaged (F_ENGAGED, nearest first,
// lowest slot on a tie): they path to the point on the flow field, steer at Rivet and fire only
// with him in sight, and search pol_[PT_SEARCH_S] once one is within PT_ARRIVE_M of it (the clock
// waits while a dispatched car drives or a crew cop walks there); then all
// go back to walking until the point moves to another cell or the level rises.
// Heat 2 (the game dispatches police cars, F_ENGAGED): a dispatched car routes to the point with
// the police turn rule, stops within PT_CAR_STOP_M of it and parks (F_PARKED); its PT_CREW cops
// get out on the side facing the point as engaged foot cops (F_CREW, outside the PT_FOOT count).
// When the search ends or heat falls to 0 every claim is cancelled: crews walk, cars drive on.
// GDScript reference: project/features/city/sim/sim_police.gd + sim_cops.gd (op for op, parity).
#include <cmath>

#include "city_core.h"

namespace gtai::sim {

void CityCore::set_police(const double *tune, int n) {
	for (int k = 0; k < PT_LEN && k < n; k++) pol_[k] = tune[k];
}

void CityCore::police_pass(double dt) {
	int cx = (int)std::floor(heat_x_), cy = (int)std::floor(heat_y_);
	if (cx != pol_cx_ || cy != pol_cy_ || heat_level_ > pol_level_) {
		pol_cx_ = cx;
		pol_cy_ = cy;
		pol_search_ = 0.0;
		pol_done_ = false;
	}
	pol_level_ = heat_level_;
	int want = (heat_level_ == 0 || pol_done_) ? 0 : (int)pol_[PT_FOOT0 + heat_level_];
	double a2 = pol_[PT_ARRIVE_M] * pol_[PT_ARRIVE_M];
	bool arrived = false, enroute = false;  // the search waits for cars en route and crews walking
	for (int i = 0; i < CAP; i++) {
		if (alive_[i] == 0 || (flags_[i] & F_ENGAGED) == 0) continue;
		if (kind_[i] == K_PCAR) enroute = true;
		if (kind_[i] != K_COP) continue;
		if (mode_[i] == M_DEAD) {
			flags_[i] = flags_[i] & ~F_ENGAGED;
			continue;
		}
		double ax = px_[i] - heat_x_, ay = py_[i] - heat_y_;
		if (ax * ax + ay * ay <= a2) {
			arrived = true;
		} else if ((flags_[i] & F_CREW) != 0) {
			enroute = true;
		}
	}
	if (arrived && !enroute && !pol_done_) {
		pol_search_ += dt;
		if (pol_search_ >= pol_[PT_SEARCH_S]) {
			pol_done_ = true;
			want = 0;
		}
	}
	if (want == 0) police_release();
	police_fill(want);
	ff_stats_[FS_SEARCH_TICKS] = (int32_t)std::floor(pol_search_ / dt + 0.5);
}

// Every claim cancelled: cops (crews too) walk, police cars drive on as traffic.
void CityCore::police_release() {
	for (int i = 0; i < CAP; i++) {
		if (alive_[i] == 0) continue;
		if (kind_[i] == K_COP) flags_[i] = flags_[i] & ~(F_ENGAGED | F_CREW);
		else if (kind_[i] == K_PCAR) flags_[i] = flags_[i] & ~(F_ENGAGED | F_PARKED);
	}
}

// Engage or release cops until want are engaged: release the farthest first, engage the nearest.
// A car's crew is outside the count.
void CityCore::police_fill(int want) {
	int n = 0;
	for (int i = 0; i < CAP; i++) {
		if (alive_[i] != 0 && kind_[i] == K_COP && (flags_[i] & (F_ENGAGED | F_CREW)) == F_ENGAGED) n++;
	}
	while (n != want) {
		bool add = n < want;
		int pick = -1;
		double best = 0.0;
		for (int i = 0; i < CAP; i++) {
			if (alive_[i] == 0 || kind_[i] != K_COP || mode_[i] == M_DEAD) continue;
			if (((flags_[i] & F_ENGAGED) != 0) == add || (flags_[i] & F_CREW) != 0) continue;
			double ax = px_[i] - heat_x_, ay = py_[i] - heat_y_;
			double d2 = ax * ax + ay * ay;
			if (pick < 0 || (add ? d2 < best : d2 > best)) {
				pick = i;
				best = d2;
			}
		}
		if (pick < 0) break;
		flags_[pick] = add ? (flags_[pick] | F_ENGAGED) : (flags_[pick] & ~F_ENGAGED);
		n += add ? 1 : -1;
	}
	ff_stats_[FS_ENGAGED] = n;
}

void CityCore::cop_heat(int i, double dt, double tgx, double tgy) {
	if ((flags_[i] & F_ENGAGED) == 0) {
		cop_walk(i, dt);
		return;
	}
	double x = px_[i], y = py_[i];
	double rx = tgx - x, ry = tgy - y;
	double dr = std::sqrt(rx * rx + ry * ry);
	double ax = hx_[i], ay = hy_[i];
	if (dr > 0.001) {
		ax = rx / dr;
		ay = ry / dr;
	}
	double mx = ax, my = ay, spd = 0.0;
	if (dr <= FF_NEAR_M && sight(x, y, tgx, tgy)) {
		spd = dr > 7.0 ? 3.4 : 0.0;
	} else if (!cop_search(i, x, y, mx, my, spd)) {
		double gx = heat_x_ - x, gy = heat_y_ - y;
		double dg = std::sqrt(gx * gx + gy * gy);
		if (dg > 0.001) {
			mx = gx / dg;
			my = gy / dg;
		}
		flow_dir(x, y, mx, my);
		spd = 3.4;
	}
	t2_[i] -= dt;
	t1_[i] -= dt;
	if (dr < 20.0 && t2_[i] <= 0.0 && sight(x, y, tgx, tgy)) {
		double s = (rnd() - 0.5) * 0.16;
		double fx = ax - ay * s, fy = ay + ax * s;
		double l = std::sqrt(fx * fx + fy * fy);
		fire(x + fx / l * 0.8, y + fy / l * 0.8, fx / l * 38.0, fy / l * 38.0, 1.5);
		t2_[i] = 0.8 + rnd() * 1.6;
		t1_[i] = 0.25;
	}
	person_move(i, x, y, mx, my, spd, dt);
}

// Within PT_ARRIVE_M of the last-seen point: amble on a heading that turns every
// POL_SEARCH_TURN_S (from the sim clock and the slot, no rnd()). False when farther.
bool CityCore::cop_search(int i, double x, double y, double &dx, double &dy, double &spd) const {
	double gx = x - heat_x_, gy = y - heat_y_;
	if (gx * gx + gy * gy > pol_[PT_ARRIVE_M] * pol_[PT_ARRIVE_M]) return false;
	int k = ((int)std::floor(time_ / POL_SEARCH_TURN_S) * 5 + i) & 15;
	dx = dir16x_[k];
	dy = dir16y_[k];
	spd = POL_SEARCH_V;
	return true;
}

// A free cop: the pedestrians' sidewalk walk at PT_WALK_V; a diagonal heading snaps to its main
// axis first, and off the sidewalk he keeps crossing until he is back on one.
void CityCore::cop_walk(int i, double dt) {
	double x = px_[i], y = py_[i], dx = hx_[i], dy = hy_[i], spd = 0.0;
	t2_[i] -= dt;
	t1_[i] -= dt;
	if (dx != 0.0 && dy != 0.0) {
		if (std::fabs(dx) >= std::fabs(dy)) {
			dx = dx >= 0.0 ? 1.0 : -1.0;
			dy = 0.0;
		} else {
			dy = dy >= 0.0 ? 1.0 : -1.0;
			dx = 0.0;
		}
	}
	if (cell_at(x, y) != C_WALK) flags_[i] = flags_[i] | F_CROSSING;
	ped_walk(i, x, y, dx, dy, spd);
	if (spd > 0.0) spd = pol_[PT_WALK_V];
	person_move(i, x, y, dx, dy, spd, dt);
}

// Heat 2: a dispatched car brakes to a stop within PT_CAR_STOP_M of the last-seen point; a parked
// one stays stopped.
double CityCore::car_police_speed(const Car &c, double vdes) const {
	int i = c.i;
	if ((flags_[i] & F_PARKED) != 0) return 0.0;
	if ((flags_[i] & F_ENGAGED) == 0) return vdes;
	double ax = c.x - heat_x_, ay = c.y - heat_y_, r = pol_[PT_CAR_STOP_M];
	return ax * ax + ay * ay <= r * r ? 0.0 : vdes;
}

// Stopped there (under 0.5 m/s), or stuck en route longer than PT_BAIL_S (it follows traffic
// under heat): the car parks and its crew gets out 2 m to the side facing the
// point (the flow field does not see cars: a crew on the far side pressed into its own car),
// 1.4 m apart along it, facing out.
void CityCore::car_unload(const Car &c) {
	int i = c.i;
	if ((flags_[i] & F_ENGAGED) == 0 || c.vv >= 0.5) return;
	double ax = c.x - heat_x_, ay = c.y - heat_y_, r = pol_[PT_CAR_STOP_M];
	if (ax * ax + ay * ay > r * r && stuck_[i] <= pol_[PT_BAIL_S]) return;  // or bail out, stuck
	flags_[i] = (uint8_t)((flags_[i] & ~F_ENGAGED) | F_PARKED);
	int n = (int)pol_[PT_CREW];
	double sx = -c.hhy, sy = c.hhx;
	if (sx * (heat_x_ - c.x) + sy * (heat_y_ - c.y) < 0.0) {
		sx = -sx;
		sy = -sy;
	}
	for (int k = 0; k < n; k++) {
		double along = (double)k * 1.4 - 0.7 * (double)(n - 1);
		double spec[SP_LEN] = {(double)K_COP, c.x + sx * 2.0 + c.hhx * along,
			c.y + sy * 2.0 + c.hhy * along, sx, sy, (double)ART_COP,
			(double)(F_PROMOTED | F_ENGAGED | F_CREW), 3.4, 0.0, 0.0};
		spawn(spec);
	}
}

}  // namespace gtai::sim
