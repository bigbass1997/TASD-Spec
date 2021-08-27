The **TASD (Tool Assisted Speedrun Dump)**, is a dump file format for replaying TASes on real hardware. It is structured to be independent on any given console, replay-device, or emulator. It can contain any amount of data, including attributions, emulation context, inputs, transitions, replay constraints, and much more.

Specification details and examples can be found in [Spec.md](Spec.md). Controller input maps are defined in [inputmaps.txt](inputmaps.txt).

**Latest Version:** 0x0001

## Tools and Scripts
[TASD-Edit](https://github.com/bigbass1997/TASD-Edit) is a cross-platform, CLI-based editor for TASD files. Can create/edit TASD files, and import or export legacy formats: r08, r16m, and GBI.

ViGreyTech has created a single-file [Lua dump script]() that works across multiple emulators and consoles.

If you'd like to create your own Lua script, Bigbass has created a [Lua API/library]() to aid in generating TASD files.
