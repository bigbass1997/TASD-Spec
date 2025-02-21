# **TASD File Format Specification And Tools**

Specification and Tools for the Tool Assisted Speedrun Dump (TASD) interchange format

<ins>**IMPORTANT**</ins> - This specification is in a DRAFT phase.  Expect inaccuracies, typos, and considerable changes.  Nothing is set in stone.

## Description:

The Tool Assisted Speedrun Dump (TASD) interchange format is a file format initially designed by [Vi Grey](https://github.com/vigrey) and [Bigbass](https://github.com/bigbass1997) for storing data to allow "Tool Assisted Speedruns" or "Tool Assited Superplays" to be played on physical video game console hardware using TAS replay devices.  Created to be hardware and software agnostic, the TASD interchange format uses a key-based, binary, packet format to break up pieces of information into easily-parsable and forward-compatible chunks.  The format is extensible by simply defining additional keys or value types as necessary.  When parsing the file, software can skip any packets whose key is unknown or unsupported.

Keys can be used multiple times or completely omitted as needed.  This reusability eliminates the need of a predefined delimiter to separate pieces of data such as a list of TAS authors.

While files generated by emulator dump scripts should provide as much information as possible, because keys are optional, the file can be expanded later with any additional data as desired. No intermediary file format is necessary.


## **Reading the Specification Documentation**

The specification documentation can be found at `docs/latest/draft-tasd-spec.html`, and `docs/latest/draft-tasd-0001.txt` and is presented in a format quite similar to IETF (Internet Engineering Task Force) RFC (Request For Comment) documents.


## **Building the Specification Documentation**

### Documentation Build Dependencies
- xml2rfc

All dependencies can be installed from the Python3 PIP package manager (`pip3 install xml2rfc`). Some distributions may prefer you to install programs with pipx instead of pip, like Arch Linux (`pipx install xml2rfc`).

Alternatively, if using linux, xml2rfc may be available in your distribution's repositories via your package manager. For instance, `sudo apt install xml2rfc` on Ubuntu/Debian, or `pacman -S xml2rfc` on Arch Linux (AUR).

### Build the Documentation
From a terminal, go to the the main directory of this project (the directory this README.md file exists in).  You can then build the HTML and TXT formatted documents with:
```sh
make documents
```

After building the documentation, you should find `draft-tasd-0001.html`,  and `draft-tasd-0001.txt` in the `build/docs/` directory.

The source code for the documentation can be found in `src/docs/draft-tasd-0001.xml`.  The xml2rfc vocabulary of the xml file is explained in [RFC 7991](https://www.rfc-editor.org/rfc/rfc7991).

To copy the generated HTML and TXT files to the final `docs/` directory, run:
```sh
make contribution
```


## Tools and Scripts

Included in this repository is a small set of tools, which will hopefully grow to a larger set of tools over time.

A lua script to dump a FCEUX TAS to a TASD file can be found at `tools/lua/tasd-fceux-dumpscript.lua`.

A tool to convert a TASD file to an r08 file can be found at `tools/tasd2r08/tasd2r08.py`.

[TASD-Edit](https://github.com/bigbass1997/TASD-Edit) is a cross-platform, CLI-based editor for TASD files. Can create/edit TASD files, and import or export legacy formats: r08, r16m, and GBI.


## Contributing

If you wish to contribute to this project, please take a look at `CONTRIBUTING.md`


## Licenses

To see the licenses of the specification documentation along with any included tools, please look at `LICENSE.txt`
