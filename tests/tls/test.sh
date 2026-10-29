SOURCE=${TEST_DIR}/tls_destruction_order.cpp

# Skip until Cygwin's mingw-w64 got a394c23a51
test_supported() {
  [[ ${TEST_COMBINATION} != cygwin-cross ]]
}

compile_test() {
  "${CXX}" ${CXXFLAGS} "${SOURCE}" -o "${OUTPUT}"
}
