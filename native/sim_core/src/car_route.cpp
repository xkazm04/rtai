// Cars, part 1: the per-step driver and lane routing (junction choice, turns, U-turns at dead
// ends, junction reservation). Part 2 (steering, speed) is car_drive.cpp; contact car_hit.cpp.
#include "city_core.h"
#include "sim_math.h"

namespace gtai::sim {

void CityCore::car(int i, double dt, double tgx, double tgy) {
	Car c{i, px_[i], py_[i], dir_[i], 0.0, 0.0, kind_[i] == K_PCAR, false, 0.0, 0.0, 0.0};
	c.ddx = DX[c.d];
	c.ddy = DY[c.d];
	if (ndir_[i] < 0) car_plan(c, tgx, tgy);
	if (ndir_[i] >= 0) car_follow(c);
	car_reserve(c);
	car_steer(c, dt);
	c.vv = v_[i];
	double vdes = car_desired_speed(c);
	if (c.vv < vdes) c.vv = minf(vdes, c.vv + 6.0 * dt);
	else c.vv = maxf(vdes, c.vv - 14.0 * dt);
	c.x += c.hhx * c.vv * dt;
	c.y += c.hhy * c.vv * dt;
	if (tier_[i] == 0) {
		car_contacts(c);
		car_hull(c);
	}
	if (c.vv < 0.3 && !c.waiting) stuck_[i] += dt;
	else stuck_[i] = 0.0;
	px_[i] = c.x;
	py_[i] = c.y;
	hx_[i] = c.hhx;
	hy_[i] = c.hhy;
	v_[i] = c.vv;
	phase_[i] += c.vv * dt;
	if ((stuck_[i] > 8.0 && tier_[i] == 1) || stuck_[i] > 20.0) {
		if ((flags_[i] & F_PROMOTED) == 0) kill(i);
	}
}

// No next direction yet: pick one at the junction 18 m ahead, or U-turn at a dead end.
void CityCore::car_plan(Car &c, double tgx, double tgy) {
	int i = c.i;
	int tc = tile_at(c.x + c.ddx * 18.0, c.y + c.ddy * 18.0);
	if (tc == T_INTER) {
		double icx = std::floor((c.x + c.ddx * 18.0) / 8.0) * 8.0 + 4.0;
		double icy = std::floor((c.y + c.ddy * 18.0) / 8.0) * 8.0 + 4.0;
		int pick = car_pick(c, icx, icy, tgx, tgy);
		ndir_[i] = pick;
		jx_[i] = icx;
		jy_[i] = icy;
		nlane_[i] = ((pick == 0 || pick == 2) ? icy : icx) + LANE_OFF[pick];
	} else if (tc != T_ROAD_H && tc != T_ROAD_V) {
		double centre = lane_[i] - LANE_OFF[c.d];
		c.d = (c.d + 2) % 4;
		dir_[i] = c.d;
		lane_[i] = centre + LANE_OFF[c.d];
		c.ddx = DX[c.d];
		c.ddy = DY[c.d];
	}
}

// Right, straight or left by weight (police cars: the exit nearest the target); else back.
int CityCore::car_pick(const Car &c, double icx, double icy, double tgx, double tgy) {
	int d = c.d;
	int cand[3] = {(d + 1) % 4, d, (d + 3) % 4};
	const double wts[3] = {0.25, 0.5, 0.25};
	bool ok[3] = {false, false, false};
	double sumw = 0.0;
	for (int k = 0; k < 3; k++) {
		int t = tile_at(icx + DX[cand[k]] * 16.0, icy + DY[cand[k]] * 16.0);
		if (t == T_ROAD_H || t == T_ROAD_V) {
			ok[k] = true;
			sumw += wts[k];
		}
	}
	int pick = -1;
	if (c.is_p) {
		double best = 1e30;
		for (int k = 0; k < 3; k++) {
			if (!ok[k]) continue;
			double ex = icx + DX[cand[k]] * 16.0 - tgx;
			double ey = icy + DY[cand[k]] * 16.0 - tgy;
			double e2 = ex * ex + ey * ey;
			if (e2 < best) {
				best = e2;
				pick = cand[k];
			}
		}
	} else if (sumw > 0.0) {
		double r = rnd() * sumw;
		for (int k = 0; k < 3; k++) {
			if (!ok[k]) continue;
			pick = cand[k];
			r -= wts[k];
			if (r < 0.0) break;
		}
	}
	return pick < 0 ? (d + 2) % 4 : pick;
}

// Turn onto the next lane once past the turn line; release the junction 13 m after it.
void CityCore::car_follow(Car &c) {
	int i = c.i;
	double along = c.x * c.ddx + c.y * c.ddy;
	int nd = ndir_[i];
	if (nd != c.d) {
		double cross = 0.0;
		if (nd == (c.d + 2) % 4) cross = jx_[i] * c.ddx + jy_[i] * c.ddy;
		else if (c.d == 0 || c.d == 2) cross = nlane_[i] * c.ddx - 2.5;
		else cross = nlane_[i] * c.ddy - 2.5;
		if (along >= cross) {
			c.d = nd;
			dir_[i] = c.d;
			lane_[i] = nlane_[i];
			c.ddx = DX[c.d];
			c.ddy = DY[c.d];
		}
		return;
	}
	double past = along - (jx_[i] * c.ddx + jy_[i] * c.ddy);
	if (past > 13.0) {
		int r = res_[i];
		if (r >= 0 && owner_[r] == i + 1) owner_[r] = 0;
		res_[i] = -1;
		ndir_[i] = -1;
	}
}

// Tier-A cars reserve the junction tile; a held reservation makes this car wait.
void CityCore::car_reserve(Car &c) {
	int i = c.i;
	if (ndir_[i] < 0 || tier_[i] != 0 || res_[i] >= 0) return;
	int jt = floori(jy_[i] / 8.0) * TW + floori(jx_[i] / 8.0);
	int o = owner_[jt];
	if (o == 0 || o == i + 1 || alive_[o - 1] == 0 || res_[o - 1] != jt) {
		owner_[jt] = i + 1;
		res_[i] = jt;
	} else {
		c.waiting = true;
	}
}

}  // namespace gtai::sim
