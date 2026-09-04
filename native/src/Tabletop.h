#pragma once

namespace savr::tabletop {

// Process-start settings for the private tabletop prototype. The defaults are
// supplied in vr_tabletop.ini and can be overridden with debug.savr.tabletop
// and debug.savr.tabletop_scale for quick A/B testing.
bool Enabled();
float VisualScale();
float AnchorForwardMeters();
float AnchorDownMeters();

} // namespace savr::tabletop
