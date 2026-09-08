#pragma once

#include <cstdint>

namespace savr::tabletop_flicker {
// Add independently mixed identities, rather than hashing their traversal
// order. GTA qsorts the LOD list for each eye. Reordering is not membership
// churn. Multiplicity is retained (unlike a plain XOR); collisions remain
// theoretically possible, so this is a diagnostic witness, not set equality.
constexpr std::uint64_t Token(std::uint64_t value) {
    value += 0x9e3779b97f4a7c15ULL;
    value = (value ^ (value >> 30)) * 0xbf58476d1ce4e5b9ULL;
    value = (value ^ (value >> 27)) * 0x94d049bb133111ebULL;
    return value ^ (value >> 31);
}
constexpr bool CanReplaceRank(int incoming, int resident) {
    return incoming >= 0 && (resident < 0 || resident > incoming);
}
enum class MaskDecision { Skip, ApplySnapshot, FailClosed };
constexpr MaskDecision DecideMask(bool snapshotActive, bool liveActive,
                                  bool passthroughActive) {
    if (!passthroughActive) return MaskDecision::Skip;
    if (snapshotActive) return MaskDecision::ApplySnapshot;
    return liveActive ? MaskDecision::FailClosed : MaskDecision::Skip;
}
static_assert(CanReplaceRank(3, -1)); // P33 regression: newcomer was rejected.
static_assert(CanReplaceRank(3, 7));
static_assert(!CanReplaceRank(3, 2));
static_assert(!CanReplaceRank(3, 3));
static_assert(!CanReplaceRank(-1, -1));
static_assert(Token(10) + Token(20) == Token(20) + Token(10));
static_assert(Token(10) + Token(20) != Token(10) + Token(21));
static_assert(Token(10) + Token(10) != 0);
// A synchronized tabletop frame always wins over the transient live camera
// flag. The GameThread deliberately drops that flag while rebuilding a frame.
static_assert(DecideMask(true, false, true) == MaskDecision::ApplySnapshot);
static_assert(DecideMask(true, true, true) == MaskDecision::ApplySnapshot);
static_assert(DecideMask(false, true, true) == MaskDecision::FailClosed);
static_assert(DecideMask(false, false, true) == MaskDecision::Skip);
static_assert(DecideMask(true, true, false) == MaskDecision::Skip);
} // namespace savr::tabletop_flicker
