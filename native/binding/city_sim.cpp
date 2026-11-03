// CitySim binding: argument checks, packed-array conversion, RenderingServer upload.
#include "city_sim.h"

#include <godot_cpp/classes/rendering_server.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

#include <vector>

using namespace godot;
namespace sim = gtai::sim;

CitySim::CitySim() : core_(std::make_unique<sim::CityCore>()) {}

bool CitySim::chunk_ok(int cx, int cy) {
	return cx >= 0 && cy >= 0 && cx < sim::CITY_CHUNKS && cy < sim::CITY_CHUNKS;
}

bool CitySim::slot_ok(int i) { return i >= 0 && i < sim::CAP; }

void CitySim::init(int64_t seed) { core_->init(seed); }

void CitySim::set_radii(double ra, double rb, double riot) { core_->set_radii(ra, rb, riot); }

void CitySim::stamp_chunk(int cx, int cy, const PackedByteArray &tiles, const PackedByteArray &cells) {
	const int nt = sim::CHUNK_TILES * sim::CHUNK_TILES, nc = sim::CHUNK_CELLS * sim::CHUNK_CELLS;
	if (!chunk_ok(cx, cy) || tiles.size() != nt || cells.size() != nc) {
		UtilityFunctions::push_error("CitySim.stamp_chunk: bad chunk ", cx, ",", cy, " or sizes");
		return;
	}
	core_->stamp_chunk(cx, cy, tiles.ptr(), cells.ptr());
}

void CitySim::clear_chunk(int cx, int cy) {
	if (chunk_ok(cx, cy)) core_->clear_chunk(cx, cy);
}

int CitySim::cell_at(double x, double y) const { return core_->cell_at(x, y); }

int CitySim::tile_at(double x, double y) const { return core_->tile_at(x, y); }

int CitySim::spawn(const PackedFloat64Array &spec) {
	if (spec.size() != sim::SP_LEN) {
		UtilityFunctions::push_error("CitySim.spawn: the spec needs ", sim::SP_LEN, " floats");
		return -1;
	}
	return core_->spawn(spec.ptr());
}

void CitySim::set_riot_centre(int i, double x, double y) {
	if (slot_ok(i)) core_->set_riot_centre(i, x, y);
}

void CitySim::kill(int i) {
	if (slot_ok(i)) core_->kill(i);
}

void CitySim::fire(double x, double y, double vx, double vy, double ttl) {
	core_->fire(x, y, vx, vy, ttl);
}

void CitySim::step(double dt, double camx, double camy, double tgx, double tgy) {
	core_->step(dt, camx, camy, tgx, tgy);
}

PackedInt32Array CitySim::get_counters() const {
	PackedInt32Array out;
	out.resize(sim::CN_COUNT);
	const int32_t *c = core_->counters();
	for (int k = 0; k < sim::CN_COUNT; k++) out.set(k, c[k]);
	return out;
}

void CitySim::set_body(const PackedFloat64Array &spec) {
	if (spec.size() != gtai::sim::BD_LEN) return;
	core_->set_body(spec.ptr());
}

PackedFloat64Array CitySim::body_result() const {
	std::vector<double> r = core_->body_result();
	PackedFloat64Array out;
	out.resize((int64_t)r.size());
	for (size_t k = 0; k < r.size(); k++) out.set((int64_t)k, r[k]);
	return out;
}

PackedFloat64Array CitySim::snapshot() const {
	std::vector<double> s = core_->snapshot();
	PackedFloat64Array out;
	out.resize((int64_t)s.size());
	double *w = out.ptrw();
	for (size_t k = 0; k < s.size(); k++) w[k] = s[k];
	return out;
}

void CitySim::set_render(const Array &mms, const PackedInt32Array &clips) {
	if (mms.size() != sim::RL_COUNT || clips.size() < sim::CLIP_VARIANTS * sim::CLIPS * 3) {
		UtilityFunctions::push_error("CitySim.set_render: needs 5 MultiMesh RIDs and the clip table");
		return;
	}
	core_->set_clips(clips.ptr(), (int)clips.size());
	for (int k = 0; k < sim::RL_COUNT; k++) {
		rmm_[k] = mms[k];
		int cap = k == sim::RL_BULLETS ? sim::PCAP : sim::CAP;
		rbuf_[k].resize(cap * sim::RL_STRIDE);
		rbuf_[k].fill(0.0f);
	}
	render_ready_ = true;
}

