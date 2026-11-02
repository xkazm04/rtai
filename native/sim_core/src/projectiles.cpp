// Projectiles: two half-steps each, stopped by solid or unloaded cells, killing the first live
// pedestrian within 0.45 m and scaring everyone within 9 m.
#include "city_core.h"
#include "sim_math.h"

namespace gtai::sim {

void CityCore::projectiles(double dt) {
	double h = dt * 0.5;
	for (int k = 0; k < PCAP; k++) {
		if (qalive_[k] == 0) continue;
		qt_[k] -= dt;
		if (qt_[k] <= 0.0) {
			qalive_[k] = 0;
			continue;
		}
		double x = qx_[k], y = qy_[k];
		for (int sub = 0; sub < 2; sub++) {
			if (!projectile_sub(k, x, y, h)) break;
		}
		qx_[k] = x;
		qy_[k] = y;
	}
}

// One half-step; false when the projectile ended (wall or hit).
bool CityCore::projectile_sub(int k, double &x, double &y, double h) {
	x += qvx_[k] * h;
	y += qvy_[k] * h;
	int c = cell_at(x, y);
	if (c == 0 || c >= 4) {
		qalive_[k] = 0;
		return false;
	}
	int hit = -1;
	int n = query(x, y, 1, qbuf_);
	for (int q = 0; q < n; q++) {
		int j = qbuf_[q];
		if (kind_[j] != K_PED || mode_[j] == M_DEAD) continue;
		double rx = px_[j] - x, ry = py_[j] - y;
		if (rx * rx + ry * ry < 0.2025) {
			hit = j;
			break;
		}
	}
	if (hit < 0) return true;
	double l = std::sqrt(qvx_[k] * qvx_[k] + qvy_[k] * qvy_[k]);
	mode_[hit] = M_DEAD;
	t2_[hit] = 0.0;
	v_[hit] = 3.0;
	hx_[hit] = qvx_[k] / l;
	hy_[hit] = qvy_[k] / l;
	counters_[CN_KILLED] += 1;
	scare(x, y);
	qalive_[k] = 0;
	return false;
}

void CityCore::scare(double x, double y) {
	int buf[CAP];
	int n = query(x, y, 2, buf);
	for (int q = 0; q < n; q++) {
		int j = buf[q];
		if (kind_[j] != K_PED || mode_[j] == M_DEAD) continue;
		double rx = px_[j] - x, ry = py_[j] - y;
		if (rx * rx + ry * ry < 81.0) {
			mode_[j] = M_FLEE;
			t1_[j] = 2.5 + rnd() * 2.0;
			sx_[j] = x;
			sy_[j] = y;
		}
	}
}

}  // namespace gtai::sim
