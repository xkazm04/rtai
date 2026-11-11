// Cars, part 1: the per-step driver and lane routing (junction choice, turns, U-turns at dead
// ends, junction reservation). Part 2 (steering, speed) is car_drive.cpp; contact car_hit.cpp.
#include "city_core.h"
#include "sim_math.h"

namespace gtai::sim {

void CityCore::car(int i, double dt, double tgx, double tgy) {
	Car c{i, px_[i], py_[i], dir_[i], 0.0, 0.0, kind_[i] == K_PCAR, false, 0.0, 0.0, 0.0, 0.0,
			is_bike(i)};
	c.ddx = DX[c.d];
	c.ddy = DY[c.d];
	if (ndir_[i] < 0) car_plan(c, tgx, tgy);
	if (ndir_[i] >= 0) car_follow(c);
	car_reserve(c);
	car_pass(c);
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

// The road tile a car heading d drives on: east-west for 0 and 2, north-south for 1 and 3.
static int road_of(int d) { return (d == 0 || d == 2) ? T_ROAD_H : T_ROAD_V; }

// True when a car U-turns before tile kind t: its bit is set in CAR_DEAD_END_TILES (a junction
// never is). Default 1: the city edge or an unloaded tile only (t-4); Call c-2.
static bool dead_end(int t) { return t != T_INTER && ((CAR_DEAD_END_TILES >> t) & 1) != 0; }

// No next direction yet: pick one at the junction CAR_PLAN_AHEAD m ahead, or U-turn before a
// dead-end tile (dead_end above).
void CityCore::car_plan(Car &c, double tgx, double tgy) {
	int i = c.i;
	double ax = c.x + c.ddx * CAR_PLAN_AHEAD, ay = c.y + c.ddy * CAR_PLAN_AHEAD;
	int tc = tile_at(ax, ay);
	if (tc == T_INTER) {
		double icx = std::floor(ax / 8.0) * 8.0 + 4.0;
		double icy = std::floor(ay / 8.0) * 8.0 + 4.0;
		int pick = car_pick(c, icx, icy, tgx, tgy);
		ndir_[i] = pick;
		jx_[i] = icx;
		jy_[i] = icy;
		nlane_[i] = ((pick == 0 || pick == 2) ? icy : icx) + LANE_OFF[pick];
	} else if (dead_end(tc)) {
		double centre = lane_[i] - LANE_OFF[c.d];
		c.d = (c.d + 2) % 4;
		dir_[i] = c.d;
		lane_[i] = centre + LANE_OFF[c.d];
		c.ddx = DX[c.d];
		c.ddy = DY[c.d];
	}
}

// Right, straight or left by weight (police cars: the exit nearest the target); else back. An
// exit is open only onto a road of its own orientation (t-4).
int CityCore::car_pick(const Car &c, double icx, double icy, double tgx, double tgy) {
	int d = c.d;
	int cand[3] = {(d + 1) % 4, d, (d + 3) % 4};
	const double wts[3] = {0.25, 0.5, 0.25};
	bool ok[3] = {false, false, false};
	double sumw = 0.0;
	for (int k = 0; k < 3; k++) {
		int t = tile_at(icx + DX[cand[k]] * CAR_EXIT_PROBE, icy + DY[cand[k]] * CAR_EXIT_PROBE);
		if (t == road_of(cand[k])) {
			ok[k] = true;
			sumw += wts[k];
		}
	}
	int pick = -1;
	if (c.is_p) {
		pick = car_pursuit_pick(cand, ok, icx, icy, tgx, tgy);
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

// Police: the open exit with the shortest flow-field distance at its far end; exits the field
// does not cover rank after every covered one, by straight-line distance; ties keep the first.
int CityCore::car_pursuit_pick(const int *cand, const bool *ok, double icx, double icy, double tgx,
		double tgy) const {
	int pick = -1, best_rank = 2, best_f = 0;
	double best_e2 = 0.0;
	for (int k = 0; k < 3; k++) {
		if (!ok[k]) continue;
		double ex = icx + DX[cand[k]] * CAR_EXIT_PROBE, ey = icy + DY[cand[k]] * CAR_EXIT_PROBE;
		int f = flow_dist(ex, ey);
		double e2 = (ex - tgx) * (ex - tgx) + (ey - tgy) * (ey - tgy);
		int rank = f >= 0 ? 0 : 1;
		bool better = pick < 0 || rank < best_rank ||
				(rank == best_rank && (rank == 0 ? f < best_f : e2 < best_e2));
		if (better) {
			pick = cand[k];
			best_rank = rank;
			best_f = f;
			best_e2 = e2;
		}
	}
	return pick;
}

// Turn onto the next lane once past the turn line; release the junction CAR_JUNCTION_CLEAR m
// after it.
void CityCore::car_follow(Car &c) {
	int i = c.i;
	double along = c.x * c.ddx + c.y * c.ddy;
	int nd = ndir_[i];
	if (nd != c.d) {
		double cross = 0.0;
		if (nd == (c.d + 2) % 4) cross = jx_[i] * c.ddx + jy_[i] * c.ddy;
		else if (c.d == 0 || c.d == 2) cross = nlane_[i] * c.ddx - CAR_TURN_LEAD;
		else cross = nlane_[i] * c.ddy - CAR_TURN_LEAD;
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
	if (past > CAR_JUNCTION_CLEAR) {
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
