## Unique Data
- Magic Number (if binary format used)
- Spec Version Number
- Key Size or Delimiter

## Packet Format:
`[Key] [Payload Length] [Payload Data]`

## Common Packets:
| Type | Size | Description |
| --- | --- | --- |
| ConsoleType | 1 byte | Possible values: NES, SNES, N64, Gamecube, GB, GBC, GBA, Genesis, A2600,... |
| ConsoleRegion | 1 byte | Possible values: NTSC, PAL |
| GameTitle | 0-65535 bytes | May be ROM file name, or game name retrieved from a database? |
| Hashes | ? | Should probably include MD5, SHA-1, SHA-254, or others |
| Author | 0-65535 bytes | Either reusable key/entry (preferable), or a single list delimited by something |
| Category | 0-65535 bytes | Category of TAS (e.g. any%) |
| EmulatorName | 0-255 bytes | Name of emulator (e.g. BizHawk, FCEUX,...)
| EmulatorVersion | 0-255 bytes | Probably a string? Might contain decimals |
| TASLastModified | ? | Formats Ideas: Unix Epoch, ISO 8601, YYYY-MM-DD |
| NumberOfFrames | 4 bytes | 32bit unsigned number |
| RAMInitType | 1 byte | Does RAM need to be initialized? If yes, in what pattern? |
| SaveInitType | 1 byte | Does Save Memory need to be initialized? If yes, in what pattern? |
| RerecordCount | 4 bytes | 32bit unsigned number of rerecords |
| SourceLink | 3 bytes | Link to TAS Publication or Video |
| BlankFrames | 0-65535 bytes | 16bit signed number to add blank frames, or subtract from movie |
| Verified | 1 byte | boolean whether this TAS has been verified before |

## NES Specific Packets:
| Type | Size | Description |
| --- | --- | --- |
| LatchFilter | 1 byte | Latch Filter time span (value multiplied by 0.1ms; inclusive range of 0.0ms to 25.5ms) |
| ClockFilter | 1 byte | Clock Filter time span (value multiplied by 0.25us; inclusive range of 0.0us to 63.75us) |
| Overread | 1 byte | If overread occurs, whether to give a 0 or a 1 |
| DPCM | 1 byte | Is DPCM used in this TAS? |
| GameGenieCode | 8 bytes | A Game Genie code |
| ControllerPortType | 2 bytes | Port Number (1-indexed) in first byte. Controller Type in second byte. Possible types: Standard, Multitap (Four Score), Zapper |

## SNES Specific Packets:
| Type | Size | Description |
| --- | --- | --- |
| LatchTrains | ? | More info needed... |
| ControllerPortType | 2 bytes | Port Number (1-indexed) in first byte. Controller Type in second byte. Possible types: Standard, Multitap, Mouse, Superscope |

## N64 Specific Packets:
| Type | Size | Description |
| --- | --- | --- |
| ControllerPortType | 2 bytes | Port Number (1-indexed) in first byte. Controller Type in second byte. Possible types: Standard, Standard with Controller Pak, Standard with Transfer Pak, RandNet Keyboard, Voice Recognition Unit (VRU), Mouse, Densha de Go (only used for 1 game), Dancepad (more research needed) |

## Gamecube Specific Packets:
More research required...

## Wii Specific Packets:
More research required...

## GB/C/A Specific Packets:
More research required... (variable length frames?)

## Genesis Specific Packets:
| Type | Size | Description |
| --- | --- | --- |
| ControllerPortType | 2 bytes | Port Number (1-indexed) in first byte. Controller Type in second byte. Possible types: 3-Button (uses 8 bits), 6-Button (uses 12 bits) |

## A2600 Specific Packets:
| Type | Size | Description |
| --- | --- | --- |
| ControllerPortType | 2 bytes | Port Number (1-indexed) in first byte. Controller Type in second byte. Possible types: Joystick (uses 5 bits), Paddles (uses 2 bits, and 2 pots?), many others... |

## Input Related Packets:
| Type | Size | Description |
| --- | --- | --- |
| Input | 2 + ? bytes | Need some way to specify what kind of input this is. That will determine how wide this is. |
| LagFrame | 4 + 4 bytes | 4 bytes specifying frame number, 4 bytes specifying number of lag frames including first. |
| TransitionFrame | 4 + 2 bytes | 4 bytes specifying frame number, 2 bytes specifying transition type. Types include: "Soft" Reset, Power Reset, possibly others... |