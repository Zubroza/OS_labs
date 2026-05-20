# Лабораторная работа 1  
**Исследование компилятора GCC, языка ассемблера, процессов ОС, Makefile и Git**

---

# Цель работы

- Изучить работу компилятора **GCC**
- Получить **ассемблерный код** из программы на языке C
- Проанализировать структуру программы на уровне **Assembler**
- Реализовать **модульную структуру программы**
- Использовать **Makefile** для автоматической сборки
- Добавить **параллельный процесс и синхронизацию**
- Разместить проект в **Git-репозитории**

---

# 1. Реализация программы (вычисление факториала)
Файл src/factorial.h

```
#ifndef FACTORIAL_H
#define FACTORIAL_H

long long factorial(int n);

#endif
```

Файл src/factorial.c

```
#include "factorial.h"

long long factorial(int n)
{
    long long result = 1;

    for(int i = 1; i <= n; i++)
    {
        result = result * i;
    }

    return result;
}
```

Файл src/main.c
```
#include <stdio.h>
#include "factorial.h"

int main()
{
    int n;

    printf("Enter number: ");
    scanf("%d", &n);

    long long result = factorial(n);

    printf("Factorial = %lld\n", result);

    return 0;
}
```

# 3. Компиляция программы

Компилируем программу:
```
gcc src/main.c src/factorial.c -o factorial
```


Запускаем программу:
```
./factorial
```

Пример выполнения:

```
Enter number: 5
Factorial = 120
```

# 4. Генерация ассемблерного кода

Компилятор GCC позволяет сгенерировать Assembler код.

Команда:
```
gcc -S -o factorial.s src/factorial.c
```

В результате появляется файл:
```
factorial.s
```


# 5. Компиляция с разными оптимизациями

GCC поддерживает несколько уровней оптимизации:

| Опция |  Описание |
|-------|---|
| -O0   | без оптимизации  |
| -O1   |базовая оптимизация   |
| -O2   | расширенная оптимизация  |
| -O3   |  максимальная оптимизация |


Пример:
```
gcc -S -O0 src/factorial.c
gcc -S -O1 src/factorial.c
gcc -S -O2 src/factorial.c
gcc -S -O3 src/factorial.c
```

Файлы будут отличаться количеством инструкций и структурой кода.


# 6. Анализ ассемблерного кода

Ниже приведен фрагмент с комментариями.

```
.file "factorial.c"      # имя исходного файла

.text                    # секция машинного кода

.globl factorial         # объявление глобальной функции
.type factorial, @function

factorial:               # начало функции factorial

.LFB0:
.cfi_startproc

pushq %rbp               # сохранить старый указатель стека
movq %rsp, %rbp          # создать новый стековый фрейм

movl %edi, -20(%rbp)     # сохранить аргумент функции n

movq $1, -8(%rbp)        # result = 1
movl $1, -12(%rbp)       # i = 1

jmp .L2                  # переход к проверке условия цикла

.L3:                     # тело цикла

movl -12(%rbp), %eax     # eax = i
cltq                     # преобразование int → long

movq -8(%rbp), %rdx      # rdx = result

imulq %rdx, %rax         # rax = result * i

movq %rax, -8(%rbp)      # result = result * i

addl $1, -12(%rbp)       # i++

.L2:                     # проверка условия цикла

movl -12(%rbp), %eax     # eax = i
cmpl -20(%rbp), %eax     # сравнение i и n

jle .L3                  # если i <= n → повторить цикл

movq -8(%rbp), %rax      # вернуть result

popq %rbp                # восстановить стек

ret                      # возврат из функции

```

Соответствие переменных

| Переменная C | Адрес в ASM |
|--------------|-------------|
| n            | -20(%rbp)   |
| result       | -8(%rbp)    |
| i            | -12(%rbp)   |


**Цикл**

Цикл реализован с помощью переходов:
```
.L3 → тело цикла
.L2 → проверка условия
jle → переход
```

# 7. Создание Makefile

Файл Makefile:
```
CC=gcc
CFLAGS=-Wall

SRC=src/main.c src/factorial.c
TARGET=factorial

all:
	$(CC) $(CFLAGS) $(SRC) -o $(TARGET)

asm:
	$(CC) -S src/factorial.c

clean:
	rm -f factorial *.o *.s

```
Использование:
```
make
make asm
make clean
```

# 8. Добавление параллельного процесса

Используем системный вызов fork().

Пример программы:

```
#include <stdio.h>
#include <unistd.h>
#include "factorial.h"

int main()
{
    int n;

    printf("Enter number: ");
    scanf("%d",&n);

    pid_t pid = fork();

    if(pid == 0)
    {
        long long r = factorial(n);
        printf("Child process factorial = %lld\n", r);
    }
    else
    {
        printf("Parent process PID = %d\n", getpid());
    }

    return 0;
}
```

После запуска создаются два процесса:
- родительский
- дочерний


# 9. Синхронизация процессов (pipe)

Для передачи данных между процессами используется канал pipe.

```
#include <unistd.h>
#include <stdio.h>
#include "factorial.h"

int main()
{
    int fd[2];
    pipe(fd);

    pid_t pid = fork();

    if(pid == 0)
    {
        close(fd[0]);

        long long r = factorial(5);

        write(fd[1], &r, sizeof(r));
    }
    else
    {
        close(fd[1]);

        long long result;

        read(fd[0], &result, sizeof(result));

        printf("Result from child = %lld\n", result);
    }
}
```

Этот пример демонстрирует:
- создание канала
- передачу данных между процессами
- синхронизацию

# 10. Использование Git

Переходим в папку репозитория:

```
cd ~/operation_systems
```

Добавляем файлы:
```
git add .
```

Создаем коммит:
```
git commit -m "Lab1: gcc, assembler, makefile, processes"
```

Отправляем изменения:
```
git push
```

# 11. Структура итогового проекта

```
operation_systems
 └ lab1
     ├ src
     │   ├ main.c
     │   ├ factorial.c
     │   └ factorial.h
     ├ Makefile
     ├ factorial.s
     ├ README.md
     └ screenshots
```

# 12. Вывод

В ходе лабораторной работы:
- изучен компилятор GCC
- получен ассемблерный код программы
- проведен анализ структуры программы на уровне ASM
- реализована модульная структура программы
- создан Makefile
- реализован параллельный процесс
- выполнена синхронизация процессов
- проект размещен в GitHub
