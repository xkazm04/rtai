// People: pedestrians (walk, flee, riot, dead) and cops on foot.
#include "city_core.h"
#include "sim_math.h"

namespace gtai::sim {

void CityCore::ped(int i, double dt) {
	double x = px_[i], y = py_[i];
	int m = mode_[i];
	if (m == M_DEAD) {
		double vv = maxf(0.0, v_[i] - 8.0 * dt);
		v_[i] = vv;
		px_[i] = x + hx_[i] * vv * dt;
		py_[i] = y + hy_[i] * vv * dt;
		return;
	}
	if (m == M_DOWN) {
		down(i, dt);
		return;
	}
	double dx = hx_[i], dy = hy_[i], spd = 0.0;
	if (m == M_FLEE) {
		ped_flee(i, dt, x, y, dx, dy);
		spd = 4.5;
	} else if (m == M_RIOT) {
		ped_riot(i, dt, x, y, dx, dy);
		spd = 2.6;
	} else {
		ped_walk(i, x, y, dx, dy, spd);
	}
	x += dx * spd * dt;
	y += dy * spd * dt;
	if (tier_[i] == 0) {
		cx_ = x;
		cy_ = y;
		crowd(i);
		body_push(i);
		solid(0.3);
		x = cx_;
		y = cy_;
	}
	px_[i] = x;
	py_[i] = y;
	if (mode_[i] == M_DOWN) return;  // tackled this step (body_push)
	hx_[i] = dx;
	hy_[i] = dy;
	v_[i] = spd;
	phase_[i] += spd * dt;
}

void CityCore::ped_flee(int i, double dt, double x, double y, double &dx, double &dy) {
	t1_[i] -= dt;
	double ax = x - sx_[i], ay = y - sy_[i];
	double l = std::sqrt(ax * ax + ay * ay);
	if (l > 0.001) {
		dx = ax / l;
		dy = ay / l;
	}
	if (cell_at(x + dx, y + dy) >= 4 || cell_at(x + dx, y + dy) == 0) {
		double nx = -dy, ny = dx;
		dx = nx;
		dy = ny;
	}
	if (t1_[i] > 0.0) return;
	if (flags_[i] & F_RIOTER) {
		mode_[i] = M_RIOT;
		return;
	}
	mode_[i] = M_WALK;
	if (std::fabs(dx) >= std::fabs(dy)) {
		dx = dx >= 0.0 ? 1.0 : -1.0;
		dy = 0.0;
	} else {
		dy = dy >= 0.0 ? 1.0 : -1.0;
		dx = 0.0;
	}
}

void CityCore::ped_riot(int i, double dt, double x, double y, double &dx, double &dy) {
	t1_[i] -= dt;
	if (t1_[i] <= 0.0) {
		int k = (int)(rnd() * 16.0);
		dx = dir16x_[k];
		dy = dir16y_[k];
		t1_[i] = 1.0 + rnd() * 2.0;
	}
	double ax = sx_[i] - x, ay = sy_[i] - y;
	double d2 = ax * ax + ay * ay;
	if (d2 > riot_r_ * riot_r_) {
		double l = std::sqrt(d2);
		dx = ax / l;
		dy = ay / l;
	}
}

// Sidewalk following: keep going on walk cells, sometimes cross a road, else turn.
void CityCore::ped_walk(int i, double x, double y, double &dx, double &dy, double &spd) {
	spd = vmax_[i];
	int c = cell_at(x + dx, y + dy);
	if (c == C_WALK) {
		flags_[i] = flags_[i] & ~F_CROSSING;
		return;
	}
	if ((c == C_LANE || c == C_PARK) && ((flags_[i] & F_CROSSING) != 0 || rnd() < 0.04)) {
		flags_[i] = flags_[i] | F_CROSSING;
		return;
	}
	flags_[i] = flags_[i] & ~F_CROSSING;
	double rx = -dy, ry = dx, lx = dy, lyy = -dx;
	double ax = rx, ay = ry, bx = lx, by = lyy;
	if (rnd() >= 0.5) {
		ax = lx;
		ay = lyy;
		bx = rx;
		by = ry;
	}
	if (cell_at(x + ax, y + ay) == C_WALK) {
		dx = ax;
		dy = ay;
	} else if (cell_at(x + bx, y + by) == C_WALK) {
		dx = bx;
		dy = by;
	} else if (cell_at(x - dx, y - dy) == C_WALK) {
		dx = -dx;
		dy = -dy;
	} else {
		spd = 0.0;
	}
}

void CityCore::cop(int i, double dt, double tgx, double tgy) {
	double x = px_[i], y = py_[i];
	if (mode_[i] == M_DEAD) return;
	if (mode_[i] == M_DOWN) {
		down(i, dt);
		return;
	}
	double ax = tgx - x, ay = tgy - y;
	double d = std::sqrt(ax * ax + ay * ay);
	double dx = hx_[i], dy = hy_[i];
	if (d > 0.001) {
		dx = ax / d;
		dy = ay / d;
	}
	// move along the flow field (WLD-09); aim and shoot straight at the target
	double mx = dx, my = dy;
	if (d > FF_NEAR_M) flow_dir(x, y, mx, my);
	double spd = d > 7.0 ? 3.4 : 0.0;
	t2_[i] -= dt;
	t1_[i] -= dt;
	if (d < 20.0 && t2_[i] <= 0.0) {
		double s = (rnd() - 0.5) * 0.16;
		double fx = dx - dy * s, fy = dy + dx * s;
		double l = std::sqrt(fx * fx + fy * fy);
		fire(x + fx / l * 0.8, y + fy / l * 0.8, fx / l * 38.0, fy / l * 38.0, 1.5);
		t2_[i] = 0.8 + rnd() * 1.6;
		t1_[i] = 0.25;
	}
	x += mx * spd * dt;
	y += my * spd * dt;
	if (tier_[i] == 0) {
		cx_ = x;
		cy_ = y;
		crowd(i);
		body_push(i);
		solid(0.3);
		x = cx_;
		y = cy_;
	}
	px_[i] = x;
	py_[i] = y;
	if (mode_[i] == M_DOWN) return;  // tackled this step (body_push)
	hx_[i] = mx;
	hy_[i] = my;
	v_[i] = spd;
	phase_[i] += spd * dt;
}

}  // namespace gtai::sim
