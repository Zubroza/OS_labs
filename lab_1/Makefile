CXX = g++
CXXFLAGS = -Wall -std=c++11

all: factorial.exe parallel.exe

factorial.exe: main.cpp factorial.cpp factorial.h
	$(CXX) $(CXXFLAGS) -o $@ main.cpp factorial.cpp

parallel.exe: parallel.cpp factorial.cpp factorial.h
	$(CXX) $(CXXFLAGS) -o $@ parallel.cpp factorial.cpp -pthread

asm: factorial_O0.s factorial_O2.s

factorial_O0.s: factorial.cpp
	$(CXX) -S -O0 -o $@ factorial.cpp

factorial_O2.s: factorial.cpp
	$(CXX) -S -O2 -o $@ factorial.cpp

clean:
	rm -f *.exe *.o *.s

run: factorial.exe
	./factorial.exe 5

run_par: parallel.exe
	./parallel.exe 5

.PHONY: all asm clean run run_par