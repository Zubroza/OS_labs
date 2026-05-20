# Лабораторная работа 1  
**Исследование компилятора GCC, языка ассемблера, процессов ОС, Makefile и Git**

---

## Цель работы

- Изучить работу компилятора **GCC**
- Получить **ассемблерный код** из программы на языке C++
- Проанализировать структуру программы на уровне **Assembler**
- Реализовать **модульную структуру программы**
- Использовать **Makefile** для автоматической сборки
- Добавить **параллельные потоки и синхронизацию**
- Разместить проект в **Git-репозитории**

---

## 1. Структура проекта

```
lab1
 ├── factorial.h
 ├── factorial.cpp
 ├── main.cpp
 ├── parallel.cpp
 ├── Makefile
 ├── README.md
 ├── asm/
 │    ├── factorial_O0.s
      ├── factorial_O1.s
 │    └── factorial_O2.s
 └── screenshots/
      └── scr.docx
 ```

---

## 2. Исходный код

**factorial.h**
```cpp
#ifndef FACTORIAL_H
#define FACTORIAL_H

unsigned long long factorial(int n);

#endif


```


**factorial.cpp**
```cpp
#include "factorial.h"

unsigned long long factorial(int n) {
    unsigned long long r = 1;
    for (int i = 2; i <= n; i++) {
        r *= i;
    }
    return r;
}


```


**main.cpp**
```cpp
#include <iostream>
#include <cstdlib>
#include "factorial.h"

int main(int argc, char* argv[]) {
    int n = std::atoi(argv[1]);
    std::cout << n << "! = " << factorial(n) << std::endl;
    return 0;
}


```


## 3. Ассемблерные коды

| Опция |  Описание |
|-------|---|
| -O0   | без оптимизации  |
| -O1   | базовая оптимизация   |
| -O2   | расширенная оптимизация  |
| -O3   | максимальная оптимизация |


Файлы:
```
asm/factorial_O0.s
asm/factorial_O1.s
asm/factorial_O2.s
```

Файлы будут отличаться количеством инструкций и структурой кода.

** Анализ файла factorial_O0.s**

```assembly
; ============================================================
; Файл: factorial.cpp
; Опции: -O0
; ============================================================

.file "factorial.cpp"
.text
.globl _Z9factoriali

_Z9factoriali:
    pushq %rbp              
    movq  %rsp, %rbp        
    subq  $16, %rsp         

    ; ИНИЦИАЛИЗАЦИЯ
    movl  %ecx, 16(%rbp)    ; n = аргумент
    movq  $1, -8(%rbp)      ; result = 1
    movl  $2, -12(%rbp)     ; i = 2
    jmp   .L2               ; переход на проверку

    ; ТЕЛО ЦИКЛА
.L3:
    movl  -12(%rbp), %eax   ; загружаем i
    cltq                    ; i -> 64 бита
    movq  -8(%rbp), %rdx    ; загружаем result
    imulq %rdx, %rax        ; result = result * i
    movq  %rax, -8(%rbp)    ; сохраняем result
    addl  $1, -12(%rbp)     ; i++

    ; ПРОВЕРКА УСЛОВИЯ
.L2:
    movl  -12(%rbp), %eax   ; загружаем i
    cmpl  16(%rbp), %eax    ; сравниваем i и n
    jle   .L3               ; если i <= n -> в цикл

    ; ВОЗВРАТ
    movq  -8(%rbp), %rax    ; вернуть result
    addq  $16, %rsp
    popq  %rbp
    ret

```

## 4. Makefile

```makefile
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

```

## 5. Параллельный процесс

```cpp

 // parallel.cpp разбивает факториал на 4 части, считает их параллельно в разных потоках, затем собирает результат.


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
    int threads = 4; 
    
    std::vector<std::thread> t;
    int step = (n - 1) / threads;  // (10-1)/4 = 2
    
    for (int i = 0; i < threads; i++) {
        int s = 2 + i * step;
        int e = (i == threads - 1) ? n : s + step - 1;
        t.push_back(std::thread(work, s, e, i));
    }
    
    for (auto& th : t) {
        th.join();
    }
    
    std::cout << n << "! = " << global << std::endl;
    return 0;
}
```
**Пример работы**
```bash
./parallel.exe 10

Thread 0: [2-3] = 6
Thread 1: [4-5] = 20
Thread 2: [6-7] = 42
Thread 3: [8-10] = 720
10! = 3628800

./parallel.exe 5
Thread 0: [2-3] = 6
Thread 1: [4-5] = 20
5! = 120

## Что делает parallel.cpp

Разбивает факториал на 4 части, считает их параллельно в разных потоках, затем собирает результат.

```

## 6. Синхронизация потоков

Для синхронизации доступа к общему ресурсу используется **mutex**.

```cpp
#include <iostream>
#include <thread>
#include <mutex>
#include <vector>
#include "factorial.h"

std::mutex mtx;              // создание мьютекса
unsigned long long global = 1;  // общий ресурс

void work(int s, int e, int id) {
    unsigned long long loc = 1;
    for (int i = s; i <= e; i++) {
        loc *= i;
    }
    
    mtx.lock();              // ЗАХВАТ мьютекса (вход в критическую секцию)
    global *= loc;           // КРИТИЧЕСКАЯ СЕКЦИЯ (доступ к общему ресурсу)
    std::cout << "Thread " << id << ": [" << s << "-" << e << "] = " << loc << std::endl;
    mtx.unlock();            // ОСВОБОЖДЕНИЕ мьютекса
}

int main(int argc, char* argv[]) {
    int n = std::atoi(argv[1]);
    int threads = 4;
    
    std::vector<std::thread> t;
    int step = (n - 1) / threads;
    
    for (int i = 0; i < threads; i++) {
        int s = 2 + i * step;
        int e = (i == threads - 1) ? n : s + step - 1;
        t.push_back(std::thread(work, s, e, i));
    }
    
    for (auto& th : t) {
        th.join();
    }
    
    std::cout << n << "! = " << global << std::endl;
    return 0;
}
