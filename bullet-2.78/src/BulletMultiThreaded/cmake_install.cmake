# Install script for directory: /Users/9r0ximi7y/Documents/Common Code/bullet-2.78/src/BulletMultiThreaded

# Set the install prefix
IF(NOT DEFINED CMAKE_INSTALL_PREFIX)
  SET(CMAKE_INSTALL_PREFIX "/Library/Frameworks")
ENDIF(NOT DEFINED CMAKE_INSTALL_PREFIX)
STRING(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
IF(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  IF(BUILD_TYPE)
    STRING(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  ELSE(BUILD_TYPE)
    SET(CMAKE_INSTALL_CONFIG_NAME "RelWithDebInfo")
  ENDIF(BUILD_TYPE)
  MESSAGE(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
ENDIF(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)

# Set the component getting installed.
IF(NOT CMAKE_INSTALL_COMPONENT)
  IF(COMPONENT)
    MESSAGE(STATUS "Install component: \"${COMPONENT}\"")
    SET(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  ELSE(COMPONENT)
    SET(CMAKE_INSTALL_COMPONENT)
  ENDIF(COMPONENT)
ENDIF(NOT CMAKE_INSTALL_COMPONENT)

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/." TYPE SHARED_LIBRARY FILES
    "/Users/9r0ximi7y/Documents/Common Code/bullet-2.78/src/BulletMultiThreaded/libBulletMultiThreaded.2.78.dylib"
    "/Users/9r0ximi7y/Documents/Common Code/bullet-2.78/src/BulletMultiThreaded/libBulletMultiThreaded.dylib"
    )
  FOREACH(file
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/./libBulletMultiThreaded.2.78.dylib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/./libBulletMultiThreaded.dylib"
      )
    IF(EXISTS "${file}" AND
       NOT IS_SYMLINK "${file}")
      EXECUTE_PROCESS(COMMAND "/usr/bin/install_name_tool"
        -id "/Library/Frameworks/libBulletMultiThreaded.2.78.dylib"
        -change "/Users/9r0ximi7y/Documents/Common Code/bullet-2.78/src/BulletCollision/BulletCollision.framework/Versions/2.78/BulletCollision" "/Library/Frameworks/BulletCollision.framework/Versions/2.78/BulletCollision"
        -change "/Users/9r0ximi7y/Documents/Common Code/bullet-2.78/src/BulletDynamics/BulletDynamics.framework/Versions/2.78/BulletDynamics" "/Library/Frameworks/BulletDynamics.framework/Versions/2.78/BulletDynamics"
        -change "/Users/9r0ximi7y/Documents/Common Code/bullet-2.78/src/LinearMath/LinearMath.framework/Versions/2.78/LinearMath" "/Library/Frameworks/LinearMath.framework/Versions/2.78/LinearMath"
        "${file}")
      IF(CMAKE_INSTALL_DO_STRIP)
        EXECUTE_PROCESS(COMMAND "/usr/bin/strip" "${file}")
      ENDIF(CMAKE_INSTALL_DO_STRIP)
    ENDIF()
  ENDFOREACH()
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")

IF(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  INCLUDE("/Users/9r0ximi7y/Documents/Common Code/bullet-2.78/src/BulletMultiThreaded/GpuSoftBodySolvers/cmake_install.cmake")

ENDIF(NOT CMAKE_INSTALL_LOCAL_ONLY)

