The goal of this project is to create a file format that can eliminate the need for multiple intermediary dump files (e.g. r08, r16, etc). The format should be expandable without radical changes to the spec. The format shouldn't care what a replay device is, nor how the file should get into a replay device. The format needs to be easily generatable from Lua, and specifically the Lua contained in emulators. Keep in mind that dumps are performed sequentially, possibly without the ability to go back to something already written.

Current task is to formalize _what_ and _how much_ data may need to be stored, either at dump-time, or via external software at a later time.