#include "Tabletop.h"

#include "Log.h"

#include <sys/system_properties.h>

#include <algorithm>
#include <atomic>
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
constexpr char kSettingsTempPath[] =
    "/sdcard/Android/data/com.rockstargames.gtasa/files/vr_tabletop.ini.tmp";
constexpr char kEnabledProperty[] = "debug.savr.tabletop";
constexpr char kScaleProperty[] = "debug.savr.tabletop_scale";

struct Settings {
    bool enabled{true};
    bool passthrough{true};
    float visualScale{0.01f};
    float anchorForwardMeters{1.25f};
    float anchorDownMeters{0.55f};
    int radiusPreset{1};
};

Settings g_settings{};
std::once_flag g_loadOnce;
std::mutex g_saveMutex;
std::atomic<bool> g_activeEnabled{true};
std::atomic<bool> g_configuredEnabled{true};
std::atomic<float> g_visualScale{0.01f};
std::atomic<int> g_radiusPreset{1};
// Preset 3 is deliberately a 75 m A/B step. 90 m was already close enough
// to the expensive 120 m disk that it did not answer whether the stable 60 m
// profile could grow a little without bringing the visible sector churn back.
constexpr float kRadiusPresets[]{30.0f, 60.0f, 75.0f, 120.0f};
constexpr int kRadiusPresetCount =
    static_cast<int>(sizeof(kRadiusPresets) / sizeof(kRadiusPresets[0]));
// Package 49 makes the proven 60 m profile the production Diorama MR
// coverage. The other values remain available to future explicit developer
// or experimental-menu work, but preserved personal settings must not start
// normal play in one of the expensive/undersized profiles.
constexpr int kOfficialRadiusPreset = 1;

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

bool IsEnabledSetting(const char* source) {
    if (!source) return false;
    char line[192]{};
    std::snprintf(line, sizeof(line), "%s", source);
    if (char* comment = std::strchr(line, '#')) *comment = '\0';
    char* key = Trim(line);
    char* separator = std::strchr(key, '=');
    if (!separator) return false;
    *separator = '\0';
    return strcasecmp(Trim(key), "enabled") == 0;
}

bool SaveConfiguredEnabled(bool enabled) {
    std::lock_guard<std::mutex> lock(g_saveMutex);
    FILE* output = std::fopen(kSettingsTempPath, "w");
    if (!output) {
        LOGW("[tabletop.settings] could not open temporary settings file");
        return false;
    }

    bool found = false;
    if (FILE* input = std::fopen(kSettingsPath, "r")) {
        char line[192]{};
        while (std::fgets(line, sizeof(line), input)) {
            if (IsEnabledSetting(line)) {
                std::fprintf(output, "enabled=%d\n", enabled ? 1 : 0);
                found = true;
            } else {
                std::fputs(line, output);
            }
        }
        std::fclose(input);
    } else {
        const Settings& current = g_settings;
        std::fprintf(output,
                     "# GTA SA Diorama MR miniature-mode settings.\n"
                     "passthrough=%d\n"
                     "visual_scale=%.3f\n"
                     "anchor_forward_m=%.2f\n"
                     "anchor_down_m=%.2f\n"
                     "radius_preset=%d\n",
                     current.passthrough ? 1 : 0,
                     static_cast<double>(current.visualScale),
                     static_cast<double>(current.anchorForwardMeters),
                     static_cast<double>(current.anchorDownMeters),
                     current.radiusPreset);
    }
    if (!found) std::fprintf(output, "enabled=%d\n", enabled ? 1 : 0);

    const bool writeOk = std::fflush(output) == 0 &&
                         std::ferror(output) == 0;
    const bool closeOk = std::fclose(output) == 0;
    if (!writeOk || !closeOk ||
        std::rename(kSettingsTempPath, kSettingsPath) != 0) {
        std::remove(kSettingsTempPath);
        LOGW("[tabletop.settings] could not persist play mode");
        return false;
    }
    return true;
}

