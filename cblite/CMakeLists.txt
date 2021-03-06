cmake_minimum_required (VERSION 3.1)
cmake_policy(VERSION 3.1)
project (cblite)
include("../cmake/common_setup.cmake")

set(LITECORE ${PROJECT_SOURCE_DIR}/../vendor/couchbase-lite-core/)
common_setup()
get_platform_libs(PLATFORM_LIBS)

set_property(DIRECTORY APPEND PROPERTY COMPILE_DEFINITIONS
    $<$<CONFIG:Debug>:DEBUG>
)

aux_source_directory("../cblite" CBLITE_SRC)
aux_source_directory("../litecp" LITECP_SRC)
aux_source_directory("../vendor/linenoise-ng/src" LINENOISE_SRC)
add_subdirectory(${LITECORE} LiteCore)
get_directory_property(LITECORE_LIBRARIES_PRIVATE DIRECTORY ${LITECORE} DEFINITION LITECORE_LIBRARIES_PRIVATE)

fix_cpp_runtime()

add_executable(
    cblite
    ${CBLITE_SRC}
    ${LITECP_SRC}
    ${LINENOISE_SRC}
    ../Tool.cc
    ../ArgumentTokenizer.cc
)

add_executable(
    cblitetest 
    ../ArgumentTokenizer.cc
    ../tests/tests_main.cc
    ../tests/TokenizerTest.cc
)

target_include_directories(
    cblite PRIVATE
    ${PROJECT_SOURCE_DIR}/..
    ${PROJECT_SOURCE_DIR}/../litecp
    ${PROJECT_SOURCE_DIR}/../vendor/linenoise-ng/include/
    ${LITECORE}C/
    ${LITECORE}C/include/
    ${LITECORE}LiteCore/Support/
    ${LITECORE}Replicator/                   # for CivetWebSocket.hh
    ${LITECORE}vendor/fleece/API/
    ${LITECORE}vendor/fleece/Fleece/Support/ # PlatformCompat.hh
    ${PROJECT_BINARY_DIR}/generated_headers/
)

target_compile_definitions(cblite PRIVATE -DCMAKE)
target_link_libraries(cblite ${LITECORE_LIBRARIES_PRIVATE} LiteCoreREST_Static ${PLATFORM_LIBS})
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
   target_link_libraries(cblite ${ICU4C_COMMON} ${ICU4C_I18N})
endif()

target_include_directories(
    cblitetest PRIVATE
    ${LITECORE}vendor/fleece/vendor/catch
    ${LITECORE}LiteCore/Support/
    ${LITECORE}LiteCore/Storage/
    ${LITECORE}vendor/fleece/Fleece/Support/
    ${LITECORE}vendor/fleece/API/
    ${LITECORE}vendor/BLIP-Cpp/src/util
    ${LITECORE}C/include/
    ${PROJECT_SOURCE_DIR}/..
)

target_link_libraries(
    cblitetest PRIVATE
    ${PLATFORM_LIBS}
)

install (
    TARGETS cblite cblitetest
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
)