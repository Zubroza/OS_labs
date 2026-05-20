#include <iostream>
#include <cstdlib>
#include <thread>
#include <mutex>
#include <vector>
#include "factorial.h"

std::mutex mtx;
unsigned long long global = 1;

void work(int s, int e, int id) {
    unsigned long long loc = 1;
    for (int i = s; i <= e; i++) {
        loc *= i;
    }
    mtx.lock();
    global *= loc;
    std::cout << "Thread " << id << ": [" << s << "-" << e << "] = " << loc << std::endl;
    mtx.unlock();
}

int main(int argc, char* argv[]) {
    int n = std::atoi(argv[1]);
    int threads = std::thread::hardware_concurrency();
    if (threads == 0) threads = 2;

    std::vector<std::thread> t;
    int step = (n - 1) / threads;

    for (int i = 0; i < threads; i++) {
        int s = 2 + i * step;
        int e = (i == threads - 1) ? n : s + step - 1;
        if (s <= n) {
            t.push_back(std::thread(work, s, e, i));
        }
    }

    for (auto& th : t) {
        th.join();
    }

    std::cout << n << "! = " << global << std::endl;
    return 0;
}
