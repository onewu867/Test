#include "mylib.h"

int MyLib::add(int a, int b) {
    return a + b;
}

int MyLib::multiply(int a, int b) {
    return a * b;
}

const char* MyLib::getVersion() {
    return "1.0.0";
}

