SOURCE=${TEST_DIR}/tls_destruction_order.cpp

compile_test() {
  "${CXX}" ${CXXFLAGS} "${SOURCE}" -o "${OUTPUT}"
}
