// The bubble sim core (NAT-01, NAT-03): plain C++17, no godot types, so it builds and tests
// standalone. The GDScript reference (project/features/city/sim/) is the same algorithm,
// operation for operation: doubles, + - * / sqrt floor fabs only, one 32-bit LCG (NAT-07), so
// the parity gate compares exact state. Struct-of-arrays slots; member functions are split over
// the TUs named beside each group.
#pragma once

#include <cstdint>
#include <vector>

#include "sim_constants.h"

namespace gtai::sim {

class CityCore {
public:
	CityCore();

	// world.cpp
	void init(int64_t seed);
	void set_radii(double ra, double rb, double riot);
	void stamp_chunk(int cx, int cy, const uint8_t *tile_codes, const uint8_t *cell_codes);
	void clear_chunk(int cx, int cy);
	int cell_at(double x, double y) const;
	int tile_at(double x, double y) const;

	// spawn.cpp. spec: SP_LEN doubles laid out by SP_KIND..SP_DIR.
	int spawn(const double *spec);
	void set_riot_centre(int i, double x, double y);
	void kill(int i);
	void fire(double x, double y, double vx, double vy, double ttl);

	// step.cpp
	void step(double dt, double camx, double camy, double tgx, double tgy);

	// render.cpp. clips: CLIP_VARIANTS * CLIPS * 3 ints [start count fps]. bufs: RL_COUNT
	// buffers sized CAP (PCAP for bullets) * RL_STRIDE floats; counts receives the instances.
	void set_clips(const int32_t *clip_table, int n);
	// Render only (never sim state): actors drawn by a full cutout rig skip their atlas body;
	// the person quad's world-px size matches the baked crowd atlas cell.
	void set_rig_slots(const int32_t *slots, int n);
	void set_person_px(float px) { person_px_ = px; }
	uint8_t variant_of(int i) const { return (i >= 0 && i < CAP) ? variant_[i] : 0; }
	void fill_render(double vx0, double vy0, double vx1, double vy1, float *const *bufs,
			int32_t *counts) const;

	// snapshot.cpp
	std::vector<double> snapshot() const;

	// flow.cpp: the police flow field (WLD-09). Distance in cells to the target, or -1.
	int flow_dist(double x, double y) const;
	bool flow_dir(double x, double y, double &dx, double &dy) const;
	const int32_t *flow_stats() const { return ff_stats_; }
	const int32_t *counters() const { return counters_; }

private:
	double ra_ = 80.0, rb_ = 160.0, riot_r_ = 14.0, time_ = 0.0;
	uint32_t rs_ = 1;
	double dir16x_[16] = {}, dir16y_[16] = {};

	uint8_t alive_[CAP], kind_[CAP], tier_[CAP], mode_[CAP], variant_[CAP], flags_[CAP];
	double px_[CAP], py_[CAP], hx_[CAP], hy_[CAP], v_[CAP], vmax_[CAP], phase_[CAP];
	double t1_[CAP], t2_[CAP], sx_[CAP], sy_[CAP], lane_[CAP], nlane_[CAP];
	double jx_[CAP], jy_[CAP], stuck_[CAP];
	int32_t dir_[CAP], ndir_[CAP], res_[CAP];
	uint8_t qalive_[PCAP];
	double qx_[PCAP], qy_[PCAP], qvx_[PCAP], qvy_[PCAP], qt_[PCAP];

	std::vector<uint8_t> tiles_, cells_;
	std::vector<int32_t> owner_;
	int32_t hcount_[HW * HW + 1], hstart_[HW * HW + 1], hitems_[CAP];
	int hgx_ = 0, hgy_ = 0;
	int32_t counters_[CN_COUNT] = {};
	std::vector<int32_t> clips_;
	uint8_t rigged_[CAP] = {};
	float person_px_ = 122.88f;

	// flow field (flow.cpp); map_version_ bumps on every stamp / clear (world.cpp)
	std::vector<uint16_t> ff_dist_;
	std::vector<int32_t> ff_queue_;
	int ff_ox_ = 0, ff_oy_ = 0, ff_tx_ = 0, ff_ty_ = 0;
	bool ff_valid_ = false;
	uint32_t map_version_ = 0, ff_map_version_ = 0;
	int64_t ff_ticks_ = 0;
	int32_t ff_stats_[FS_LEN] = {};

	double cx_ = 0.0, cy_ = 0.0;  // contact scratch position (crowd / solid)
	int qbuf_[CAP];

	// Car state carried between the car_* phases of one step (car_route.cpp, car_drive.cpp).
	struct Car {
		int i;
		double x, y;
		int d;
		double ddx, ddy;
		bool is_p, waiting;
		double hhx, hhy, vv;
	};

	double rnd();                                     // world.cpp
	void tier_pass_one(int i, double camx, double camy);  // step.cpp
	void count();                                     // step.cpp
	void build_hash(double camx, double camy);        // hash.cpp
	int query(double x, double y, int r, int *out) const;  // hash.cpp
	void ped(int i, double dt);                       // people.cpp
	void ped_walk(int i, double x, double y, double &dx, double &dy, double &spd);
	void ped_flee(int i, double dt, double x, double y, double &dx, double &dy);
	void ped_riot(int i, double dt, double x, double y, double &dx, double &dy);
	void cop(int i, double dt, double tgx, double tgy);
	void crowd(int i);                                // contact.cpp
	void solid(double r);                             // contact.cpp
	void car(int i, double dt, double tgx, double tgy);  // car_route.cpp
	void car_plan(Car &c, double tgx, double tgy);    // car_route.cpp
	int car_pick(const Car &c, double icx, double icy, double tgx, double tgy);
	int car_pursuit_pick(const int *cand, const bool *ok, double icx, double icy, double tgx,
			double tgy) const;
	void car_follow(Car &c);                          // car_route.cpp
	void car_reserve(Car &c);                         // car_route.cpp
	void car_steer(Car &c, double dt);                // car_drive.cpp
	double car_desired_speed(const Car &c);           // car_drive.cpp
	void car_contacts(Car &c);                        // car_hit.cpp
	void car_hull(Car &c);                            // car_hit.cpp
	void projectiles(double dt);                      // projectiles.cpp
	bool projectile_sub(int k, double &x, double &y, double h);
	void scare(double x, double y);                   // projectiles.cpp
	int frame_of(int i, int &cell) const;             // render.cpp
	bool police_alive() const;                        // flow.cpp
	int map_cell(int gx, int gy) const;               // flow.cpp
	void flow_update(double tgx, double tgy);         // flow.cpp
	void flow_build(int tx, int ty);                  // flow.cpp
	int local_dist(int lx, int ly) const;             // flow.cpp
};

}  // namespace gtai::sim
