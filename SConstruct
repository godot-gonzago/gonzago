#!/usr/bin/env python
import os
import sys

env = SConscript("godot-cpp/SConstruct")

# For reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# tweak this if you want to use different folders, or more folders, to store your source code in.
env.Append(CPPPATH=["src/"])
sources = Glob("src/*.cpp")

addon_path = "project/addons/gonzago"
project_name = "gonzago"
debug_or_release = "release" if env["target"] == "template_release" else "debug"

if env["platform"] == "macos":
    library = env.SharedLibrary(
        "{}/bin/lib{}.{}.{}.framework/libgdexample.{}.{}".format(
            addon_path,
            project_name,
            env["platform"],
            debug_or_release,
            env["platform"],
            debug_or_release
        ),
        source=sources,
    )
else:
    library = env.SharedLibrary(
        "{}/bin/lib{}.{}.{}.{}{}".format(
            addon_path,
            project_name,
            env["platform"],
            debug_or_release,
            env["arch"],
            env["SHLIBSUFFIX"]
        ),
        source=sources,
    )

Default(library)
