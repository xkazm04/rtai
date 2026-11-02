// Helpers shared by the core TUs. Only operations that round identically in GDScript and C++
// (NAT-07): floor via std::floor, comparisons, and tables of exactly representable doubles.
#pragma once

#include <cmath>

namespace gtai::sim {

inline int floori(double x) { return (int)std::floor(x); }
inline double minf(double a, double b) { return a < b ? a : b; }
inline double maxf(double a, double b) { return a > b ? a : b; }
inline double clampf(double x, double lo, double hi) { return x < lo ? lo : (x > hi ? hi : x); }

// Lane directions E S W N (+y is south), and lane = road centre + LANE_OFF[dir] (right-hand).
inline constexpr double DX[4] = {1.0, 0.0, -1.0, 0.0};
inline constexpr double DY[4] = {0.0, 1.0, 0.0, -1.0};
inline constexpr double LANE_OFF[4] = {2.0, -2.0, -2.0, 2.0};

// 16 headings as integer vectors, normalised with sqrt at init: decimal literals would round
// differently in GDScript and MSVC in the last bit.
inline constexpr int DIR16I[32] = {1, 0, 12, 5, 1, 1, 5, 12, 0, 1, -5, 12, -1, 1, -12, 5,
	-1, 0, -12, -5, -1, -1, -5, -12, 0, -1, 5, -12, 1, -1, 12, -5};

}  // namespace gtai::sim
