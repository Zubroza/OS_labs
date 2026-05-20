#include "factorial.h"

unsigned long long factorial(int n) {
    unsigned long long r = 1;
    for (int i = 2; i <= n; i++) {
        r *= i;
    }
    return r;
}
