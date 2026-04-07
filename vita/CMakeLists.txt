option(BUILD_VITA "Build Vita SDK library (libcsound.a)" OFF)

if(BUILD_VITA)
  message(STATUS "Building Vita SDK library.")
  
  # Vita SDK configuration is done via Custom.cmake and crosscompile.cmake
  # This is just a placeholder to ensure the Vita directory is recognized
  # The actual library is built as part of the main Csound build with appropriate settings
  
  message(STATUS "Vita SDK build configured via Custom.cmake and crosscompile.cmake")
  message(STATUS "Build with: cmake .. -DCUSTOM_CMAKE=../Vita/Custom.cmake -DCMAKE_TOOLCHAIN_FILE=../Vita/crosscompile.cmake")
else()
  message(STATUS "Not building Vita SDK library. Set BUILD_VITA=ON to enable.")
endif()