void LoadSettings() {
    Settings loaded{};
    bool loadedSettingsFile = false;
    if (FILE* file = std::fopen(kSettingsPath, "r")) {
        loadedSettingsFile = true;
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
            } else if (strcasecmp(key, "passthrough") == 0) {
                loaded.passthrough = ParseBool(value, loaded.passthrough);
            } else if (strcasecmp(key, "visual_scale") == 0) {
                loaded.visualScale = ParseFloat(value, loaded.visualScale);
            } else if (strcasecmp(key, "anchor_forward_m") == 0) {
                loaded.anchorForwardMeters =
                    ParseFloat(value, loaded.anchorForwardMeters);
            } else if (strcasecmp(key, "anchor_down_m") == 0) {
                loaded.anchorDownMeters = ParseFloat(value, loaded.anchorDownMeters);
            } else if (strcasecmp(key, "radius_preset") == 0) {
                loaded.radiusPreset = static_cast<int>(
                    ParseFloat(value, static_cast<float>(loaded.radiusPreset)));
            }
        }
        std::fclose(file);
    }

    // Personal-update installers preserve the existing settings file. Migrate
    // only the exact shipped 0.040 default so Package 46 reaches the requested
    // farthest startup zoom without trampling any other custom scale.
    if (loadedSettingsFile &&
        std::abs(loaded.visualScale - 0.040f) < 0.0001f) {
        loaded.visualScale = 0.010f;
    }

    const bool configuredEnabled = loaded.enabled;
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
    loaded.radiusPreset = std::clamp(loaded.radiusPreset, 0,
                                     kRadiusPresetCount - 1);
    if (loaded.radiusPreset != kOfficialRadiusPreset) {
        LOGI("[tabletop.settings] radius preset %d migrated to official 60m preset",
             loaded.radiusPreset);
        loaded.radiusPreset = kOfficialRadiusPreset;
    }
    g_settings = loaded;
    g_activeEnabled.store(loaded.enabled, std::memory_order_relaxed);
    g_configuredEnabled.store(configuredEnabled, std::memory_order_relaxed);
    g_visualScale.store(loaded.visualScale, std::memory_order_relaxed);
    g_radiusPreset.store(loaded.radiusPreset, std::memory_order_relaxed);
    LOGI("[tabletop] enabled=%d passthrough=%d scale=%.3f anchor_forward=%.2fm anchor_down=%.2fm radius=%.0fm",
         loaded.enabled ? 1 : 0, loaded.passthrough ? 1 : 0,
         static_cast<double>(loaded.visualScale),
         static_cast<double>(loaded.anchorForwardMeters),
         static_cast<double>(loaded.anchorDownMeters),
         static_cast<double>(kRadiusPresets[loaded.radiusPreset]));
}

const Settings& GetSettings() {
    std::call_once(g_loadOnce, LoadSettings);
    return g_settings;
}

} // namespace

bool Enabled() {
    (void)GetSettings();
    return g_activeEnabled.load(std::memory_order_relaxed);
}
bool ConfiguredEnabled() {
    (void)GetSettings();
    return g_configuredEnabled.load(std::memory_order_relaxed);
}
bool SetConfiguredEnabled(bool enabled) {
    (void)GetSettings();
    if (enabled == g_configuredEnabled.load(std::memory_order_relaxed))
        return true;
    if (!SaveConfiguredEnabled(enabled)) return false;
    g_configuredEnabled.store(enabled, std::memory_order_release);
    LOGI("[tabletop.settings] next play mode=%s restart_required=%d",
         enabled ? "diorama" : "immersive", enabled != Enabled() ? 1 : 0);
    return true;
}
bool ModeChangeNeedsRestart() { return ConfiguredEnabled() != Enabled(); }
float VisualScale() {
    (void)GetSettings();
    return g_visualScale.load(std::memory_order_relaxed);
}
void SetVisualScale(float scale) {
    (void)GetSettings();
    g_visualScale.store(std::clamp(scale, 0.01f, 0.20f),
                        std::memory_order_relaxed);
}
void ResetVisualScale() { SetVisualScale(GetSettings().visualScale); }
float AnchorForwardMeters() { return GetSettings().anchorForwardMeters; }
float AnchorDownMeters() { return GetSettings().anchorDownMeters; }
bool PassthroughEnabled() { return GetSettings().passthrough; }

int RadiusPresetIndex() {
    (void)GetSettings();
    return g_radiusPreset.load(std::memory_order_relaxed);
}
float RadiusMeters() { return kRadiusPresets[RadiusPresetIndex()]; }
float CycleRadiusPreset() {
    (void)GetSettings();
    int current = g_radiusPreset.load(std::memory_order_relaxed);
    int next{};
    do {
        next = (current + 1) % kRadiusPresetCount;
    } while (!g_radiusPreset.compare_exchange_weak(
        current, next, std::memory_order_relaxed));
    return kRadiusPresets[next];
}
void ResetRadiusPreset() {
    (void)GetSettings();
    g_radiusPreset.store(kOfficialRadiusPreset, std::memory_order_relaxed);
}

} // namespace savr::tabletop
