// Thin godot-cpp binding (NAT-03): CitySim converts packed arrays to pointers for the plain
// C++ core and uploads the render buffers through RenderingServer. No sim logic lives here.
// API: coarse step() + write_render() per frame; spawn/kill/stamp are rare calls (NAT-02).
#pragma once

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/array.hpp>
#include <godot_cpp/variant/packed_byte_array.hpp>
#include <godot_cpp/variant/packed_float32_array.hpp>
#include <godot_cpp/variant/packed_float64_array.hpp>
#include <godot_cpp/variant/packed_int32_array.hpp>
#include <godot_cpp/variant/rid.hpp>

#include <memory>

#include "city_core.h"

namespace godot {

class CitySim : public RefCounted {
	GDCLASS(CitySim, RefCounted)

public:
	CitySim();

	void init(int64_t seed);
	void set_radii(double ra, double rb, double riot);
	void stamp_chunk(int cx, int cy, const PackedByteArray &tiles, const PackedByteArray &cells);
	void clear_chunk(int cx, int cy);
	int cell_at(double x, double y) const;
	int tile_at(double x, double y) const;
	int spawn(const PackedFloat64Array &spec);
	void set_riot_centre(int i, double x, double y);
	void kill(int i);
	void strike(int i, double vx, double vy, bool lethal);
	void set_car_state(int i, int state);
	void set_obstacles(const PackedFloat64Array &xy);
	void fire(double x, double y, double vx, double vy, double ttl);
	void step(double dt, double camx, double camy, double tgx, double tgy);
	PackedInt32Array get_counters() const;
	PackedFloat64Array snapshot() const;
	void set_render(const Array &mms, const PackedInt32Array &clips);
	void write_render(double vx0, double vy0, double vx1, double vy1);
	PackedInt32Array get_render_counts() const;
	void set_rig_slots(const PackedInt32Array &slots);
	void set_person_px(double px);
	PackedByteArray get_variants() const;
	PackedInt32Array flow_stats() const;
	int flow_dist(double x, double y) const;

protected:
	static void _bind_methods();

private:
	std::unique_ptr<gtai::sim::CityCore> core_;
	RID rmm_[gtai::sim::RL_COUNT];
	PackedFloat32Array rbuf_[gtai::sim::RL_COUNT];
	int32_t rcount_[gtai::sim::RL_COUNT] = {};
	bool render_ready_ = false;

	static bool chunk_ok(int cx, int cy);
	static bool slot_ok(int i);
};

}  // namespace godot
