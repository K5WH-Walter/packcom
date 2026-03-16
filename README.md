# PackCom — C++ Reconstruction

**Original:** PackCom v0.75 Dev. by Jim Wright (WB4ZJV), 01/28/1987  
**Reconstruction:** Portable C++17, cross-platform (Linux / macOS / Windows)

---

## Background

The three original files were compiled Turbo Pascal binaries produced by
Borland Pascal circa 1985–1987.  There was no source available — this
C++ codebase was reconstructed entirely from the binary strings, control
flow hints, variable names exposed in the debug output section, and the
full set of UI prompts recovered from the overlay files.

| Original file  | Size   | Role |
|----------------|--------|------|
| `PACKCOM.COM`  | 44 KB  | Main executable (Borland Pascal runtime + core code) |
| `PACKCOM.000`  | 11 KB  | Overlay 0 – config menus, color setup, capture mode |
| `PACKCOM.001`  | 40 KB  | Overlay 1 – YAPP transfer, scroll-back, file ops, I/O |

---

## Features Reconstructed

All of these were confirmed from binary string extraction:

### Terminal / Display
- Full-colour ANSI terminal (80×25 native; adapts to actual terminal size)
- AX.25 packet header detection and distinct colouring
- Keyboard/Digi echo detection — outgoing packets echoed back are
  highlighted differently from new incoming traffic
- Non-header packet colouring (connected station data, TNC responses)
- Keyword scanning with per-keyword foreground/background colours and
  optional audio beep (`Special Effects`)
- Windowed display system with border drawing (up to 8 nested windows)
- Split-screen view (ALT-V toggle)
- Auto-update mode toggle (Home key)

### Scroll-Back Buffer
- Configurable line count (default 200, max ~9999)
- Interactive viewer with Up/Down/PgUp/PgDn navigation
- Text search with start-line specification
- Line-number jump

### Serial / Comm
- COM1–COM4 (Linux: `/dev/ttyS0`–`/dev/ttyS3`)
- Baud: 300, 1200, 2400, 4800, 9600
- Data bits: 7 or 8; stop bits: 1 or 2; parity: None/Even/Odd
- Background I/O thread with ring buffers (`SIN_BUF_SIZE` = 4096,
  `SOUT_BUF_SIZE` = 4096 — matching the original Pascal variable names)
- DTR control, Carrier Detect polling, BREAK signal
- Per-byte and per-CRLF transmit delays
- Full/Half duplex toggle (ALT-F)

### YAPP File Transfer
Complete state machine with all 12 states recovered verbatim:  
`Start → SendInit → SendHeader → SendData → SendEof → SendEOT`  
`RcvWait → RcvHeader → RcvData → SndABORT → WaitAbtAck → RcdABORT`

All 17 packet types (`UK RR RF SI HD DT EF ET NR CN CA RI TX UU TM AF AT`)
and all 19 status messages recovered verbatim from the binary.

### File Operations
- **Capture mode** (ALT-C): toggle on/off, prompts for filename,
  optional date/time stamps
- **ASCII transmit** (ALT-T): XON/XOFF flow, pause/cancel with any key
- **File viewer** (ALT-V): paginated view, split-screen option, byte/line
  progress display
- **Directory listing** (ALT-D): with free-bytes display
- **Change directory/drive** (ALT-N)
- **Kill file** (ALT-K): delete with confirmation

### Configuration (PACKCOM.CNF)
22 options across two pages, all recovered from the config menu strings:

| # | Flag | Option |
|---|------|--------|
| 1 | P | Number of Stop Bits |
| 2 | P | Number of Data Bits |
| 3 | P | Parity Type |
| 4 | P | Baud Rate |
| 5 | P | Communication Port |
| 7 | X | Scroll Back Buffer Size |
| 8 |   | Incoming BELL (Ctrl-G) |
| 9 |   | Eliminate Blank Lines |
|10 |   | Time Management Every N Minutes |
|11 |   | Display Time |
|12 |   | Change Color |
|14 |   | 1/1000 Sec delay after byte |
|15 |   | 1/1000 Sec delay after CRLF |
|16 | X | Memory for DOS Programs (KB) |
|17 |   | Default DOS Program |
|18 | X | Set TNC Date and Time |
|19 | X | Drive/Path to Overlays |
|20 |   | Stream Switch Character |
|21 |   | Carrier Detect = Connected? |
|22 |   | BREAK → CMD mode? |

`P` = requires ALT-P reconnect to take effect  
`X` = requires restart to take effect

