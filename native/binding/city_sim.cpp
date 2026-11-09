// CitySim binding: argument checks, packed-array conversion, RenderingServer upload.
#include "city_sim.h"

#include <godot_cpp/classes/rendering_server.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

#include <cstring>
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

// New pos, vel and life columns (copies: a packed argument is the script's own buffer) and the events.
Array CitySim::step_blood_drops(const PackedVector2Array &pos, const PackedVector2Array &vel,
		const PackedInt32Array &life, double drag, double land, double px) const {
	PackedVector2Array p2 = pos, v2 = vel;
	PackedInt32Array l2 = life;
	thread_local std::vector<int32_t> events;
	core_->step_blood_drops(reinterpret_cast<float *>(p2.ptrw()), reinterpret_cast<float *>(v2.ptrw()),
			l2.ptrw(), l2.size(), (float)drag, land, px, events);
	PackedInt32Array ev;
	ev.resize((int64_t)events.size());
	if (!events.empty()) memcpy(ev.ptrw(), events.data(), events.size() * sizeof(int32_t));
	Array out;
	out.resize(4);
	out[0] = p2, out[1] = v2, out[2] = l2, out[3] = ev;
	return out;
}

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

void CitySim::strike(int i, double vx, double vy, bool lethal) {
	if (slot_ok(i)) core_->strike(i, vx, vy, lethal);
}

void CitySim::scare(double x, double y) { core_->scare(x, y); }

void CitySim::set_car_state(int i, int state) { core_->set_car_state(i, state); }

void CitySim::set_obstacles(const PackedFloat64Array &xy) {
	core_->set_obstacles(xy.ptr(), (int)(xy.size() / 2));
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

PackedInt32Array CitySim::scan_dead_flips(const PackedFloat64Array &snap, const PackedByteArray &dead) {
	thread_local std::vector<int32_t> hits;
	sim::scan_dead_flips(snap.ptr(), snap.size(), dead.ptr(), dead.size(), hits);
	PackedInt32Array out;
	out.resize((int64_t)hits.size());
	memcpy(out.ptrw(), hits.data(), hits.size() * sizeof(int32_t));
	return out;
}

PackedInt32Array CitySim::scan_crowd_in_rect(const PackedFloat64Array &snap, const Rect2 &rect, double px) {
	thread_local std::vector<int32_t> hits;
	const Vector2 end = rect.position + rect.size;
	sim::scan_crowd_in_rect(snap.ptr(), snap.size(), (float)px, rect.position.x, rect.position.y, end.x, end.y, hits);
	PackedInt32Array out;
	out.resize((int64_t)hits.size());
	if (!hits.empty()) memcpy(out.ptrw(), hits.data(), hits.size() * sizeof(int32_t));
	return out;
}

// RigFeed's columns in adopt_rows' order, then the row count; one zero row follows the people, so
// Rivet's row is written without growing ten arrays.
Array CitySim::fill_feed_rows(const PackedFloat64Array &snap, const PackedByteArray &variants,
		const Vector2 &focus, double r2, const Vector2 &aim, double px) {
	thread_local std::vector<sim::FeedRow> rows;
	const sim::FeedRowsArgs args{focus.x, focus.y, r2, aim.x, aim.y, (float)px};
	sim::fill_feed_rows(snap.ptr(), snap.size(), variants.ptr(), variants.size(), args, rows);
	const int64_t n = (int64_t)rows.size();
	PackedInt32Array ids;
	PackedByteArray kinds, looks, flags, clip;
	PackedVector2Array pos, vel, aims;
	PackedFloat32Array face, clip_arg;
	ids.resize(n + 1), kinds.resize(n + 1), looks.resize(n + 1), flags.resize(n + 1);
	clip.resize(n + 1), pos.resize(n + 1), vel.resize(n + 1), aims.resize(n + 1);
	face.resize(n + 1), clip_arg.resize(n + 1);
	int32_t *w_ids = ids.ptrw();
	uint8_t *w_kinds = kinds.ptrw(), *w_looks = looks.ptrw(), *w_flags = flags.ptrw();
	Vector2 *w_pos = pos.ptrw(), *w_vel = vel.ptrw(), *w_aim = aims.ptrw();
	float *w_face = face.ptrw();
	for (int64_t i = 0; i < n; i++) {
		const sim::FeedRow &f = rows[(size_t)i];
		w_ids[i] = f.id, w_kinds[i] = f.kind, w_looks[i] = f.look, w_flags[i] = f.flags;
		w_pos[i] = Vector2(f.x, f.y), w_vel[i] = Vector2(f.vx, f.vy);
		w_aim[i] = Vector2(f.aim_x, f.aim_y), w_face[i] = f.face;
	}
	w_ids[n] = 0, w_kinds[n] = 0, w_looks[n] = 0, w_flags[n] = 0, w_face[n] = 0.0f;
	w_pos[n] = Vector2(), w_vel[n] = Vector2(), w_aim[n] = Vector2();
	memset(clip.ptrw(), 0, (size_t)n + 1);  // RigClips.Clip.NONE
	memset(clip_arg.ptrw(), 0, ((size_t)n + 1) * sizeof(float));
	Array out;
	out.resize(11);
	out[0] = ids, out[1] = kinds, out[2] = looks, out[3] = pos, out[4] = vel, out[5] = face;
	out[6] = aims, out[7] = flags, out[8] = clip, out[9] = clip_arg, out[10] = n;
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
	ClassDB::bind_method(D_METHOD("step_blood_drops", "pos", "vel", "life", "drag", "land", "px"), &CitySim::step_blood_drops);
	ClassDB::bind_method(D_METHOD("tile_at", "x", "y"), &CitySim::tile_at);
	ClassDB::bind_method(D_METHOD("spawn", "spec"), &CitySim::spawn);
	ClassDB::bind_method(D_METHOD("set_riot_centre", "i", "x", "y"), &CitySim::set_riot_centre);
	ClassDB::bind_method(D_METHOD("kill", "i"), &CitySim::kill);
	ClassDB::bind_method(D_METHOD("strike", "i", "vx", "vy", "lethal"), &CitySim::strike);
	ClassDB::bind_method(D_METHOD("scare", "x", "y"), &CitySim::scare);
	ClassDB::bind_method(D_METHOD("set_car_state", "i", "state"), &CitySim::set_car_state);
	ClassDB::bind_method(D_METHOD("set_obstacles", "xy"), &CitySim::set_obstacles);
	ClassDB::bind_method(D_METHOD("fire", "x", "y", "vx", "vy", "ttl"), &CitySim::fire);
	ClassDB::bind_method(D_METHOD("step", "dt", "camx", "camy", "tgx", "tgy"), &CitySim::step);
	ClassDB::bind_method(D_METHOD("get_counters"), &CitySim::get_counters);
	ClassDB::bind_method(D_METHOD("snapshot"), &CitySim::snapshot);
	ClassDB::bind_static_method("CitySim", D_METHOD("scan_dead_flips", "snap", "dead"), &CitySim::scan_dead_flips);
	ClassDB::bind_static_method("CitySim", D_METHOD("scan_crowd_in_rect", "snap", "rect", "px"), &CitySim::scan_crowd_in_rect);
	ClassDB::bind_static_method("CitySim", D_METHOD("fill_feed_rows", "snap", "variants", "focus", "r2", "aim", "px"), &CitySim::fill_feed_rows);
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
