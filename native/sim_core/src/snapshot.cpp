// The parity digest (NAT-06): every float of every live slot in slot order, then projectiles.
#include "city_core.h"

#include <cmath>

namespace gtai::sim {

std::vector<double> CityCore::snapshot() const {
	std::vector<double> out;
	for (int i = 0; i < CAP; i++) {
		if (alive_[i] == 0) continue;
		const double a[SNAP_STRIDE] = {(double)i, (double)kind_[i], (double)mode_[i],
			(double)tier_[i], px_[i], py_[i], hx_[i], hy_[i], v_[i], phase_[i], t1_[i], t2_[i],
			(double)dir_[i], (double)ndir_[i]};
		out.insert(out.end(), a, a + SNAP_STRIDE);
	}
	for (int k = 0; k < PCAP; k++) {
		if (qalive_[k] == 0) continue;
		out.push_back((double)(SNAP_PROJ_BASE + k));
		out.push_back(qx_[k]);
		out.push_back(qy_[k]);
	}
	return out;
}

void scan_dead_flips(const double *snap, int64_t n, const uint8_t *dead, int64_t dead_n,
		std::vector<int32_t> &out) {
	out.clear();
	out.push_back(0);
	int64_t r = 0;
	while (r + SNAP_STRIDE <= n && snap[r] < SNAP_PROJ_BASE) {
		const int64_t i = (int64_t)snap[r];
		const int kind = (int)snap[r + 1];
		if (i >= 0 && i < dead_n && (kind == K_PED || kind == K_COP) &&
				(((int)snap[r + 2] == M_DEAD) != (dead[i] != 0))) {
			out.push_back((int32_t)r);
		}
		r += SNAP_STRIDE;
	}
	out[0] = (int32_t)r;
}

void scan_crowd_in_rect(const double *snap, int64_t n, float px, float x0, float y0, float x1,
		float y1, std::vector<int32_t> &out) {
	out.clear();
	for (int64_t r = 0; r + SNAP_STRIDE <= n && snap[r] < SNAP_PROJ_BASE; r += SNAP_STRIDE) {
		const int kind = (int)snap[r + 1];
		if (kind != K_PED && kind != K_COP) continue;
		const float x = (float)snap[r + 4] * px;
		const float y = (float)snap[r + 5] * px;
		if (x >= x0 && y >= y0 && x < x1 && y < y1) out.push_back((int32_t)r);
	}
}

namespace {
// The script's enums, by value: BodyPlan.Kind, RigFeed.Flag, RigFeed.LOOK_AUTO.
constexpr uint8_t BODY_COP = 1, BODY_PED = 2;
constexpr uint8_t FLAG_DEAD = 1, FLAG_AIMING = 2, FLAG_GUN_OUT = 4, FLAG_FLEE = 8, FLAG_DOWN = 16;
constexpr uint8_t LOOK_AUTO = 255;

uint8_t mode_flag(int mode) {
	if (mode == M_DEAD) return FLAG_DEAD;
	if (mode == M_DOWN) return FLAG_DOWN;
	return (mode == M_FLEE || mode == M_RIOT) ? FLAG_FLEE : 0;
}
}  // namespace

void fill_feed_rows(const double *snap, int64_t n, const uint8_t *variants, int64_t variants_n,
		const FeedRowsArgs &a, std::vector<FeedRow> &out) {
	out.clear();
	for (int64_t r = 0; r + SNAP_STRIDE <= n && snap[r] < SNAP_PROJ_BASE; r += SNAP_STRIDE) {
		const int kind = (int)snap[r + 1];
		if (kind != K_PED && kind != K_COP) continue;
		const float x = (float)snap[r + 4], y = (float)snap[r + 5];
		const float dx = x - a.focus_x, dy = y - a.focus_y;
		if ((double)(dx * dx + dy * dy) > a.r2) continue;
		const int slot = (int)snap[r];
		const int mode = (int)snap[r + 2];
		const bool cop = kind == K_COP;
		const float hx = (float)snap[r + 6], hy = (float)snap[r + 7], v = (float)snap[r + 8];
		FeedRow f;
		f.id = slot;
		f.kind = cop ? BODY_COP : BODY_PED;
		f.look = slot < variants_n ? variants[slot] : LOOK_AUTO;
		f.x = x * a.px, f.y = y * a.px;
		f.vx = hx * v * a.px, f.vy = hy * v * a.px;
		f.face = std::atan2(hy, hx);
		f.aim_x = f.x, f.aim_y = f.y;
		f.flags = mode_flag(mode);
		if (cop && mode != M_DEAD && mode != M_DOWN) {
			f.flags |= FLAG_GUN_OUT;
			f.aim_x = a.aim_x, f.aim_y = a.aim_y;
			if (snap[r + 10] > 0.0) f.flags |= FLAG_AIMING;
		}
		out.push_back(f);
	}
}

}  // namespace gtai::sim
