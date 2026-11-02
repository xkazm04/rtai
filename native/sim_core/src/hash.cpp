// Spatial hash over tier-A actors: a HW x HW window of HC-metre cells around the camera,
// counting sort into hitems_ so queries return ids in a fixed order.
#include <cstring>

#include "city_core.h"
#include "sim_math.h"

namespace gtai::sim {

void CityCore::build_hash(double camx, double camy) {
	hgx_ = floori(camx / HC) - HW / 2;
	hgy_ = floori(camy / HC) - HW / 2;
	const int n = HW * HW;
	std::memset(hcount_, 0, sizeof(hcount_));
	for (int i = 0; i < CAP; i++) {
		if (alive_[i] == 0 || tier_[i] != 0) continue;
		int gx = floori(px_[i] / HC) - hgx_, gy = floori(py_[i] / HC) - hgy_;
		if (gx < 0 || gy < 0 || gx >= HW || gy >= HW) continue;
		hcount_[gy * HW + gx] += 1;
	}
	int s = 0;
	for (int c = 0; c < n; c++) {
		hstart_[c] = s;
		s += hcount_[c];
		hcount_[c] = 0;
	}
	hstart_[n] = s;
	for (int i = 0; i < CAP; i++) {
		if (alive_[i] == 0 || tier_[i] != 0) continue;
		int gx = floori(px_[i] / HC) - hgx_, gy = floori(py_[i] / HC) - hgy_;
		if (gx < 0 || gy < 0 || gx >= HW || gy >= HW) continue;
		int c = gy * HW + gx;
		hitems_[hstart_[c] + hcount_[c]] = i;
		hcount_[c] += 1;
	}
}

// The ids in the (2r+1)^2 cells around a point, row by row.
int CityCore::query(double x, double y, int r, int *out) const {
	int n = 0;
	int gx = floori(x / HC) - hgx_, gy = floori(y / HC) - hgy_;
	for (int cy = gy - r; cy <= gy + r; cy++) {
		if (cy < 0 || cy >= HW) continue;
		for (int cx = gx - r; cx <= gx + r; cx++) {
			if (cx < 0 || cx >= HW) continue;
			int c = cy * HW + cx;
			int s = hstart_[c];
			for (int k = 0; k < hcount_[c]; k++) out[n++] = hitems_[s + k];
		}
	}
	return n;
}

}  // namespace gtai::sim