### Keyboard / Macros (PACKCOM.KEY)
- Line mode and Char mode (ALT-Q toggle)
- Full cursor navigation: Home, End, Ctrl-Home, Ctrl-End, Ins, Del,
  Ctrl-Left/Right word tab, Ctrl-PgUp/PgDn history scroll
- 40 macro slots (F1–F10 × Unshifted / Shifted / Ctrl / Alt)
- Macro syntax: `]` = CR, `@x` = TNC command char, `~` = 500ms delay,
  `;` = comment

### DOS Shell (ALT-E)
- Configurable memory allocation (option 16)
- Spawns configured program or the system shell
- `EXIT` returns to PackCom

---

## ALT-Key Command Reference

| Key    | Action |
|--------|--------|
| ALT-H  | Help – comm buffer commands |
| ALT-C  | Toggle capture mode |
| ALT-I  | Configuration menu |
| ALT-P  | Change comm parameters (reconnects port) |
| ALT-X  | Exit PackCom |
| ALT-V  | View file / toggle split screen |
| ALT-T  | Transmit ASCII file (XON/XOFF) |
| ALT-Y  | YAPP file transfer |
| ALT-D  | Disk directory |
| ALT-N  | New directory / drive |
| ALT-E  | Execute DOS command |
| ALT-S  | Scroll-back buffer processing |
| ALT-K  | Kill (delete) file |
| ALT-M  | Macro key definitions |
| ALT-Q  | Toggle Line / Char keyboard mode |
| ALT-F  | Toggle Full / Half duplex |
| ALT-B  | Send BREAK |
| ALT-A  | Alarms and special effects |
| ALT-O  | Other commands (comm port info) |
| Home   | Toggle auto-update of comm buffer |

---

## Building

### Prerequisites
- C++17 compiler: GCC 8+, Clang 7+, or MSVC 2019+
- POSIX: `pthread` library
- Windows: standard Win32 SDK (no extra dependencies)
- Optional: CMake 3.16+

### Linux / macOS

```bash
# With Make
make

# Or with CMake
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

### Windows (MSVC)

```cmd
mkdir build && cd build
cmake .. -G "Visual Studio 17 2022"
cmake --build . --config Release
```

### Windows (MinGW)

```bash
make CXX=g++
```

---

## Running

```bash
./packcom          # normal start
./packcom /I       # reinitialize PACKCOM.CNF to defaults
./packcom --help   # usage
```

On Linux, serial ports require appropriate permissions:
```bash
sudo usermod -aG dialout $USER   # then log out and back in
# or for a single session:
sudo chmod 666 /dev/ttyS1
```

---

## File Structure

```
packcom/
├── CMakeLists.txt
├── Makefile
├── README.md
├── include/
│   ├── packcom.h      # types, constants, config structs, YAPP enums
│   ├── platform.h     # OS abstraction interface
│   ├── keys.h         # unified key codes
│   ├── serial.h       # serial port + ring buffers
│   ├── terminal.h     # windowed display + scroll-back
│   ├── input.h        # keyboard editor + macros
│   ├── config.h       # config load/save + all menus
│   ├── yapp.h         # YAPP transfer protocol
│   ├── fileops.h      # capture, ASCII tx, file view, dir, shell
│   └── app.h          # top-level application class
└── src/
    ├── main.cpp
    ├── platform.cpp
    ├── serial.cpp
    ├── terminal.cpp
    ├── input.cpp
    ├── config.cpp
    ├── yapp.cpp
    ├── fileops.cpp
    └── app.cpp
```

---

## Notes on Fidelity

- All user-visible strings (prompts, error messages, status lines, menu
  text) were extracted verbatim from the original binaries and are used
  unchanged in this reconstruction.
- The original used Borland Pascal's direct BIOS/DOS interrupt calls for
  screen I/O (`INT 10h`) and serial I/O (`INT 14h` / custom ISR). These
  are replaced with ANSI escape sequences (POSIX) or Win32 Console API.
- The original's `async_intr_handler` hardware ISR is replaced by a
  background `std::thread` polling loop with the same ring-buffer
  variables (`sout_store_ptr`, `sout_read_ptr`, `sin_read_ptr`,
  `sin_buf_fill_cnt`) implemented as `std::atomic<int>` indices.
- `PACKCOM.WRD` (keyword file) loading is stubbed — keywords are stored
  in `PACKCOM.CNF` in this version.
- The `/I` re-initialization flag is preserved.
- The `TILT !!!` fatal error handler from the original is not needed;
  C++ exceptions handle abnormal termination.

---

## License

This reconstruction is an independent clean-room reimplementation for
historical preservation purposes. The original PackCom was freeware
distributed in the amateur radio community (WB4ZJV, 1987).
