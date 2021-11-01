# XXX <14-10-21, soltzen> We're using gomobile, but we need to ensure
# libc++_shared.so is included in the binary. This file just runs
# ndk-stl-config.cmake to do just that.
cmake_minimum_required(VERSION 3.10.2)
project("lantern-android")

message("Configuring STL ${so_base} for ${ANDROID_ABI}")
set(lib_path "llvm-libc++")
set(so_base "c++_shared")
configure_file(
  "${ANDROID_NDK}/sources/cxx-stl/${lib_path}/libs/${ANDROID_ABI}/lib${so_base}.so"
  "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/lib${so_base}.so"
  COPYONLY)
