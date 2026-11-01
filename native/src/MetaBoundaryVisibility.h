#pragma once

// OpenXR 1.1.43 predates XR_META_boundary_visibility. Keep the verified loader
// and vendor headers intact, and provide only the registered extension ABI that
// the Quest runtime exposes. Remove this compatibility block when the vendored
// OpenXR headers are updated to a revision that defines the extension itself.
#ifndef XR_META_boundary_visibility
#define XR_META_boundary_visibility 1
#define XR_META_boundary_visibility_SPEC_VERSION 1
#define XR_META_BOUNDARY_VISIBILITY_EXTENSION_NAME "XR_META_boundary_visibility"

#define XR_TYPE_SYSTEM_BOUNDARY_VISIBILITY_PROPERTIES_META \
    ((XrStructureType)1000528000)
#define XR_TYPE_EVENT_DATA_BOUNDARY_VISIBILITY_CHANGED_META \
    ((XrStructureType)1000528001)
#define XR_BOUNDARY_VISIBILITY_SUPPRESSION_NOT_ALLOWED_META \
    ((XrResult)1000528000)

typedef enum XrBoundaryVisibilityMETA {
    XR_BOUNDARY_VISIBILITY_NOT_SUPPRESSED_META = 1,
    XR_BOUNDARY_VISIBILITY_SUPPRESSED_META = 2,
    XR_BOUNDARY_VISIBILITY_MAX_ENUM_META = 0x7FFFFFFF
} XrBoundaryVisibilityMETA;

typedef struct XrSystemBoundaryVisibilityPropertiesMETA {
    XrStructureType type;
    void* next;
    XrBool32 supportsBoundaryVisibility;
} XrSystemBoundaryVisibilityPropertiesMETA;

typedef struct XrEventDataBoundaryVisibilityChangedMETA {
    XrStructureType type;
    const void* next;
    XrBoundaryVisibilityMETA boundaryVisibility;
} XrEventDataBoundaryVisibilityChangedMETA;

typedef XrResult(XRAPI_PTR* PFN_xrRequestBoundaryVisibilityMETA)(
    XrSession session,
    XrBoundaryVisibilityMETA boundaryVisibility);
#endif
