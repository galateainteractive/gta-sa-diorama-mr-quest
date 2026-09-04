#pragma once

namespace savr::tabletop {

// Process-start settings for the private tabletop prototype. The defaults are
// supplied in vr_tabletop.ini and can be overridden with debug.savr.tabletop
// and debug.savr.tabletop_scale for quick A/B testing.
bool Enabled();
float VisualScale();
void SetVisualScale(float scale);
void ResetVisualScale();
float AnchorForwardMeters();
float AnchorDownMeters();
bool PassthroughEnabled();

int RadiusPresetIndex();
float RadiusMeters();
float CycleRadiusPreset();
void ResetRadiusPreset();

} // namespace savr::tabletop
