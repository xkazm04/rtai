// World maps, init and the LCG (NAT-07: the same 32-bit LCG in both runtimes).
#include <cstring>

#include "city_core.h"
#include "sim_math.h"

namespace gtai::sim {

CityCore::CityCore() { init(1); }

void CityCore::init(int64_t seed) {
	rs_ = (uint32_t)(seed & 0xFFFFFFFF);
	for (int k = 0; k < 16; k++) {
		double ix = (double)DIR16I[k * 2], iy = (double)DIR16I[k * 2 + 1];
		double l = std::sqrt(ix * ix + iy * iy);
		dir16x_[k] = ix / l;
		dir16y_[k] = iy / l;
	}
	time_ = 0.0;
	std::memset(alive_, 0, sizeof(alive_));
	std::memset(kind_, 0, sizeof(kind_));
	std::memset(tier_, 0, sizeof(tier_));
	std::memset(mode_, 0, sizeof(mode_));
	std::memset(variant_, 0, sizeof(variant_));
	std::memset(flags_, 0, sizeof(flags_));
	for (int i = 0; i < CAP; i++) {
		px_[i] = py_[i] = hx_[i] = hy_[i] = v_[i] = vmax_[i] = phase_[i] = 0.0;
		t1_[i] = t2_[i] = sx_[i] = sy_[i] = lane_[i] = nlane_[i] = 0.0;
		jx_[i] = jy_[i] = stuck_[i] = 0.0;
		dir_[i] = ndir_[i] = res_[i] = -1;
	}
	std::memset(qalive_, 0, sizeof(qalive_));
	for (int k = 0; k < PCAP; k++) qx_[k] = qy_[k] = qvx_[k] = qvy_[k] = qt_[k] = 0.0;
	tiles_.assign((size_t)TW * TW, 0);
	cells_.assign((size_t)W * W, 0);
	owner_.assign((size_t)TW * TW, 0);
	std::memset(counters_, 0, sizeof(counters_));
}

void CityCore::set_radii(double ra, double rb, double riot) {
	ra_ = ra;
	rb_ = rb;
	riot_r_ = riot;
}

double CityCore::rnd() {
	rs_ = rs_ * (uint32_t)LCG_MUL + (uint32_t)LCG_ADD;
	return (double)(rs_ >> 8) / 16777216.0;
}

void CityCore::stamp_chunk(int cx, int cy, const uint8_t *tile_codes, const uint8_t *cell_codes) {
	for (int ly = 0; ly < CHUNK_TILES; ly++) {
		size_t row = (size_t)(cy * CHUNK_TILES + ly) * TW + (size_t)cx * CHUNK_TILES;
		std::memcpy(&tiles_[row], tile_codes + ly * CHUNK_TILES, CHUNK_TILES);
	}
	size_t base = (size_t)cy * CHUNK_CELLS * W + (size_t)cx * CHUNK_CELLS;
	for (int ly = 0; ly < CHUNK_CELLS; ly++)
		std::memcpy(&cells_[base + (size_t)ly * W], cell_codes + ly * CHUNK_CELLS, CHUNK_CELLS);
}

void CityCore::clear_chunk(int cx, int cy) {
	for (int ly = 0; ly < CHUNK_TILES; ly++) {
		size_t row = (size_t)(cy * CHUNK_TILES + ly) * TW + (size_t)cx * CHUNK_TILES;
		std::memset(&tiles_[row], 0, CHUNK_TILES);
	}
	size_t base = (size_t)cy * CHUNK_CELLS * W + (size_t)cx * CHUNK_CELLS;
	for (int ly = 0; ly < CHUNK_CELLS; ly++)
		std::memset(&cells_[base + (size_t)ly * W], 0, CHUNK_CELLS);
}

int CityCore::cell_at(double x, double y) const {
	int ix = floori(x), iy = floori(y);
	if (ix < 0 || iy < 0 || ix >= W || iy >= W) return 0;
	return cells_[(size_t)iy * W + ix];
}

int CityCore::tile_at(double x, double y) const {
	int ix = floori(x / 8.0), iy = floori(y / 8.0);
	if (ix < 0 || iy < 0 || ix >= TW || iy >= TW) return 0;
	return tiles_[(size_t)iy * TW + ix];
}

}  // namespace gtai::sim
