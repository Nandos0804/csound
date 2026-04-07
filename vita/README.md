# Csound for PlayStation Vita

## Requirements

- x86_64 Linux host (native or WSL2)
- [Vita SDK](http://docs.vitasdk.org/) installed
- CMake 3.16+

> **Note:** The Vita SDK toolchain is x86_64 only. macOS on Apple Silicon and ARM-based
> Windows devices are not supported. On Windows x86_64, use WSL2 with Ubuntu.

### Installing Vita SDK

```bash
sudo apt update && sudo apt install -y cmake build-essential git

export VITASDK=/usr/local/vitasdk
export PATH=$VITASDK/bin:$PATH

git clone https://github.com/vitasdk/vdpm /tmp/vdpm
cd /tmp/vdpm
./bootstrap-vitasdk.sh
./install-all.sh
```

Add the environment variables to your shell profile (`~/.bashrc` or `~/.zshrc`):

```bash
echo 'export VITASDK=/usr/local/vitasdk' >> ~/.bashrc
echo 'export PATH=$VITASDK/bin:$PATH' >> ~/.bashrc
```

## Building libcsound.a

From the csound root directory:

```bash
mkdir build-vita && cd build-vita
cmake .. \
  -DCUSTOM_CMAKE=../Vita/Custom.cmake \
  -DCMAKE_TOOLCHAIN_FILE=$VITASDK/share/vita.toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

To install into the Vita SDK:

```bash
cmake .. \
  -DCUSTOM_CMAKE=../Vita/Custom.cmake \
  -DCMAKE_TOOLCHAIN_FILE=$VITASDK/share/vita.toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$VITASDK/arm-vita-eabi
make -j$(nproc)
make install
```

## Example: Oscillator on Vita

See [example_oscil.csd](example_oscil.csd) for a sample Csound orchestra.

A minimal Vita app that plays a 440 Hz sine wave through the Csound API:

### CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.16)

if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  if(DEFINED ENV{VITASDK})
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VITASDK}/share/vita.toolchain.cmake" CACHE PATH "toolchain file")
  else()
    message(FATAL_ERROR "Please define VITASDK to point to your SDK path!")
  endif()
endif()

project(csound_oscil)
include("${VITASDK}/share/vita.cmake" REQUIRED)

set(VITA_APP_NAME "Csound Oscillator")
set(VITA_TITLEID  "CSND00001")
set(VITA_VERSION  "01.00")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=gnu11 -Wall -O3")

add_executable(${PROJECT_NAME} src/main.c)

target_link_libraries(${PROJECT_NAME}
  csound m
  SceLibKernel_stub SceDisplay_stub SceCtrl_stub
  SceAudio_stub SceProcessMgr_stub
)

vita_create_self(eboot.bin ${PROJECT_NAME})
vita_create_vpk(${PROJECT_NAME}.vpk ${VITA_TITLEID} eboot.bin
  VERSION ${VITA_VERSION}
  NAME ${VITA_APP_NAME}
)
```

### src/main.c

```c
#include <stdint.h>
#include <psp2/kernel/processmgr.h>
#include <psp2/audioout.h>
#include <psp2/ctrl.h>
#include "csound.h"

#define SAMPLE_RATE 44100
#define BUFFER_SIZE 256

int main(void) {
    void *csound = csoundCreate(NULL);
    if (!csound) return 1;

    const char *orc =
        "sr = 44100\n"
        "ksmps = 1\n"
        "nchnls = 1\n"
        "0dbfs = 1\n"
        "instr 1\n"
        "  asig oscil 0.1, 440\n"
        "  out asig\n"
        "endin\n";

    const char *sco = "i 1 0 10\ne\n";

    if (csoundCompileOrc(csound, orc) != 0 ||
        csoundReadScore(csound, sco) != 0 ||
        csoundStart(csound) != 0) {
        csoundDestroy(csound);
        return 1;
    }

    int port = sceAudioOutOpenPort(
        SCE_AUDIO_OUT_PORT_TYPE_BGM, BUFFER_SIZE,
        SAMPLE_RATE, SCE_AUDIO_OUT_MODE_MONO);
    if (port < 0) { csoundDestroy(csound); return 1; }

    int vol = SCE_AUDIO_VOLUME_0DB;
    sceAudioOutSetVolume(port,
        SCE_AUDIO_VOLUME_FLAG_L_CH | SCE_AUDIO_VOLUME_FLAG_R_CH,
        (int[]){vol, vol});

    MYFLT *spout = csoundGetSpout(csound);
    int16_t buf[BUFFER_SIZE];
    SceCtrlData pad;

    while (1) {
        sceCtrlPeekBufferPositive(0, &pad, 1);
        if (pad.buttons & SCE_CTRL_START) break;

        if (csoundPerformKsmps(csound) == 0) {
            for (int i = 0; i < BUFFER_SIZE; i++)
                buf[i] = (int16_t)(spout[i] * 32767.0f);
            sceAudioOutOutput(port, buf);
        } else {
            break;
        }
    }

    sceAudioOutReleasePort(port);
    csoundStop(csound);
    csoundDestroy(csound);
    sceKernelExitProcess(0);
    return 0;
}
```

## Resources

- [Vita SDK docs](http://docs.vitasdk.org/)
- [Vita SDK samples](https://github.com/vitasdk/samples)
- [Vita SDK packages](https://github.com/vitasdk/packages)
- Optimization for Vita's specific audio subsystem
