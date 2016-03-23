cmake_minimum_required(VERSION 3.0)
project(hdphoto)
include(flags OPTIONAL)
set(lib_name hdphoto)
#######################################
# additional include directories
include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}/common/include
  ${CMAKE_CURRENT_SOURCE_DIR}/image/sys
  ${CMAKE_CURRENT_SOURCE_DIR}/systems/tools/wmpgluelib
  ${CMAKE_CURRENT_SOURCE_DIR}/systems/tools/wmpmetalib
  )
if(WIN32)
  include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/image/x86
    ${CMAKE_CURRENT_SOURCE_DIR}/network/client/debughlp/memtrace
    )
endif()
#######################################
# preprocessor
if(MSVC)
  add_definitions(
    -D_CRT_SECURE_NO_WARNINGS
    )
elseif(CMAKE_COMPILER_IS_GNUCXX OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
  add_definitions(
    -D__ANSI__
    -DDISABLE_PERF_MEASUREMENT
    )
endif()
#######################################
# library sources
###################
# Common
set(Common_srcs
  image/sys/adapthuff.c
  image/sys/common.h
  image/sys/image.c
  image/sys/perfTimer.h
  image/sys/perfTimerANSI.c
  image/sys/strcodec.c
  image/sys/strcodec.h
  image/sys/strPredQuant.c
  image/sys/strTransform.c
  image/sys/strTransform.h
  image/sys/windowsmediaphoto.h
  image/sys/xplatform_image.h
  )
source_group(Common FILES ${Common_srcs})
list(APPEND ${lib_name}_libsrcs ${Common_srcs})
###################
# Decode
set(Decode_srcs
  image/decode/decode.c
  image/decode/decode.h
  image/decode/huffman.c
  image/decode/postprocess.c
  image/decode/segdec.c
  image/decode/strdec.c
  image/decode/strInvTransform.c
  image/decode/strPredQuantDec.c
  image/decode/WMPTranscode.c
  )
source_group(Decode FILES ${Decode_srcs})
list(APPEND ${lib_name}_libsrcs ${Decode_srcs})
###################
# Encode
set(Encode_srcs
  image/encode/encode.c
  image/encode/encode.h
  image/encode/segenc.c
  image/encode/strenc.c
  image/encode/strFwdTransform.c
  image/encode/strPredQuantEnc.c
  )
source_group(Encode FILES ${Encode_srcs})
list(APPEND ${lib_name}_libsrcs ${Encode_srcs})
###################
# Include
set(Include_srcs
  common/include/guiddef.h
  common/include/wmsal.h
  common/include/wmspecstring.h
  common/include/wmspecstrings_adt.h
  common/include/wmspecstrings_strict.h
  )
source_group(Include FILES ${Include_srcs})
list(APPEND ${lib_name}_libsrcs ${Include_srcs})
###################
# Memtrace
if(WIN32)
  set(Memtrace_srcs
    network/client/debughlp/memtrace/heaptrace.cpp
    network/client/debughlp/memtrace/heaptrace.h
    network/client/debughlp/memtrace/memtrace.cpp
    network/client/debughlp/memtrace/memtrace.h
    network/client/debughlp/memtrace/memtrace_com.h
    network/client/debughlp/memtrace/regtrace.cpp
    network/client/debughlp/memtrace/regtrace.h
    network/client/debughlp/memtrace/sysheap.cpp
    network/client/debughlp/memtrace/sysMalloc.cpp
    )
  source_group(Memtrace FILES ${Memtrace_srcs})
  list(APPEND ${lib_name}_libsrcs ${Memtrace_srcs})
endif()
###################
# WMPGlue
set(WMPGlue_srcs
  systems/tools/wmpgluelib/WMPGlue.c
  systems/tools/wmpgluelib/WMPGlue.h
  systems/tools/wmpgluelib/WMPGlueBmp.c
  systems/tools/wmpgluelib/WMPGlueHdr.c
  systems/tools/wmpgluelib/WMPGluePFC.c
  systems/tools/wmpgluelib/WMPGluePnm.c
  systems/tools/wmpgluelib/WMPGlueTif.c
  systems/tools/wmpgluelib/WMPGlueWmp.c
  systems/tools/wmpgluelib/WMPGlueYUV.c
  )
source_group(WMPGlue FILES ${WMPGlue_srcs})
list(APPEND ${lib_name}_libsrcs ${WMPGlue_srcs})
###################
# WMPMeta
set(WMPMeta_srcs
  systems/tools/wmpmetalib/WMPMeta.c
  systems/tools/wmpmetalib/WMPMeta.h
  )
source_group(WMPMeta FILES ${WMPMeta_srcs})
list(APPEND ${lib_name}_libsrcs ${WMPMeta_srcs})
#######################################
# library
add_library(${lib_name} STATIC ${${lib_name}_libsrcs})
#######################################
# executables
set(exes WmpDecApp WmpEncApp)
foreach(exe ${exes})
  add_executable(${exe} systems/tools/samplecodenew/wmpencdecoder/${exe}.c)
  target_link_libraries(${exe} ${lib_name})
endforeach()
#######################################
# install
set(lib_hdrs
  "${Include_srcs}"
  image/sys/windowsmediaphoto.h
  systems/tools/wmpgluelib/WMPGlue.h
  systems/tools/wmpmetalib/WMPMeta.h
  )
install(TARGETS ${lib_name} EXPORT ${PROJECT_NAME}-targets
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  )
install(FILES ${lib_hdrs} DESTINATION include/hdphoto)
install(EXPORT ${PROJECT_NAME}-targets DESTINATION lib/cmake)
