// The player body (features/bodies, gtai.bodies/1): one circle the caller places before each
// step. People overlapping it take BD_SHARE of the overlap (the mass ratio) and, above the
// tackle speed, are knocked down; after the people step the body is pushed out of whatever still
// overlaps it, so it never ends a tick inside a person. Mirrors features/city/sim/sim_body.gd.
#include "city_core.h"
#include "sim_math.h"

namespace gtai::sim {

void CityCore::set_body(const double *spec) {
	for (int k = 0; k < BD_LEN; k++) body_[k] = spec[k];
	bx_ = body_[BD_X];
	by_ = body_[BD_Y];
}

// Person i at the scratch position (cx_, cy_), moving at (pvx, pvy) m/s, against the body.
void CityCore::body_push(int i, double pvx, double pvy) {
	if (body_[BD_ON] == 0.0) return;
	double rs = body_[BD_R] + body_[BD_RP];
	double ddx = cx_ - bx_, ddy = cy_ - by_;
	double d2 = ddx * ddx + ddy * ddy;
	if (d2 >= rs * rs) return;
	double nx = 1.0, ny = 0.0, d = 0.0;
	if (d2 > 1e-12) {
		d = std::sqrt(d2);
		nx = ddx / d;
		ny = ddy / d;
	}
	bool tackle = mode_[i] != M_DOWN && body_[BD_VX] * nx + body_[BD_VY] * ny > body_[BD_TACKLE];
	if (tackle) {
		mode_[i] = M_DOWN;
		hx_[i] = nx;
		hy_[i] = ny;
		v_[i] = body_[BD_KNOCK];
		t1_[i] = body_[BD_DOWN];
		sx_[i] = bx_;
		sy_[i] = by_;
		knocks_.push_back((double)i);
		knocks_.push_back(cx_);
		knocks_.push_back(cy_);
	}
	double sh = body_[BD_SHARE];
	// a person running into the body is blocked (human -> rivet_base run): it takes it all
	if (!tackle && body_[BD_RUN_IN] != 0.0 && -(pvx * nx + pvy * ny) > body_[BD_RUN_IN]) sh = 1.0;
	double pen = (rs - d) * sh;
	cx_ += nx * pen;
	cy_ += ny * pen;
	double vx = body_[BD_VX], vy = body_[BD_VY];
	double vv2 = vx * vx + vy * vy;
	if (tackle || vv2 <= 1e-6) return;
	// A shove also steps the person aside (to the side they stand on; dead ahead: by slot), so a
	// crowd parts instead of being bulldozed along in a train.
	double vl = std::sqrt(vv2);
	double ux = vx / vl, uy = vy / vl;
	double cr = ux * ny - uy * nx;
	double sd = cr > 0.0 ? 1.0 : (cr < 0.0 ? -1.0 : ((i & 1) != 0 ? 1.0 : -1.0));
	cx_ += -uy * sd * pen * 0.5;
	cy_ += ux * sd * pen * 0.5;
}

// A knocked-down person: slides along the knock, lies for t1, then gets up (a ped flees from
// where it was hit, a cop resumes).
void CityCore::down(int i, double dt) {
	double vv = maxf(0.0, v_[i] - 8.0 * dt);
	v_[i] = vv;
	double x = px_[i] + hx_[i] * vv * dt, y = py_[i] + hy_[i] * vv * dt;
	if (tier_[i] == 0) {
		cx_ = x;
		cy_ = y;
		body_push(i, 0.0, 0.0);
		solid(0.3);
		x = cx_;
		y = cy_;
	}
	px_[i] = x;
	py_[i] = y;
	t1_[i] -= dt;
	if (t1_[i] > 0.0) return;
	if (kind_[i] == K_COP) {
		mode_[i] = M_WALK;
		t1_[i] = 0.0;
		return;
	}
	mode_[i] = M_FLEE;
	t1_[i] = body_[BD_FLEE];
}

// The body out of every live tier-A person it still overlaps (twice), then out of solid cells.
void CityCore::body_resolve() {
	if (body_[BD_ON] == 0.0) return;
	double rs = body_[BD_R] + body_[BD_RP];
	for (int it = 0; it < 2; it++) {
		int n = query(bx_, by_, 1, qbuf_);
		for (int q = 0; q < n; q++) {
			int j = qbuf_[q];
			int kj = kind_[j];
			if (alive_[j] == 0 || (kj != K_PED && kj != K_COP) || mode_[j] == M_DEAD) continue;
			double ddx = bx_ - px_[j], ddy = by_ - py_[j];
			double d2 = ddx * ddx + ddy * ddy;
			if (d2 >= rs * rs || d2 <= 1e-12) continue;
			double d = std::sqrt(d2);
			bx_ += ddx / d * (rs - d);
			by_ += ddy / d * (rs - d);
		}
	}
	cx_ = bx_;
	cy_ = by_;
	solid(body_[BD_R]);
	bx_ = cx_;
	by_ = cy_;
}

std::vector<double> CityCore::body_result() const {
	std::vector<double> out;
	out.push_back(bx_);
	out.push_back(by_);
	out.push_back((double)(knocks_.size() / BR_STRIDE));
	out.insert(out.end(), knocks_.begin(), knocks_.end());
	return out;
}

}  // namespace gtai::sim