void CitySim::write_render(double vx0, double vy0, double vx1, double vy1) {
	if (!render_ready_) return;
	float *bufs[sim::RL_COUNT];
	for (int k = 0; k < sim::RL_COUNT; k++) bufs[k] = rbuf_[k].ptrw();
	core_->fill_render(vx0, vy0, vx1, vy1, bufs, rcount_);
	RenderingServer *rs = RenderingServer::get_singleton();
	for (int k = 0; k < sim::RL_COUNT; k++) {
		rs->multimesh_set_buffer(rmm_[k], rbuf_[k]);
		rs->multimesh_set_visible_instances(rmm_[k], rcount_[k]);
	}
}

PackedInt32Array CitySim::get_render_counts() const {
	PackedInt32Array out;
	for (int k = 0; k < sim::RL_COUNT; k++) out.push_back(rcount_[k]);
	return out;
}

// Render only: rigged actors skip their atlas body; the person quad size; art variants per slot.
void CitySim::set_rig_slots(const PackedInt32Array &slots) { core_->set_rig_slots(slots.ptr(), (int)slots.size()); }

void CitySim::set_person_px(double px) { core_->set_person_px((float)px); }

PackedByteArray CitySim::get_variants() const {
	PackedByteArray out;
	out.resize(sim::CAP);
	for (int i = 0; i < sim::CAP; i++) out.set(i, core_->variant_of(i));
	return out;
}

PackedInt32Array CitySim::flow_stats() const {
	PackedInt32Array out;
	out.resize(sim::FS_LEN);
	for (int k = 0; k < sim::FS_LEN; k++) out.set(k, core_->flow_stats()[k]);
	return out;
}

int CitySim::flow_dist(double x, double y) const { return core_->flow_dist(x, y); }

void CitySim::_bind_methods() {
	ClassDB::bind_method(D_METHOD("init", "seed"), &CitySim::init);
	ClassDB::bind_method(D_METHOD("set_radii", "ra", "rb", "riot"), &CitySim::set_radii);
	ClassDB::bind_method(D_METHOD("stamp_chunk", "cx", "cy", "tiles", "cells"), &CitySim::stamp_chunk);
	ClassDB::bind_method(D_METHOD("clear_chunk", "cx", "cy"), &CitySim::clear_chunk);
	ClassDB::bind_method(D_METHOD("cell_at", "x", "y"), &CitySim::cell_at);
	ClassDB::bind_method(D_METHOD("tile_at", "x", "y"), &CitySim::tile_at);
	ClassDB::bind_method(D_METHOD("spawn", "spec"), &CitySim::spawn);
	ClassDB::bind_method(D_METHOD("set_riot_centre", "i", "x", "y"), &CitySim::set_riot_centre);
	ClassDB::bind_method(D_METHOD("kill", "i"), &CitySim::kill);
	ClassDB::bind_method(D_METHOD("fire", "x", "y", "vx", "vy", "ttl"), &CitySim::fire);
	ClassDB::bind_method(D_METHOD("step", "dt", "camx", "camy", "tgx", "tgy"), &CitySim::step);
	ClassDB::bind_method(D_METHOD("get_counters"), &CitySim::get_counters);
	ClassDB::bind_method(D_METHOD("snapshot"), &CitySim::snapshot);
	ClassDB::bind_method(D_METHOD("set_body", "spec"), &CitySim::set_body);
	ClassDB::bind_method(D_METHOD("body_result"), &CitySim::body_result);
	ClassDB::bind_method(D_METHOD("set_render", "mms", "clips"), &CitySim::set_render);
	ClassDB::bind_method(D_METHOD("write_render", "vx0", "vy0", "vx1", "vy1"), &CitySim::write_render);
	ClassDB::bind_method(D_METHOD("get_render_counts"), &CitySim::get_render_counts);
	ClassDB::bind_method(D_METHOD("flow_stats"), &CitySim::flow_stats);
	ClassDB::bind_method(D_METHOD("set_rig_slots", "slots"), &CitySim::set_rig_slots);
	ClassDB::bind_method(D_METHOD("set_person_px", "px"), &CitySim::set_person_px);
	ClassDB::bind_method(D_METHOD("get_variants"), &CitySim::get_variants);
	ClassDB::bind_method(D_METHOD("flow_dist", "x", "y"), &CitySim::flow_dist);
}
