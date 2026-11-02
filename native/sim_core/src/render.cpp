// The render-buffer writer (NAT-01): fills the RL_COUNT MultiMesh 2D buffers (RL_STRIDE floats
// per instance: 2x4 transform rows, colour, custom) for actors inside the view rect (metres).
// Not part of the sim state, so float32 here is fine; the binding uploads the buffers.
#include <algorithm>

#include "city_core.h"

namespace gtai::sim {

namespace {
// 2D transform rows (a, b, 0, ox / c, d, 0, oy), then colour and custom.x.
void put(float *o, const float *xf, const float *rgba, float custom) {
	for (int k = 0; k < 8; k++) o[k] = xf[k];
	for (int k = 0; k < 4; k++) o[8 + k] = rgba[k];
	o[12] = custom;
	o[13] = o[14] = o[15] = 0.0f;
}
const float WHITE[4] = {1.0f, 1.0f, 1.0f, 1.0f};
const float INK_PED[4] = {0.09f, 0.075f, 0.106f, 0.3f};
const float INK_CAR[4] = {0.09f, 0.075f, 0.106f, 0.45f};
const float BULLET[4] = {1.0f, 0.85f, 0.4f, 1.0f};
}  // namespace

void CityCore::set_clips(const int32_t *clip_table, int n) { clips_.assign(clip_table, clip_table + n); }

// Clip (idle walk flee hit death shoot) and atlas cell for a person.
int CityCore::frame_of(int i, int &cell) const {
	int k = kind_[i], m = mode_[i], cl = 1, f = 0;
	if (m == M_DEAD) cl = 4;
	else if (k == K_COP && t1_[i] > 0.0) cl = 5;
	else if (v_[i] < 0.2) cl = 0;
	else if (m == M_FLEE || m == M_RIOT || k == K_COP || v_[i] > 3.0) cl = 2;
	const int32_t *cp = clips_.data();
	int b = (variant_[i] * CLIPS + cl) * 3;
	int cnt = cp[b + 1];
	if (cl == 4) f = std::min((int)(t2_[i] * cp[b + 2]), cnt - 1);
	else if (cl == 5) f = std::min((int)((0.25 - t1_[i]) * 24.0), cnt - 1);
	else if (cl == 0) f = (int)((time_ + i * 0.37) * cp[b + 2]) % cnt;
	else if (cl == 2) f = (int)(phase_[i] / 2.585 * cnt) % cnt;
	else f = (int)(phase_[i] / 1.869 * cnt) % cnt;
	cell = cp[b] + f;
	return cl;
}

void CityCore::fill_render(double vx0, double vy0, double vx1, double vy1, float *const *bufs,
		int32_t *counts) const {
	const float PXM = (float)PX_PER_M, S = 122.88f, SH = 25.6f, CL = 204.8f, CW = 102.4f;
	int np = 0, nc = 0, nb = 0;
	bool people = clips_.size() >= (size_t)(CLIP_VARIANTS * CLIPS * 3);
	for (int i = 0; i < CAP; i++) {
		if (alive_[i] == 0) continue;
		double x = px_[i], y = py_[i];
		if (x < vx0 || x > vx1 || y < vy0 || y > vy1) continue;
		float dx = (float)hx_[i], dy = (float)hy_[i];
		float X = (float)x * PXM, Y = (float)y * PXM;
		int k = kind_[i];
		if (k == K_PED || k == K_COP) {
			if (!people) continue;
			int cell = 0;
			frame_of(i, cell);
			const float sh[8] = {SH, 0.0f, 0.0f, X + 2.0f, 0.0f, SH, 0.0f, Y + 3.0f};
			put(bufs[RL_PED_SHADOWS] + np * RL_STRIDE, sh, INK_PED, 0.0f);
			const float body[8] = {dx * S, -dy * S, 0.0f, X, dy * S, dx * S, 0.0f, Y};
			put(bufs[RL_PEDS] + np * RL_STRIDE, body, WHITE, (float)cell);
			np++;
		} else {
			const float body[8] = {dx * CL, -dy * CW, 0.0f, X, dy * CL, dx * CW, 0.0f, Y};
			put(bufs[RL_CARS] + nc * RL_STRIDE, body, WHITE, (float)variant_[i]);
			const float sh[8] = {dx * CL, -dy * CW, 0.0f, X + 5.12f, dy * CL, dx * CW, 0.0f, Y + 5.12f};
			put(bufs[RL_CAR_SHADOWS] + nc * RL_STRIDE, sh, INK_CAR, (float)variant_[i]);
			nc++;
		}
	}
	for (int k = 0; k < PCAP; k++) {
		if (qalive_[k] == 0) continue;
		double x = qx_[k], y = qy_[k];
		if (x < vx0 || x > vx1 || y < vy0 || y > vy1) continue;
		const float xf[8] = {9.6f, 0.0f, 0.0f, (float)x * PXM, 0.0f, 9.6f, 0.0f, (float)y * PXM};
		put(bufs[RL_BULLETS] + nb * RL_STRIDE, xf, BULLET, 0.0f);
		nb++;
	}
	const int32_t ns[RL_COUNT] = {np, np, nc, nc, nb};
	for (int k = 0; k < RL_COUNT; k++) counts[k] = ns[k];
}

}  // namespace gtai::sim
