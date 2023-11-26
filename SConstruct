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

is_editor = "" if env["target"] == "template_release" else "_editor"

if env["platform"] == "macos":
    library = env.SharedLibrary(
        "project/addons/gonzago/lib/{0}/gonzago_{0}{1}.framework/libgonzago.{0}{1}".format(
            env["platform"],
            is_editor
        ),
        source=sources,
    )
else:
    library = env.SharedLibrary(
        "project/addons/gonzago/lib/{0}/gonzago_{0}{1}-{2}{3}".format(
            env["platform"],
            is_editor,
            env["arch"],
            env["SHLIBSUFFIX"]
        ),
        source=sources,
    )

Default(library)
