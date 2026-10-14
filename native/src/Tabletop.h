#pragma once

namespace savr::tabletop {

// Process-start settings for Diorama MR's tabletop implementation. Defaults are
// supplied in vr_tabletop.ini and can be overridden with debug.savr.tabletop
// and debug.savr.tabletop_scale for quick A/B testing.
bool Enabled();
// The mode selected in vr_tabletop.ini for the next process start. Enabled()
// remains the immutable mode of the current process so OpenXR/render hooks are
// never switched underneath a live game.
bool ConfiguredEnabled();
bool SetConfiguredEnabled(bool enabled);
bool ModeChangeNeedsRestart();
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
