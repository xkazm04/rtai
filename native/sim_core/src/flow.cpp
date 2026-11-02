// Police flow field (WLD-09): one integer BFS toward the pursuit target over the 1 m cell map,
// in an FF_W x FF_W window centred on the target cell, shared by every cop and police car.
// Integers only (exact in both runtimes); fixed neighbour order E S W N for the BFS and
// E S W N SE SW NW NE for the descent, first strict minimum wins. Recomputed at most every
// FF_EVERY ticks, only when the target cell or the map changed and police are alive.
#include <chrono>
#include <cmath>

#include "city_core.h"

namespace gtai::sim {

namespace {
constexpr int NX[8] = {1, 0, -1, 0, 1, -1, -1, 1};
constexpr int NY[8] = {0, 1, 0, -1, 1, 1, -1, -1};

inline bool walkable(int c) { return c >= C_LANE && c <= C_WALK; }
}  // namespace

bool CityCore::police_alive() const {
	for (int i = 0; i < CAP; i++) {
		if (alive_[i] != 0 && (kind_[i] == K_COP || kind_[i] == K_PCAR)) return true;
	}
	return false;
}

int CityCore::map_cell(int gx, int gy) const {
	if (gx < 0 || gy < 0 || gx >= W || gy >= W) return C_VOID;
	return cells_[(size_t)gy * W + gx];
}

void CityCore::flow_update(double tgx, double tgy) {
	int tx = (int)std::floor(tgx), ty = (int)std::floor(tgy);
	bool due = (ff_ticks_ % FF_EVERY) == 0;
	ff_ticks_ += 1;
	if (!due || !police_alive()) return;
	if (ff_valid_ && tx == ff_tx_ && ty == ff_ty_ && map_version_ == ff_map_version_) return;
	auto t0 = std::chrono::steady_clock::now();
	flow_build(tx, ty);
	auto us = std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::steady_clock::now() - t0);
	ff_stats_[FS_COMPUTES] += 1;
	ff_stats_[FS_LAST_US] = (int32_t)us.count();
	if (ff_stats_[FS_LAST_US] > ff_stats_[FS_MAX_US]) ff_stats_[FS_MAX_US] = ff_stats_[FS_LAST_US];
}

void CityCore::flow_build(int tx, int ty) {
	ff_tx_ = tx;
	ff_ty_ = ty;
	ff_ox_ = tx - FF_W / 2;
	ff_oy_ = ty - FF_W / 2;
	ff_map_version_ = map_version_;
	ff_valid_ = true;
	for (int k = 0; k < FF_W * FF_W; k++) ff_dist_[k] = (uint16_t)FF_UNREACHED;
	int head = 0, tail = 0;
	if (walkable(map_cell(tx, ty))) {
		ff_dist_[(FF_W / 2) * FF_W + FF_W / 2] = 0;
		ff_queue_[tail++] = (FF_W / 2) * FF_W + FF_W / 2;
	}
	while (head < tail) {
		int c = ff_queue_[head++];
		int lx = c % FF_W, ly = c / FF_W;
		int nd = ff_dist_[c] + 1;
		for (int n = 0; n < 4; n++) {
			int ax = lx + NX[n], ay = ly + NY[n];
			if (ax < 0 || ay < 0 || ax >= FF_W || ay >= FF_W) continue;
			int a = ay * FF_W + ax;
			if (ff_dist_[a] != FF_UNREACHED || !walkable(map_cell(ff_ox_ + ax, ff_oy_ + ay))) continue;
			ff_dist_[a] = (uint16_t)nd;
			ff_queue_[tail++] = a;
		}
	}
	ff_stats_[FS_REACHED] = tail;
}

// Distance in cells from world point (x, y) to the target, or -1 (outside, unreached, stale).
int CityCore::flow_dist(double x, double y) const {
	if (!ff_valid_) return -1;
	int lx = (int)std::floor(x) - ff_ox_, ly = (int)std::floor(y) - ff_oy_;
	if (lx < 0 || ly < 0 || lx >= FF_W || ly >= FF_W) return -1;
	int d = ff_dist_[ly * FF_W + lx];
	return d == FF_UNREACHED ? -1 : d;
}

// The unit step toward the target from (x, y): the neighbour with the smallest distance
// (diagonals only when both sides are open). False when there is no downhill step.
bool CityCore::flow_dir(double x, double y, double &dx, double &dy) const {
	int here = flow_dist(x, y);
	if (here <= 0) return false;
	int lx = (int)std::floor(x) - ff_ox_, ly = (int)std::floor(y) - ff_oy_;
	int best = here, pick = -1;
	for (int n = 0; n < 8; n++) {
		int d = local_dist(lx + NX[n], ly + NY[n]);
		if (d < 0) continue;
		if (n >= 4 && (local_dist(lx + NX[n], ly) < 0 || local_dist(lx, ly + NY[n]) < 0)) continue;
		if (d < best) {
			best = d;
			pick = n;
		}
	}
	if (pick < 0) return false;
	double ix = (double)NX[pick], iy = (double)NY[pick];
	double l = std::sqrt(ix * ix + iy * iy);
	dx = ix / l;
	dy = iy / l;
	return true;
}

int CityCore::local_dist(int lx, int ly) const {
	if (lx < 0 || ly < 0 || lx >= FF_W || ly >= FF_W) return -1;
	int d = ff_dist_[ly * FF_W + lx];
	return d == FF_UNREACHED ? -1 : d;
}

}  // namespace gtai::sim
