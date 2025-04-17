## Contribution
If you wish to contribute to this project, please be aware of and follow these rules:
* If you make an update to this repository, please update the `CHANGELOG.md` file accordingly.  The style of the `CHANGELOG.md` file is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
* If you edit the `.xml` file in `src/docs/`, please update the changelog at the bottom of the `.xml` file.  The current style is `draft [{DraftNum}] - {Year}-{Month}-{Day}   {Initials}    {Description}` followed by a new line, where {DraftNum} is an incrementing 2 digit decimal number (can be 00-99), {Year} is the 4 digit year number, {Month} is the 2 digit month number, {Day} is the 2 digit day number, {Initials} are some initials to help differentiate changelog editors (Vi Grey's initials are **VG**, for example), and {Description} is a description of what you changed. (These instructions may change in the future.)

## Building
### Dependencies
- xml2rfc
- make

`xml2rfc` can be installed from the Python3 PIP package manager (`pip3 install xml2rfc`). Some distributions may prefer you to install programs with pipx instead of pip, like Arch Linux (`pipx install xml2rfc`).

Alternatively, if using linux, xml2rfc may be available in your distribution's repositories via your package manager. For instance, `sudo apt install xml2rfc` on Ubuntu/Debian, or `pacman -S xml2rfc` on Arch Linux (AUR).

### Build (temporary instructions)
From a terminal, go to the the main directory of this project (the directory this CONTRIBUTING.md file exists in).  You can then build the HTML and TXT formatted documents with:
```sh
make documents
```
After building the documentation, you should find the exported `.html` and `.txt` files in the `build/docs/` directory.

The source code for the documentation can be found in `src/docs/`.  The xml2rfc vocabulary of the xml file is explained in [RFC 7991](https://www.rfc-editor.org/rfc/rfc7991).

To copy the generated HTML and TXT files to the final `docs/` directory, run:
```sh
make contribution
```
