set(CMAKE_CXX_FLAGS_COMMON "-g -Wall -Wextra")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_COMMON}")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_COMMON} -O3")

list(APPEND CMAKE_REQUIRED_FLAGS -std=gnu++14)
function(apply_folly_compile_options_to_target THETARGET)
  target_compile_definitions(${THETARGET}
    PRIVATE
      _REENTRANT
      _GNU_SOURCE
      "FOLLY_XLOG_STRIP_PREFIXES=\"${FOLLY_DIR_PREFIXES}\""
  )
  target_compile_options(${THETARGET}
    PRIVATE
      -g
      -std=c++17
      -finput-charset=UTF-8
      -fsigned-char
      -Werror
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
endfunction()
