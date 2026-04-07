# Vita SDK Cross-Compilation Toolchain
# This file configures CMake to use the Vita SDK toolchain for building Csound libraries

# Detect VITASDK path
if(NOT DEFINED VITASDK)
  if(DEFINED ENV{VITASDK})
    set(VITASDK "$ENV{VITASDK}")
  else()
    message(FATAL_ERROR "Please define VITASDK environment variable or pass -DVITASDK=/path/to/vitasdk")
  endif()
endif()

# Use Vita SDK's official toolchain as a base
if(EXISTS "${VITASDK}/share/vita.toolchain.cmake")
  include("${VITASDK}/share/vita.toolchain.cmake")
else()
  message(FATAL_ERROR "Vita SDK toolchain not found at ${VITASDK}/share/vita.toolchain.cmake")
endif()

# Additional Csound-specific configuration
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Vita SDK cross-compiler paths (override if needed)
if(NOT CMAKE_C_COMPILER)
  set(CMAKE_C_COMPILER "${VITASDK}/bin/arm-vita-eabi-gcc")
endif()
if(NOT CMAKE_CXX_COMPILER)
  set(CMAKE_CXX_COMPILER "${VITASDK}/bin/arm-vita-eabi-g++")
endif()
if(NOT CMAKE_AR)
  set(CMAKE_AR "${VITASDK}/bin/arm-vita-eabi-ar")
endif()
if(NOT CMAKE_RANLIB)
  set(CMAKE_RANLIB "${VITASDK}/bin/arm-vita-eabi-ranlib")
endif()

# Search paths for libraries and headers
set(CMAKE_FIND_ROOT_PATH "${VITASDK}/arm-vita-eabi")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Ensure include and lib paths are properly set
list(APPEND CMAKE_INCLUDE_PATH "${VITASDK}/arm-vita-eabi/include")
list(APPEND CMAKE_LIBRARY_PATH "${VITASDK}/arm-vita-eabi/lib")
