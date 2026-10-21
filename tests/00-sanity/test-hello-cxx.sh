SOURCE=${TEST_DIR}/hello.cc

compile_test() {
  "${CXX}" ${CXXFLAGS} "${SOURCE}" -o "${OUTPUT}"
}
