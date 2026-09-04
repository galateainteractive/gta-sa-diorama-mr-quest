#include "Tabletop.h"

#include "Log.h"

#include <sys/system_properties.h>

#include <algorithm>
#include <cctype>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <mutex>
#include <strings.h>

namespace savr::tabletop {
namespace {

constexpr char kSettingsPath[] =
    "/sdcard/Android/data/com.rockstargames.gtasa/files/vr_tabletop.ini";
constexpr char kEnabledProperty[] = "debug.savr.tabletop";
constexpr char kScaleProperty[] = "debug.savr.tabletop_scale";

struct Settings {
    bool enabled{true};
    float visualScale{0.04f};
    float anchorForwardMeters{1.25f};
    float anchorDownMeters{0.55f};
};

Settings g_settings{};
std::once_flag g_loadOnce;

char* Trim(char* text) {
    while (*text && std::isspace(static_cast<unsigned char>(*text))) ++text;
    char* end = text + std::strlen(text);
    while (end > text && std::isspace(static_cast<unsigned char>(end[-1]))) --end;
    *end = '\0';
    return text;
}

bool ParseBool(const char* value, bool fallback) {
    if (!value) return fallback;
    if (std::strcmp(value, "1") == 0 || strcasecmp(value, "true") == 0 ||
        strcasecmp(value, "on") == 0 || strcasecmp(value, "yes") == 0) {
        return true;
    }
    if (std::strcmp(value, "0") == 0 || strcasecmp(value, "false") == 0 ||
        strcasecmp(value, "off") == 0 || strcasecmp(value, "no") == 0) {
        return false;
    }
    return fallback;
}

float ParseFloat(const char* value, float fallback) {
    if (!value) return fallback;
    char* end = nullptr;
    const float parsed = std::strtof(value, &end);
    return end != value && std::isfinite(parsed) ? parsed : fallback;
}

void LoadSettings() {
    Settings loaded{};
    if (FILE* file = std::fopen(kSettingsPath, "r")) {
        char line[192]{};
        while (std::fgets(line, sizeof(line), file)) {
            if (char* comment = std::strchr(line, '#')) *comment = '\0';
            char* key = Trim(line);
            if (*key == '\0') continue;
            char* separator = std::strchr(key, '=');
            if (!separator) continue;
            *separator = '\0';
            char* value = Trim(separator + 1);
            key = Trim(key);
            if (strcasecmp(key, "enabled") == 0) {
                loaded.enabled = ParseBool(value, loaded.enabled);
            } else if (strcasecmp(key, "visual_scale") == 0) {
                loaded.visualScale = ParseFloat(value, loaded.visualScale);
            } else if (strcasecmp(key, "anchor_forward_m") == 0) {
                loaded.anchorForwardMeters =
                    ParseFloat(value, loaded.anchorForwardMeters);
            } else if (strcasecmp(key, "anchor_down_m") == 0) {
                loaded.anchorDownMeters = ParseFloat(value, loaded.anchorDownMeters);
            }
        }
        std::fclose(file);
    }

    char property[PROP_VALUE_MAX]{};
    if (__system_property_get(kEnabledProperty, property) > 0) {
        loaded.enabled = ParseBool(Trim(property), loaded.enabled);
    }
    if (__system_property_get(kScaleProperty, property) > 0) {
        loaded.visualScale = ParseFloat(Trim(property), loaded.visualScale);
    }

    loaded.visualScale = std::clamp(loaded.visualScale, 0.01f, 0.20f);
    loaded.anchorForwardMeters =
        std::clamp(loaded.anchorForwardMeters, 0.25f, 3.00f);
    loaded.anchorDownMeters = std::clamp(loaded.anchorDownMeters, 0.10f, 1.50f);
    g_settings = loaded;
    LOGI("[tabletop] enabled=%d scale=%.3f anchor_forward=%.2fm anchor_down=%.2fm",
         loaded.enabled ? 1 : 0, static_cast<double>(loaded.visualScale),
         static_cast<double>(loaded.anchorForwardMeters),
         static_cast<double>(loaded.anchorDownMeters));
}

const Settings& GetSettings() {
    std::call_once(g_loadOnce, LoadSettings);
    return g_settings;
}

} // namespace

bool Enabled() { return GetSettings().enabled; }
float VisualScale() { return GetSettings().visualScale; }
float AnchorForwardMeters() { return GetSettings().anchorForwardMeters; }
float AnchorDownMeters() { return GetSettings().anchorDownMeters; }

} // namespace savr::tabletop
