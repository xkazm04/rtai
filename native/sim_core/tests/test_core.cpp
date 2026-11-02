// Standalone core test (NAT-03, no godot): a synthetic chunk with a plaza and one road, a few
// pedestrians, a cop and a car. Same seed twice must give identical snapshots; a different
// seed must not; a few behaviour checks. Exit code = number of failed checks.
#include <cmath>
#include <cstdio>
#include <memory>
#include <vector>

#include "city_core.h"

using namespace gtai::sim;

namespace {

int failures = 0;

void check(bool ok, const char *what) {
	std::printf("%s %s\n", ok ? "ok  " : "FAIL", what);
	if (!ok) failures++;
}

// Chunk (2, 2): plaza everywhere, one east-west road in tile row 8 (cells 64..71).
void stamp_test_chunk(CityCore &s) {
	std::vector<uint8_t> tiles(CHUNK_TILES * CHUNK_TILES, T_PLAZA);
	std::vector<uint8_t> cells(CHUNK_CELLS * CHUNK_CELLS, C_WALK);
	for (int lx = 0; lx < CHUNK_TILES; lx++) tiles[8 * CHUNK_TILES + lx] = T_ROAD_H;
	for (int ly = 64; ly < 72; ly++)
		for (int lx = 0; lx < CHUNK_CELLS; lx++) cells[ly * CHUNK_CELLS + lx] = C_LANE;
	s.stamp_chunk(2, 2, tiles.data(), cells.data());
}

int spawn(CityCore &s, int kind, double x, double y, double vmax, int dir, double lane) {
	double spec[SP_LEN] = {};
	spec[SP_KIND] = kind;
	spec[SP_X] = x;
	spec[SP_Y] = y;
	spec[SP_DX] = dir < 0 ? 0.0 : 1.0;
	spec[SP_DY] = dir < 0 ? 1.0 : 0.0;
	spec[SP_VMAX] = vmax;
	spec[SP_LANE] = lane;
	spec[SP_DIR] = dir < 0 ? 0 : dir;
	return s.spawn(spec);
}

struct Run {
	std::vector<double> snap;
	int32_t counters[CN_COUNT];
	double car_x0, car_x1;
};

Run run(int64_t seed, int steps) {
	auto s = std::make_unique<CityCore>();
	s->init(seed);
	stamp_test_chunk(*s);
	for (int k = 0; k < 10; k++) spawn(*s, K_PED, 290.5 + k * 3.0, 290.5, 1.4, -1, 0.0);
	spawn(*s, K_COP, 300.0, 300.0, 3.4, -1, 0.0);
	int car = spawn(*s, K_CAR, 300.0, 326.0, 11.0, 0, 326.0);
	Run r{};
	r.car_x0 = 300.0;
	for (int t = 0; t < steps; t++) s->step(1.0 / 60.0, 320.0, 320.0, 330.0, 300.0);
	r.snap = s->snapshot();
	for (int k = 0; k < CN_COUNT; k++) r.counters[k] = s->counters()[k];
	r.car_x1 = -1.0;
	for (size_t k = 0; k + SNAP_STRIDE <= r.snap.size(); k += SNAP_STRIDE) {
		if (r.snap[k] == (double)car && r.snap[k + 1] == (double)K_CAR) r.car_x1 = r.snap[k + 4];
	}
	return r;
}

// Chunk (2, 2) all sidewalk with a solid wall at x 300..302 over the whole chunk except the
// 8 m gap at y 320..327. A cop west of the wall must route through the gap to a target east of
// it (WLD-09 flow field); straight-line steering would pin it against the wall.
struct Chase {
	int detour, computes;
	double final_dist;
};

Chase chase() {
	auto s = std::make_unique<CityCore>();
	s->init(7);
	std::vector<uint8_t> tiles(CHUNK_TILES * CHUNK_TILES, T_PLAZA);
	std::vector<uint8_t> cells(CHUNK_CELLS * CHUNK_CELLS, C_WALK);
	for (int ly = 0; ly < CHUNK_CELLS; ly++) {
		if (ly >= 64 && ly < 72) continue;
		for (int lx = 44; lx < 47; lx++) cells[ly * CHUNK_CELLS + lx] = C_BUILD;
	}
	s->stamp_chunk(2, 2, tiles.data(), cells.data());
	int cop = spawn(*s, K_COP, 290.5, 290.5, 3.4, -1, 0.0);
	s->step(1.0 / 60.0, 305.0, 300.0, 315.5, 290.5);
	Chase r{s->flow_dist(290.5, 290.5), 0, 1e9};
	for (int t = 0; t < 3000; t++) s->step(1.0 / 60.0, 305.0, 300.0, 315.5, 290.5);
	std::vector<double> snap = s->snapshot();
	for (size_t k = 0; k + SNAP_STRIDE <= snap.size(); k += SNAP_STRIDE) {
		if (snap[k] != (double)cop) continue;
		double dx = snap[k + 4] - 315.5, dy = snap[k + 5] - 290.5;
		r.final_dist = std::sqrt(dx * dx + dy * dy);
	}
	r.computes = s->flow_stats()[FS_COMPUTES];
	return r;
}

}  // namespace

int main() {
	Run a = run(4242, 600);
	Run b = run(4242, 600);
	Run c = run(4243, 600);
	check(!a.snap.empty(), "snapshot has live actors");
	check(a.snap == b.snap, "same seed, same steps: identical snapshot");
	check(a.snap != c.snap, "different seed: different snapshot");
	check(a.car_x1 >= 0.0 && std::fabs(a.car_x1 - a.car_x0) > 5.0, "the car drove along its lane");
	check(a.counters[CN_PEDS] + a.counters[CN_COPS] >= 1, "people are counted");
	check(a.counters[CN_TIER_A] + a.counters[CN_TIER_B] > 0, "every live actor has a tier");
	Chase f = chase();
	check(f.detour > 40, "flow field: the route around the wall is longer than the straight line");
	check(f.final_dist < 9.0, "flow field: the cop reached the target through the gap");
	check(f.computes >= 1, "flow field: computed at least once");
	std::printf("flow: detour %d cells, final distance %.2f m, %d fields\n", f.detour, f.final_dist,
			f.computes);
	std::printf("sim_core tests: %d failed\n", failures);
	return failures;
}
