# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), although currently without version numbers added.


## 2023-09-24

### Changed
- Specify INPUT_CHUNK offset for Index Value of TRANSITION packet

### Fixed
- EXPERIMENTAL packet drawing error and packet value length

### Added
- SNES_LATCH_FILTER
- Port value to TRANSITION packet

### Removed
- SNES_OVERREAD and NES_OVERREAD


## 2023-09-18
### Changed
- Specify that PEXP MUST be greater than 0


## 2023-09-17
### Added
- "Structure" section in spec to better define the overall structure of a TASD file


## 2023-09-14
### Fixed
- Key values in description section 3.2.3

### Changed
- SNES_LATCH_TRAIN description


## 2023-07-15
### Fixed
- Spelling mistakes in spec


## 2023-07-06
### Added
- rasteri to `LICENSES.txt`, spec contributors list, and spec LICENSE

### Removed
- VG Interactive organization Vi Grey

### Fixed
- \<bcp14\> tag around MUST instead of \<strong\> tag in spec


## 2023-07-06
### Added
- SNES Super Multitap input format to spec
- Additional build instructions

### Changed
- Updated copyright year in `LICENSES.txt` and in spec
- Reordered Genesis 3-button and 6-button controller formats


## 2023-07-03
### Added
- SNES_LATCH_TRAIN to spec

### Removed
- PDF files from `docs/`
- PDF file generation via Makefile

### Fixed
- Correct length for Data of MEMORY_INIT in spec
- Correct length of Name of MOVIE_FILE packet in spec


## 2022-09-26
### Added
- TODO.md file
- "Licenses" section in `README.md` file
- "Contributing" section in `README.md` file

### Removed
- "TODO" section in `README.md` file


## 2022-09-26
### Changed
- Rename `docs/draft-tasd-spec-0001/` to `docs/tasd-spec-0001/`

### Fixed
- Use correct path for compiled documents for Makefile contribution rule


## 2022-09-26
### Added
- `latest/` and `tasd-spec-{version}/` directories to `docs/`
- "contribution" rule in `Makefile` to automate the process of adding updated documents to the `docs/` directory
- "Keep a Changelog" link and sentence to this `CHANGELOG.md` file
- Initial `CONTRIBUTING.md` file

### Changed
- Rename `draft-tasd-{version}` to `draft-tasd-spec-{version}`
- Clean up documents rule in `Makefile` to avoid using `cd` and `mv`


## 2022-09-24
### Fixed
- Capitalize "Bigbass" in `README.md`


## 2022-09-24
### Added
- Initial release
