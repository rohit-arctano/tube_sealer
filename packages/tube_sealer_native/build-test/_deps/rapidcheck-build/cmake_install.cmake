# Install script for directory: C:/Users/rohit/Documents/application/tube_sealer/packages/tube_sealer_native/build-test/_deps/rapidcheck-src

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "C:/Program Files (x86)/tube_sealer_native_library")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "C:/Users/rohit/Documents/application/tube_sealer/packages/tube_sealer_native/build-test/_deps/rapidcheck-build/Debug/rapidcheck.lib")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "C:/Users/rohit/Documents/application/tube_sealer/packages/tube_sealer_native/build-test/_deps/rapidcheck-build/Release/rapidcheck.lib")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "C:/Users/rohit/Documents/application/tube_sealer/packages/tube_sealer_native/build-test/_deps/rapidcheck-build/MinSizeRel/rapidcheck.lib")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "C:/Users/rohit/Documents/application/tube_sealer/packages/tube_sealer_native/build-test/_deps/rapidcheck-build/RelWithDebInfo/rapidcheck.lib")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE DIRECTORY FILES "C:/Users/rohit/Documents/application/tube_sealer/packages/tube_sealer_native/build-test/_deps/rapidcheck-src/include/")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/rohit/Documents/application/tube_sealer/packages/tube_sealer_native/build-test/_deps/rapidcheck-build/ext/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/rohit/Documents/application/tube_sealer/packages/tube_sealer_native/build-test/_deps/rapidcheck-build/extras/cmake_install.cmake")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/share/rapidcheck/cmake/rapidcheckConfig.cmake")
    file(DIFFERENT _cmake_export_file_changed FILES
         "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/share/rapidcheck/cmake/rapidcheckConfig.cmake"
         "C:/Users/rohit/Documents/application/tube_sealer/packages/tube_sealer_native/build-test/_deps/rapidcheck-build/CMakeFiles/Export/cfc2e163caa257db3b835d2a8be41964/rapidcheckConfig.cmake")
    if(_cmake_export_file_changed)
      file(GLOB _cmake_old_config_files "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/share/rapidcheck/cmake/rapidcheckConfig-*.cmake")
      if(_cmake_old_config_files)
        string(REPLACE ";" ", " _cmake_old_config_files_text "${_cmake_old_config_files}")
        message(STATUS "Old export file \"$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/share/rapidcheck/cmake/rapidcheckConfig.cmake\" will be replaced.  Removing files [${_cmake_old_config_files_text}].")
        unset(_cmake_old_config_files_text)
        file(REMOVE ${_cmake_old_config_files})
      endif()
      unset(_cmake_old_config_files)
    endif()
    unset(_cmake_export_file_changed)
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rapidcheck/cmake" TYPE FILE FILES "C:/Users/rohit/Documents/application/tube_sealer/packages/tube_sealer_native/build-test/_deps/rapidcheck-build/CMakeFiles/Export/cfc2e163caa257db3b835d2a8be41964/rapidcheckConfig.cmake")
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rapidcheck/cmake" TYPE FILE FILES "C:/Users/rohit/Documents/application/tube_sealer/packages/tube_sealer_native/build-test/_deps/rapidcheck-build/CMakeFiles/Export/cfc2e163caa257db3b835d2a8be41964/rapidcheckConfig-debug.cmake")
  endif()
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rapidcheck/cmake" TYPE FILE FILES "C:/Users/rohit/Documents/application/tube_sealer/packages/tube_sealer_native/build-test/_deps/rapidcheck-build/CMakeFiles/Export/cfc2e163caa257db3b835d2a8be41964/rapidcheckConfig-minsizerel.cmake")
  endif()
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rapidcheck/cmake" TYPE FILE FILES "C:/Users/rohit/Documents/application/tube_sealer/packages/tube_sealer_native/build-test/_deps/rapidcheck-build/CMakeFiles/Export/cfc2e163caa257db3b835d2a8be41964/rapidcheckConfig-relwithdebinfo.cmake")
  endif()
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rapidcheck/cmake" TYPE FILE FILES "C:/Users/rohit/Documents/application/tube_sealer/packages/tube_sealer_native/build-test/_deps/rapidcheck-build/CMakeFiles/Export/cfc2e163caa257db3b835d2a8be41964/rapidcheckConfig-release.cmake")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig" TYPE FILE FILES "C:/Users/rohit/Documents/application/tube_sealer/packages/tube_sealer_native/build-test/_deps/rapidcheck-build/rapidcheck.pc")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "C:/Users/rohit/Documents/application/tube_sealer/packages/tube_sealer_native/build-test/_deps/rapidcheck-build/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
