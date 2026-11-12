#pragma once

// The retail-compatible build keeps the original Android package by default.
// Experimental side-by-side builds override SAVR_PACKAGE_NAME from CMake.
#ifndef SAVR_PACKAGE_NAME
#define SAVR_PACKAGE_NAME "com.rockstargames.gtasa"
#endif

#define SAVR_EXTERNAL_FILES_DIR "/sdcard/Android/data/" SAVR_PACKAGE_NAME "/files"
