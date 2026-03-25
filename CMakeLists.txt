cmake_minimum_required(VERSION 3.5)
project(mydumper)
file(READ "VERSION" ver_str)
string(REGEX MATCH "ver=\"([^\"]+)\"" _ ${ver_str})
set(ver ${CMAKE_MATCH_1})
string(REGEX MATCH "rev=\"([^\"]+)\"" _ ${ver_str})
set(rev ${CMAKE_MATCH_1})
set(VERSION "${ver}-${rev}")
set(ARCHIVE_NAME "${CMAKE_PROJECT_NAME}-${VERSION}")

#Required packages
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/modules)
find_package(MySQL)
find_package(ZLIB)
find_package(GLIB2)
find_package(PCRE2)
# find_package(JeMalloc)

#if (NOT JEMALLOC_FOUND)
#    MESSAGE(WARNING "Could not find JeMalloc library")
#endif ()

if (NOT MYSQL_FOUND)
    MESSAGE(FATAL_ERROR "Could not find MySQL or MariaDB client libraries")
endif ()

#option(BUILD_DOCS "Build the documentation" ON)

#if (BUILD_DOCS)
#  add_subdirectory(docs)
#endif (BUILD_DOCS)

if (PC_GLIB2_VERSION VERSION_GREATER "2.51")
  option(WITH_GLIB_uuid_string_random "uuid_string_random not available" ON)
endif (PC_GLIB2_VERSION VERSION_GREATER "2.51")

#if (PC_GLIB2_VERSION VERSION_LESS "2.68")
#	MESSAGE(FATAL_ERROR "GLIB version lower than 2.68")
#endif (PC_GLIB2_VERSION VERSION_LESS "2.68")

option(WITH_SSL "Build SSL support" ON)
if (MARIADB_FOUND AND NOT MARIADB_SSL AND WITH_SSL)
    message(WARNING "MariaDB was not build with SSL so cannot turn SSL on")
    set(WITH_SSL OFF)
endif()

if(WIN32)
  set(CMAKE_C_FLAGS "-std=gnu99 -Wall -Wno-deprecated-declarations -Wunused -Wwrite-strings -Wno-strict-aliasing -Wextra -Wshadow -g ${MYSQL_CFLAGS}")
else()
  set(CMAKE_C_FLAGS "-std=gnu99 -Wall -Wno-deprecated-declarations -Wunused -Wwrite-strings -Wno-strict-aliasing -Wextra -Wshadow -g -Werror ${MYSQL_CFLAGS}")
endif()
include_directories(${MYDUMPER_SOURCE_DIR} ${MYSQL_INCLUDE_DIR} ${GLIB2_INCLUDE_DIR} ${PCRE2_INCLUDE_DIR} ${ZLIB_INCLUDE_DIRS} )

OPTION(WITH_ASAN "Build with ASAN" OFF)
OPTION(WITH_TSAN "Build with TSAN" OFF)
OPTION(WITH_TSAN "Build with CircleCI" OFF)

IF(WITH_ASAN AND WITH_TSAN)
    MESSAGE(FATAL_ERROR "Cannot use ASAN and TSAN at the same time")
ENDIF()

IF(WITH_ASAN)
    add_compile_options(-fsanitize=address -fno-omit-frame-pointer)
#    add_link_options(-fsanitize=address -fno-omit-frame-pointer)
    set (CMAKE_EXE_LINKER_FLAGS "-fsanitize=address -fno-omit-frame-pointer")
    set (CMAKE_SHARED_LINKER_FLAGS "-fsanitize=address -fno-omit-frame-pointer")
    set (CMAKE_STATIC_LINKER_FLAGS "-fsanitize=address -fno-omit-frame-pointer")
ELSEIF(WITH_TSAN)
    add_compile_options(-fsanitize=thread -fno-omit-frame-pointer)
#    add_link_options(-fsanitize=thread -fno-omit-frame-pointer)
    set (CMAKE_EXE_LINKER_FLAGS "-fsanitize=thread -fno-omit-frame-pointer")
    set (CMAKE_SHARED_LINKER_FLAGS "-fsanitize=thread -fno-omit-frame-pointer")
    set (CMAKE_STATIC_LINKER_FLAGS "-fsanitize=thread -fno-omit-frame-pointer")
ELSE()
#    add_compile_options(-O3)
#    add_link_options(-O3)
#    set (CMAKE_SHARED_LINKER_FLAGS "-O3")
ENDIF()

if (NOT CMAKE_INSTALL_PREFIX)
  SET(CMAKE_INSTALL_PREFIX "/usr/local" CACHE STRING "Install path" FORCE)
endif (NOT CMAKE_INSTALL_PREFIX)
MARK_AS_ADVANCED(CMAKE)

CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/config.h.in ${CMAKE_CURRENT_SOURCE_DIR}/src/config.h )
SET( SHARED_SRCS src/server_detect.c src/connection.c src/logging.c src/set_verbose.c src/common.c src/tables_skiplist.c src/regex.c src/common_options.c src/pmm_thread.c src/checksum.c )
SET( MYDUMPER_SRCS src/mydumper/mydumper.c ${SHARED_SRCS} src/mydumper/mydumper_pmm.c src/mydumper/mydumper_start_dump.c src/mydumper/mydumper_jobs.c src/mydumper/mydumper_common.c src/mydumper/mydumper_stream.c src/mydumper/mydumper_database.c src/mydumper/mydumper_table.c src/mydumper/mydumper_working_thread.c src/mydumper/mydumper_daemon_thread.c src/mydumper/mydumper_exec_command.c src/mydumper/mydumper_masquerade.c src/mydumper/mydumper_chunks.c src/mydumper/mydumper_write.c src/mydumper/mydumper_arguments.c src/mydumper/mydumper_integer_chunks.c src/mydumper/mydumper_string_chunks.c src/mydumper/mydumper_partition_chunks.c src/mydumper/mydumper_file_handler.c src/mydumper/mydumper_create_jobs.c )
SET( MYLOADER_SRCS src/myloader/myloader.c ${SHARED_SRCS} src/myloader/myloader_pmm.c src/myloader/myloader_stream.c src/myloader/myloader_stream.c src/myloader/myloader_process.c src/myloader/myloader_common.c src/myloader/myloader_directory.c src/myloader/myloader_restore.c src/myloader/myloader_restore_job.c src/myloader/myloader_control_job.c src/myloader/myloader_process_filename.c src/myloader/myloader_process_file_type.c src/myloader/myloader_arguments.c src/myloader/myloader_worker_index.c src/myloader/myloader_worker_schema.c src/myloader/myloader_worker_loader.c src/myloader/myloader_worker_post.c src/myloader/myloader_database.c src/myloader/myloader_worker_loader_main.c src/myloader/myloader_table.c)

add_executable(mydumper ${MYDUMPER_SRCS})
add_executable(myloader ${MYLOADER_SRCS})

# Find OpenSSL - use modern imported targets if available (CMake 3.4+), otherwise fall back to variables
find_package(OpenSSL REQUIRED)
if (TARGET OpenSSL::SSL)
  set(OPENSSL_LINK_LIBRARIES OpenSSL::SSL OpenSSL::Crypto)
else ()
  set(OPENSSL_LINK_LIBRARIES ${OPENSSL_SSL_LIBRARY} ${OPENSSL_CRYPTO_LIBRARY})
  include_directories(${OPENSSL_INCLUDE_DIR})
endif ()

if (NOT JEMALLOC_FOUND)
  target_link_libraries(mydumper ${MYSQL_LIBRARIES} ${GLIB2_LIBRARIES} ${GTHREAD2_LIBRARIES} ${GIO2_LIBRARIES} ${GOBJECT2_LIBRARIES} ${PCRE2_LIBRARY} ${ZLIB_LIBRARIES} stdc++ m ${OPENSSL_LINK_LIBRARIES})
  target_link_libraries(myloader ${MYSQL_LIBRARIES} ${GLIB2_LIBRARIES} ${GTHREAD2_LIBRARIES} ${PCRE2_LIBRARY} ${ZLIB_LIBRARIES} stdc++ ${OPENSSL_LINK_LIBRARIES})
else ()
  target_link_libraries(mydumper ${JEMALLOC_LIBRARIES} ${MYSQL_LIBRARIES} ${GLIB2_LIBRARIES} ${GTHREAD2_LIBRARIES} ${GIO2_LIBRARIES} ${GOBJECT2_LIBRARIES} ${PCRE2_LIBRARY} ${ZLIB_LIBRARIES} stdc++ m ${OPENSSL_LINK_LIBRARIES})
  target_link_libraries(myloader ${JEMALLOC_LIBRARIES} ${MYSQL_LIBRARIES} ${GLIB2_LIBRARIES} ${GTHREAD2_LIBRARIES} ${PCRE2_LIBRARY} ${ZLIB_LIBRARIES} stdc++ ${OPENSSL_LINK_LIBRARIES})

endif ()

INSTALL(TARGETS mydumper myloader
  RUNTIME DESTINATION bin
)

