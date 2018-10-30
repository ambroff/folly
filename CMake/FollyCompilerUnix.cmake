set(CMAKE_CXX_FLAGS_COMMON "-g -Wall -Wextra")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_COMMON}")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_COMMON} -O3")

if (APPLE)
  list(APPEND CMAKE_REQUIRED_FLAGS -std=c++17)
else()
  list(APPEND CMAKE_REQUIRED_FLAGS -std=gnu++14)
endif()

function(apply_folly_compile_options_to_target THETARGET)
  if (APPLE)
    target_compile_definitions(${THETARGET} PRIVATE
      "FOLLY_XLOG_STRIP_PREFIXES=\"${FOLLY_DIR_PREFIXES}\""
      )
  else()
    target_compile_definitions(${THETARGET}
      PRIVATE
        _REENTRANT
        _GNU_SOURCE
        "FOLLY_XLOG_STRIP_PREFIXES=\"${FOLLY_DIR_PREFIXES}\""
      )
    target_compile_options(${THETARGET}
      PRIVATE
        -g
        -std=gnu++14
        -finput-charset=UTF-8
        -fsigned-char
        -Wno-error
        -Wall
        -Wno-deprecated
        -Wdeprecated-declarations
        -Wno-error=deprecated-declarations
        -Wno-sign-compare
        -Wno-unused
        -Wno-inconsistent-missing-override
        -Wunused-label
        -Wunused-result
        -Wnon-virtual-dtor
        -Wno-missing-exception-spec
        ${FOLLY_CXX_FLAGS}
      )
  endif()
endfunction()
