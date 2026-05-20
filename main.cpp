#include <iostream>
#include <cstdlib>
#include "factorial.h"

int main(int argc, char* argv[]) {
    int n = std::atoi(argv[1]);
    std::cout << n << "! = " << factorial(n) << std::endl;
    return 0;
}