if(WIN32)
  get_filename_component(_mysql_lib_dir "${MYSQL_LIBRARIES}" DIRECTORY)
  get_filename_component(_mingw_prefix "${_mysql_lib_dir}/.." ABSOLUTE)
  set(_mingw_bin "${_mingw_prefix}/bin")
  set(_runtime_dlls
    libwinpthread-1.dll
    libgcc_s_seh-1.dll
    libstdc++-6.dll
    libglib-2.0-0.dll
    libgthread-2.0-0.dll
    libgobject-2.0-0.dll
    libgio-2.0-0.dll
    libpcre2-8-0.dll
    libintl-8.dll
    libiconv-2.dll
    zlib1.dll
    libzstd.dll
    libmariadb.dll
    libcurl-4.dll
    libcrypto-3-x64.dll
    libssl-3-x64.dll
    libbrotlidec.dll
    libbrotlicommon.dll
    libidn2-0.dll
    libunistring-5.dll
    libnghttp2-14.dll
    libnghttp3-9.dll
    libngtcp2-16.dll
    libngtcp2_crypto_ossl-0.dll
    libpsl-5.dll
    libssh2-1.dll
  )

  foreach(_dll IN LISTS _runtime_dlls)
    if(EXISTS "${_mingw_bin}/${_dll}")
      install(FILES "${_mingw_bin}/${_dll}" DESTINATION bin)
    endif()
  endforeach()
endif()

if(WIN32)
  set(ETC_DEST "etc")
else()
  set(ETC_DEST "/etc")
endif()
INSTALL(FILES mydumper.cnf DESTINATION ${ETC_DEST} COMPONENT config)

if(WIN32)
  install(PROGRAMS
    package/windows/BackupWizard.ps1
    package/windows/RestoreWizard.ps1
    DESTINATION bin
  )
endif()

if(WIN32)
  set(CPACK_GENERATOR "ZIP")
  find_program(MAKENSIS_EXECUTABLE NAMES makensis)
  if(MAKENSIS_EXECUTABLE)
    list(APPEND CPACK_GENERATOR "NSIS")
    set(CPACK_NSIS_DISPLAY_NAME "mydumper")
    set(CPACK_NSIS_PACKAGE_NAME "mydumper")
    set(CPACK_NSIS_CONTACT "mydumper community")
    set(CPACK_NSIS_URL_INFO_ABOUT "https://github.com/mydumper/mydumper")
    set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)
  endif()
else()
  set(CPACK_GENERATOR "TGZ")
endif()

set(CPACK_PACKAGE_NAME "mydumper")
set(CPACK_PACKAGE_VENDOR "mydumper community")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "mydumper and myloader MySQL backup tools")
set(CPACK_PACKAGE_VERSION "${VERSION}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "mydumper")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
include(CPack)

add_custom_target(dist
  COMMAND git archive --format=tar.gz --prefix=${ARCHIVE_NAME}/
  -o ${CMAKE_BINARY_DIR}/${ARCHIVE_NAME}.tar.gz HEAD
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

OPTION(RUN_CPPCHECK "Run cppcheck" OFF)

IF(RUN_CPPCHECK)
  include(CppcheckTargets)
  add_cppcheck(mydumper)
  add_cppcheck(myloader)
ENDIF(RUN_CPPCHECK)

set(CIRCLECI_CONFIG_FILE "config.yml")

IF(WITH_CIRCLECI)
  add_custom_target( circleci_config_file_build ALL
    COMMAND ${mydumper_BINARY_DIR}/.circleci/circleci_config_builder.sh ${CIRCLECI_EXTRA_CONFIG} > ${mydumper_BINARY_DIR}/.circleci/${CIRCLECI_CONFIG_FILE}
    COMMENT "Creating ${CIRCLECI_CONFIG_FILE}"
  )
ENDIF(WITH_CIRCLECI)

MESSAGE(STATUS "------------------------------------------------")
MESSAGE(STATUS "MYSQL_CONFIG = ${MYSQL_CONFIG}")
MESSAGE(STATUS "CMAKE_INSTALL_PREFIX = ${CMAKE_INSTALL_PREFIX}")
MESSAGE(STATUS "BUILD_DOCS = ${BUILD_DOCS}")
MESSAGE(STATUS "WITH_SSL = ${WITH_SSL}")
MESSAGE(STATUS "RUN_CPPCHECK = ${RUN_CPPCHECK}")
MESSAGE(STATUS "WITH_ASAN = ${WITH_ASAN}")
MESSAGE(STATUS "WITH_TSAN = ${WITH_TSAN}")
MESSAGE(STATUS "WITH_CIRCLECI = ${WITH_CIRCLECI}")
MESSAGE(STATUS "Change a values with: cmake -D<Variable>=<Value>")
MESSAGE(STATUS "------------------------------------------------")
MESSAGE(STATUS)


#get_cmake_property(_variableNames VARIABLES)
#list (SORT _variableNames)
#foreach (_variableName ${_variableNames})
#    message(STATUS "${_variableName}=${${_variableName}}")
#endforeach()



